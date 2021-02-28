#define _GNU_SOURCE
#include <immintrin.h>
#include <sched.h>
#include <pthread.h>
#include <numa.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdbool.h>
#include <sys/mman.h>
#include "ffwd.h"
#include "fiber_scheduler.h"
#include "spsc_fifo.h"

#define MAX_SERVERS 54

#ifdef SERVER_CONTROLLED_DOORBELL
int doorbell[MAX_SERVERS + 10] __attribute__((aligned(128)));
#else
__m128i doorbell[MAX_SERVERS*4 + 10] __attribute__((aligned(128)));
#endif

#ifdef DEBUG_YIELD
__thread int test = 0;
#endif 

volatile int num_of_server_launched = 0;
struct thread_attr *thread_attrs[TOTAL_NUM_OF_THREADS+1]; // +1 is for the main manager

__thread uint64_t child_ret_value;
__thread fiber_t* main_server_fiber;
__thread struct server_args* this_server;

struct server_set *server_response_group_set[MAX_SERVERS];
struct server_args *server_arg[MAX_SERVERS];

forloop(`chip', `0', MAX_SOCK-1, 
`struct request *`chip'chip[MAX_SERVERS];
')

#ifdef PTHREAD
__thread int my_id;
int id_tracker = -1;
void pin_the_thread(int core_id){
	int num_cpu = numa_num_configured_cpus();
	struct bitmask * cpumask = numa_bitmask_alloc(num_cpu);
	numa_bitmask_setbit(cpumask, core_id);
	numa_sched_setaffinity(0, cpumask);
	my_id = core_id;
}
#endif
volatile int num_of_hwth_to_check = TOTAL_NUM_OF_THREADS;
volatile int num_of_req_lines_to_check;

volatile char finished[128 * MAX_SERVERS] __attribute__((aligned(128))) = {0};

inline void __attribute__((always_inline)) copy_to_client_resp(__m128i* to, __m128i* from) {
	forloop(`i', `0', CLIENT_PER_RESPONSE-1, `__m128i `temp'i = _mm_load_si128(from+i);
	')

	forloop(`i', `0', CLIENT_PER_RESPONSE-1, `_mm_stream_si128(to+i,`temp'i);
	')
}

void switch_no_maintenance(){

	// parent switches to child
	if (fiber_manager_get()->current_fiber == main_server_fiber){
		fiber_manager_switch_no_maintenance(((fiber_manager_t*)(this_server->manager)), ((fiber_manager_t*)(this_server->manager))->current_fiber, this_server->request_fibers[this_server->req_fiber_index]);

		// child still needs to wait
		if (this_server->still_need_to_wait == 1){
			this_server->still_need_to_wait = 0;
			int index = this_server->req_fiber_index;
			// return to label 5
			__asm__ __volatile__ (  "movq %0, %%rbx \n\t" 
									"movq %%rbx,  0x8(%%rbp)" 
									: 
									: "m" (this_server->ret_addrs[index][2]) 
									: "memory", "rbx"); 
		}

	}
	//child switches to parent
	else{
		fiber_manager_switch_no_maintenance(((fiber_manager_t*)(this_server->manager)), ((fiber_manager_t*)(this_server->manager))->current_fiber, main_server_fiber);
	}

	return;
}

void recycle_child(uint64_t ret){

	mpsc_fifo_node_t* const node = this_server->request_fibers[this_server->req_fiber_index]->mpsc_fifo_node;
	assert(node);
	node->data = this_server->request_fibers[this_server->req_fiber_index];
	spsc_lifo_push(&(((fiber_manager_t*)(this_server->manager))->recyled_fibers), (spsc_lifo_node_t*)node);
	this_server->request_fibers[this_server->req_fiber_index] = 0;
}

inline void prepare_request_argvs(struct request* myrequest, int arg_count, ...){
	va_list args;
	va_start(args, arg_count);
	int i;
	assert(arg_count<=6);

	for (i = 0; i < arg_count; i++){
 		myrequest->argv[i] = va_arg(args, uint64_t);
	}

	va_end(args);
}

//__attribute__((noinline))
inline void send_next_request_if_any(fiber_scheduler_dist_t* scheduler, int req_index, struct thread_attr* my_thread, int lock_holder){
		
	fiber_t* fiber_waiting_for_req_line;
	int server_no = req_index / REQS_LINES_PER_THREAD;
	fiber_manager_t* manager = fiber_manager_get();

	spsc_node_t* waiting_node = spsc_fifo_trypop(&(scheduler->req_lock_queue[server_no]));
	
	if (waiting_node){

		fiber_waiting_for_req_line = (fiber_t*)waiting_node->data;
		fiber_waiting_for_req_line->mpsc_fifo_node = waiting_node;
		fiber_waiting_for_req_line->state = FIBER_STATE_WAIT_FOR_RESP;

		manager->resp_waiting_fibers[req_index] = fiber_waiting_for_req_line;
		my_thread->is_locked[req_index] = 1;

		fiber_waiting_for_req_line->my_request.flag = my_thread->request[req_index]->flag ^ 1;
		memcpy(my_thread->request[req_index], &(fiber_waiting_for_req_line->my_request), sizeof(struct request));

		//my_thread->server_last_request_time[server_no]=__rdtsc();

		#ifdef SERVER_CONTROLLED_DOORBELL
			if (doorbell[0] == 0) doorbell[0] = 1;	//set only if it's not 1
		#endif
		
	}
	else{
		if (lock_holder == 1){
			my_thread->is_locked[req_index] = 0;
		}
	}
}

fiber_t* ffwd_poll_resp(fiber_manager_t* manager, fiber_scheduler_t* sched){
	
 	fiber_scheduler_dist_t* const scheduler = (fiber_scheduler_dist_t*)sched;
	fiber_t* new_fiber;
	spsc_node_t* node = NULL;
	struct thread_attr * my_thread = thread_attrs[manager->core_id];
	int mycoreid = my_thread->coreid_in_chip;
	// %64 is because the largest variable is uint64_t which has 64 bits
	int shift_base = (mycoreid * REQS_LINES_PER_THREAD)%64;
	int num_of_request_lines = num_of_server_launched * REQS_LINES_PER_THREAD;
	int lock_holder;


#if defined(DOORBELL) && !defined(SERVER_CONTROLLED_DOORBELL)
	uint64_t now = __rdtsc();
#endif

	for (int i=0; i < num_of_request_lines; i++){
		
		// only poll this server's response line if the last request went out a while ago
		/*

		if(i%2==0 && now-my_thread->server_last_request_time[i/REQS_LINES_PER_THREAD] < 6100) {
			i++;
			continue;
		}
		*/

#if defined(DOORBELL) && ! defined(SERVER_CONTROLLED_DOORBELL) && !defined(SKIP_POLL)
		if( now - manager->last_time > 100000 ){
			__m128i val = {now, now};
	//		int val_small = (int) now;
				
		#ifdef NT_STORE
			_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD ], val);
			_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD + MAX_SERVERS], val);
			_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD + MAX_SERVERS*2], val);
			_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD + MAX_SERVERS*3], val);
			_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD + MAX_SERVERS*4], val);
			_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD + MAX_SERVERS*5], val);
			_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD + MAX_SERVERS*6], val);
//			_mm_stream_si128(&doorbell[1], val);
//			_mm_stream_si128(&doorbell[2], val);
//			_mm_stream_si128(&doorbell[3], val);
//			_mm_stream_si128(&doorbell[4], val);
//			_mm_stream_si128(&doorbell[5], val);
//			_mm_stream_si128(&doorbell[6], val);
//			_mm_stream_si128(&doorbell[7], val);
		#else
			doorbell[0] = val;
		#endif
		}

#endif

		new_fiber = manager->resp_waiting_fibers[i];

		if(new_fiber){
			if (!(( (my_thread->core_resp[i]->flag >> (shift_base + (i%REQS_LINES_PER_THREAD))) ^ (my_thread->request[i]->flag)) & ((uint64_t)1 ) )){ // resp is ready
				lock_holder = 1;
				new_fiber->response_retval = my_thread->core_resp[i]->return_value;
				manager->resp_waiting_fibers[i] = NULL;
					
				send_next_request_if_any(scheduler, i, my_thread, lock_holder);

		#if defined(DOORBELL) && !defined(SKIP_POLL) && !defined(SERVER_CONTROLLED_DOORBELL)
			#ifdef NT_STORE
				__m128i val = {now, now};
				_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD], val);
				_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD + MAX_SERVERS], val);
				_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD + MAX_SERVERS*2], val);
				_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD + MAX_SERVERS*3], val);
				_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD + MAX_SERVERS*4], val);
				_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD + MAX_SERVERS*5], val);
				_mm_stream_si128(&doorbell[i/REQS_LINES_PER_THREAD + MAX_SERVERS*6], val);
	//					_mm_stream_si128(&doorbell[1], val);
	//					_mm_stream_si128(&doorbell[2], val);
	//					_mm_stream_si128(&doorbell[3], val);
	//					_mm_stream_si128(&doorbell[4], val);
	//					_mm_stream_si128(&doorbell[5], val);
	//					_mm_stream_si128(&doorbell[6], val);
	//					_mm_stream_si128(&doorbell[7], val);
				__asm__ __volatile__ ("sfence" ::: "memory");
				manager->last_time = now;
				manager->last_client = new_fiber->my_id;
			#else
				__m128i val = {now, now};
				doorbell[0] = val;
				manager->last_time = now;
				manager->last_client = new_fiber->my_id;
			#endif
		#endif

				new_fiber->state = FIBER_STATE_READY;
				node = new_fiber->mpsc_fifo_node;
				assert(node);
				new_fiber->mpsc_fifo_node = NULL;
				node->data = new_fiber;
				spsc_fifo_push(((fiber_scheduler_dist_t*)scheduler)->runnable_queue, node);
				/*
				if(scheduler->runnable_queue == &(scheduler->runnable_queue1))
					scheduler->curr_queue1_length++;
				else
					scheduler->curr_queue2_length++;
				*/
			}
		#ifdef SERVER_CONTROLLED_DOORBELL
			else if (doorbell[0] == 0) doorbell[0] = 1; // only do that if a request is still pending
		#endif
		}
		else {
			// if no-one is waiting for this request line, we can send something
			lock_holder = 0;
			send_next_request_if_any(scheduler, i, my_thread, lock_holder);
		}
	}
	 
	return NULL;
}


void fiber_push_and_wait_for_req_lock(int server_no){

#ifdef NO_RL_BUFFERING
	fiber_manager_t* manager = fiber_manager_get();
	struct thread_attr * my_thread = thread_attrs[manager->core_id];
	
	if (manager->resp_waiting_fibers[server_no]){
		push_and_wait_for_req_lock(server_no);
	} else {

		fiber_t * fiber_waiting_for_req_line = manager->current_fiber;
		//fiber_waiting_for_req_line->mpsc_fifo_node = waiting_node; not sure about this
		fiber_waiting_for_req_line->state = FIBER_STATE_WAIT_FOR_RESP;

		manager->resp_waiting_fibers[server_no] = fiber_waiting_for_req_line;
		my_thread->is_locked[server_no] = 1;

		fiber_waiting_for_req_line->my_request.flag = my_thread->request[server_no]->flag ^ 1;
		memcpy(my_thread->request[server_no], &(fiber_waiting_for_req_line->my_request), sizeof(struct request));
		fiber_yield();
	}
#else
	push_and_wait_for_req_lock(server_no);
#endif

}

inline void send_next_nested_request_if_any(fiber_scheduler_dist_t* scheduler, int req_index, struct thread_attr* my_thread, int lock_holder){
	
	fiber_t* fiber_waiting_for_req_line;
	int server_no = req_index / REQS_LINES_PER_THREAD;
	fiber_manager_t* manager = fiber_manager_get();
	spsc_node_t* waiting_node = spsc_fifo_trypop(&(scheduler->req_lock_queue[server_no]));

	if (waiting_node){

		fiber_waiting_for_req_line = (fiber_t*)waiting_node->data;
		fiber_waiting_for_req_line->mpsc_fifo_node = waiting_node;

		fiber_waiting_for_req_line->my_request.flag = my_thread->request[req_index]->flag ^ 1; 
		memcpy(my_thread->request[req_index], &(fiber_waiting_for_req_line->my_request), sizeof(struct request)); 
		
		fiber_waiting_for_req_line->request_state = FIBER_CHILD_WAITING_FOR_NESTED;
		manager->resp_waiting_fibers[req_index] = fiber_waiting_for_req_line;
		my_thread->is_locked[req_index] = 1;
	} 
	else if (lock_holder){
		my_thread->is_locked[req_index] = 0;
	}
}

inline void poll_server_resp(struct server_args* this_server, fiber_manager_t* manager, int shift_base){

	int j;
	for (j=0; j < num_of_server_launched*REQS_LINES_PER_THREAD; j++){

		if (manager->resp_waiting_fibers[j]){ //because in the begining it seems all resps are ready
			if(!( ( (thread_attrs[this_server->server_core]->core_resp[j]->flag >> (shift_base + (j%REQS_LINES_PER_THREAD))) ^ thread_attrs[this_server->server_core]->request[j]->flag) & ((uint64_t)1) )){ //resp is ready

				assert(manager->resp_waiting_fibers[j]->request_state == FIBER_CHILD_WAITING_FOR_NESTED);
				manager->resp_waiting_fibers[j]->request_state = FIBER_REQUEST_RESUMABLE; // means in the next round server should process the rest of the request
				manager->resp_waiting_fibers[j]->response_retval = thread_attrs[this_server->server_core]->core_resp[j]->return_value;

				manager->resp_waiting_fibers[j] = NULL;

				// if any fiber is waiting for our req line, copy their request
				fiber_scheduler_t* scheduler = manager->scheduler;
				send_next_nested_request_if_any((fiber_scheduler_dist_t*)scheduler, j, thread_attrs[this_server->server_core], 1);
			}
		}
		// else if (any request is waiting to be sent)
		else{
			// TODO :: check this assert ????
			assert(thread_attrs[this_server->server_core]->is_locked[j] == 0);
			send_next_nested_request_if_any((fiber_scheduler_dist_t*)(manager->scheduler), j, thread_attrs[this_server->server_core], 0);
		}

	}
}

void* server_func(void*);

// got the code for manually creating C labels from this link: https://gist.github.com/gby/3847477
// Start a new block in the jump table
#define start_here(_table_addr) \
	asm volatile ( \
		".pushsection my_jump_table,\"a\"\n" \
		".align 8\n" \
		"1: .quad 1b\n" \
		".popsection \n\t" \
		"movq $1b-server_func, %0\n" \
		: "=r"(_table_addr): : "memory"); \
		_table_addr++


#ifdef FAST_PATH 

inline int __attribute__((always_inline)) process_request(uint64_t* server_local_resp_flags, int id_in_chip, struct server_response* server_local_responses, struct request* chip_req_array, struct server_args* this_server, int chip){
	
	int resp_ready = 0;

	// to make it fit uint64_t variable
	int shift_base = id_in_chip % 64;

	__asm__ __volatile__ ("############## if there is a new request start processing, if not check if any nested resp is ready (label 8) ############ \n\t"
						"############## ((*server_local_resp_flags >> id_in_chip) ^ (chip_req_array[id_in_chip].flag)) & (uint64_t)1 ############\n\t"
						"movq 	%3, %%rax \n\t"
						"movl 	%12, %%ecx \n\t"
						"shr 	%%cl, %%rax \n\t"
						"xor 	%5, %%rax \n\t"
						"test   $0x1,%%al \n\t"
						"je 	5f \n\t"
						"1: \n\t"
						"############## prepare function inputs and call ############ \n\t"
						"movq 	%6, %%r9 \n\t"
						"movq 	%7, %%r8 \n\t"
						"movq 	%8, %%rcx \n\t"
						"movq 	%9, %%rdx \n\t"
						"movq 	%10, %%rsi \n\t"
						"movq 	%11, %%rdi \n\t"
						"call 	*%4 \n\t"
						"############## update the flag and return value ############ \n\t"
						"movq 	%%rax, %2 \n\t"
						"movq 	$1, %%rax \n\t"
						"movl 	%12, %%ecx \n\t"
						"shl 	%%cl, %%rax \n\t"
						"xor 	%%rax, %3 \n\t"
						"movq 	%3, %%rax \n\t"
						"movq	%%rax, %1 \n\t"
						"incl 	%0 \n\t"
						"jmp 	5f \n\t"
						"############## if there exists a request_fibers and if it is resumable switch to, otherwise go to label 5 ############ \n\t"
						"5:"
					: "+m" (resp_ready),
					  "=m" (server_local_responses[id_in_chip % CLIENT_PER_RESPONSE].flag),
					  "=m" (server_local_responses[id_in_chip % CLIENT_PER_RESPONSE].return_value),
					  "+m" (*server_local_resp_flags)
					: "m" (chip_req_array[id_in_chip].fptr),
					  "m" (chip_req_array[id_in_chip].flag),
					  "m" (chip_req_array[id_in_chip].argv[5]),
					  "m" (chip_req_array[id_in_chip].argv[4]),
					  "m" (chip_req_array[id_in_chip].argv[3]),
					  "m" (chip_req_array[id_in_chip].argv[2]),
					  "m" (chip_req_array[id_in_chip].argv[1]),
					  "m" (chip_req_array[id_in_chip].argv[0]),
					  "m" (shift_base)
					: "memory", "rax", "rcx", "rdx", "rdi", "rsi", "r8", "r9", "r10", "r11");

	return resp_ready;

}
#else

inline int __attribute__((always_inline)) process_request(uint64_t* server_local_resp_flags, int id_in_chip, struct server_response* server_local_responses, struct request* chip_req_array, struct server_args* this_server, int chip){
	
	int resp_ready = 0;
	this_server->req_fiber_index = (chip * MAX_REQS_PER_CHIP)+id_in_chip;

	// to make it fit uint64_t variable
	uint64_t shift_base = id_in_chip % 64;

	__asm__ __volatile__ ("############## if there is a new request start processing, if not check if any nested resp is ready (label 8) ############ \n\t"
						"############## ((*server_local_resp_flags >> id_in_chip) ^ (chip_req_array[id_in_chip].flag)) & (uint64_t)1 ############\n\t"
						"movq 	%5, %%rax \n\t"
						"movl 	%15, %%ecx \n\t"
						"shr 	%%cl, %%rax \n\t"
						"xor 	%8, %%rax \n\t"
						"test   $0x1,%%al \n\t"
						"je 	8f \n\t"
						"1: \n\t"
						"############## prepare function inputs and call ############ \n\t"
						"movq	%0, %%r10\n\t"
						"movq 	%%rbx, 0x0(%%r10) \n\t"
						"movq 	%%r12, 0x8(%%r10) \n\t"
						"movq 	%%r13, 0x10(%%r10) \n\t"
						"movq 	%%r14, 0x18(%%r10) \n\t"
						"movq 	%%r15, 0x20(%%r10) \n\t"
						"movq 	%%rsp, %1 \n\t"
						"movq 	%9, %%r9 \n\t"
						"movq 	%10, %%r8 \n\t"
						"movq 	%11, %%rcx \n\t"
						"movq 	%12, %%rdx \n\t"
						"movq 	%13, %%rsi \n\t"
						"movq 	%14, %%rdi \n\t"
						"call 	*%7 \n\t"
						"############## update the flag and return value ############ \n\t"
						"movq 	%%rax, %4 \n\t"
						"movq 	$1, %%rax \n\t"
						"movl 	%15, %%ecx \n\t"
						"shl 	%%cl, %%rax \n\t"
						"xor 	%%rax, %5 \n\t"
						"movq 	%5, %%rax \n\t"
						"movq	%%rax, %3 \n\t"
						"incl 	%2 \n\t"
						"jmp 	5f \n\t"
						"############## if there exists a request_fibers and if it is resumable switch to it, otherwise go to label 5 ############ \n\t"
						"8: \n\t"
						"############## load this_server ############ \n\t"
						"movq	%0, %%rax\n\t"
						"############## load this_server->req_fiber_index ############ \n\t"
						"movq 	0x28(%%rax), %%rcx \n\t"
						"############## load this_server->request_fibers[this_server->req_fiber_index] ############ \n\t"
						"mov    0x30(%%rax,%%rcx,8),%%r10 \n\t"
						"mov 	%%r10, %%rcx \n\t"
						"test   %%rcx,%%rcx \n\t"
						"je 	5f \n\t"
						"############## if request_fiber is resumable (state = 1), switch to it ############ \n\t"
						"############## if request_fiber is waiting (state = 2), skip ############ \n\t"
						"cmpq 	$0x1,(%%r10) \n\t"
						"jne 	5f \n\t"
						"############## see if waiting for a lock and if the lock is still available ############ \n\t"
						"movq 	0x8(%%r10), %%r10 \n\t"
						"cmpq 	$0, %%r10 \n\t"
						"je 	4f \n\t"
						"movl	(%%r10), %%eax \n\t"
						"cmpl 	$0, %%eax \n\t"
						"jne 	5f \n\t"
						"4: \n\t"
						"############## switch to the request fiber ############ \n\t"
						"call 	switch_no_maintenance \n\t"
						"############## if parent gets here means the child is done ############ \n\t"
						"############## recycle the child and write the flag and return value ############ \n\t"
						"movq 	%6, %%rax \n\t"
						"movq	%%rax, %4 \n\t"
						"movq 	%5, %%rax \n\t"
						"movq	%%rax, %3 \n\t"
						"movq 	%4, %%rdi \n\t"
						"call 	recycle_child \n\t"
						"jmp 7f \n\t"
						"3: \n\t"
						"1: \n" 
						"############## Instantiate label 3. This will put the address of the code block in my_jump_table ############ \n\t"
						".pushsection my_jump_table,\"a\"\n" 
						".align 8\n" 
						".quad 1b-server_func\n" 
						".popsection \n\t" 
						"############## if child gets here - means func is done ############ \n\t"
						"############## save return value to thread local, switch to parent ############ \n\t"
						"movq 	%%rax, %6 \n\t"
						"call 	switch_no_maintenance \n\t"
						"1: \n" 
						"############## Instantiate label 6. This will put the address of the code block in my_jump_table ############ \n\t"
						".pushsection my_jump_table,\"a\"\n" 
						".align 8\n" 
						".quad 1b-server_func\n" 
						".popsection \n\t" 
						"6: \n\t"
						"movq	%0, %%r10\n\t"
						"movq 	0x0(%%r10), %%rbx \n\t"
						"movq 	0x8(%%r10), %%r12 \n\t"
						"movq 	0x10(%%r10), %%r13 \n\t"
						"movq 	0x18(%%r10), %%r14 \n\t"
						"movq 	0x20(%%r10), %%r15 \n\t"
						"############## parent returns form yield : only change the server's local flags (server_local_resp_flags) ############ \n\t"
						"############## this way, it seems that the request has been processed until it becomes resummable ############ \n\t"
						"movq 	$1, %%rax \n\t"
						"movl 	%15, %%ecx \n\t"
						"shl 	%%cl, %%rax \n\t"
						"xor 	%%rax, %5 \n\t"
						"jmp 5f \n\t"
						"7: \n\t"
						"incl 	%2\n\t"
						"jmp 5f \n\t"
						"1: \n" 
						"############## Instantiate label 5. This will put the address of the code block in my_jump_table ############ \n\t"
						".pushsection my_jump_table,\"a\"\n" 
						".align 8\n" 
						".quad 1b-server_func\n" 
						".popsection \n\t" 
						"5:"
					: "+m" (this_server),
					  "=m" (rsp_before_del_call),
					  "+m" (resp_ready),
					  "=m" (server_local_responses[id_in_chip % CLIENT_PER_RESPONSE].flag),
					  "=m" (server_local_responses[id_in_chip % CLIENT_PER_RESPONSE].return_value),
					  "+m" (*server_local_resp_flags),
					  "+m" (child_ret_value)
					: "m" (chip_req_array[id_in_chip].fptr),
					  "m" (chip_req_array[id_in_chip].flag),
					  "m" (chip_req_array[id_in_chip].argv[5]),
					  "m" (chip_req_array[id_in_chip].argv[4]),
					  "m" (chip_req_array[id_in_chip].argv[3]),
					  "m" (chip_req_array[id_in_chip].argv[2]),
					  "m" (chip_req_array[id_in_chip].argv[1]),
					  "m" (chip_req_array[id_in_chip].argv[0]),
					  "m" (shift_base)
					: "memory", "rax", "rcx", "rdx", "rdi", "rsi", "r8", "r9", "r10", "r11");

	return resp_ready;

}
#endif

inline void __attribute__((always_inline)) process_requests_batch(uint64_t* server_local_resp_flags, struct server_response* server_local_responses, struct request* chip_req_array, int first, int last, int resp_group, int chip, struct server_args* this_server){
		int j;
		int resp_ready = 0;
		for (j=first; j<=last; j++){

			/*			if ((j + chip* MAX_REQS_PER_CHIP) >= num_of_req_lines_to_check){
				__asm__ __volatile__ ("jmp 12f":::);
			}
			*/

			resp_ready += process_request(server_local_resp_flags, j, &server_local_responses[resp_group*CLIENT_PER_RESPONSE], chip_req_array, this_server, chip);
		}

#if defined(ADAPTIVE_SKIP_POLL) || defined(SERVER_CONTROLLED_DOORBELL) || defined(PROFILE_SERVER_POLL_LATENCY) || defined(PROFILE_SERVER_POLL) 
                this_server->resp_ready += resp_ready;
#endif
		if(resp_ready){
			copy_to_client_resp((__m128i*)this_server->server_response_group->server_response_groups[resp_group+((RESP_GROUP_PER_SOCK)*chip)], (__m128i*)&(server_local_responses[CLIENT_PER_RESPONSE*resp_group]));
		}

		/*		__asm__ __volatile__ (	"jmp 11f \n\t"
								"12:":::"memory");
		if(resp_ready){
			copy_to_client_resp((__m128i*)this_server->server_response_group->server_response_groups[resp_group+((RESP_GROUP_PER_SOCK)*chip)], (__m128i*)&(server_local_responses[CLIENT_PER_RESPONSE*resp_group]));
		}
		__asm__ __volatile__ (	"jmp 13f \n\t"
								"11:":::"memory");
		*/
		if ((last + chip* MAX_REQS_PER_CHIP) >= num_of_req_lines_to_check){
                	__asm__ __volatile__ ("jmp skip_the_rest_of_socks \n\t"
						:::"memory");
                }
}

inline void __attribute__((always_inline)) per_chip_process(uint64_t* server_local_resp_flags, struct server_args* this_server, struct server_response* server_local_responses, struct request* chip_req_array, int chip)
{
		forloop(`r', `0', RESP_GROUP_PER_SOCK-1, `process_requests_batch(&server_local_resp_flags[eval( eval((r*CLIENT_PER_RESPONSE))/eval((64/CLIENT_PER_RESPONSE)*CLIENT_PER_RESPONSE))], server_local_responses, chip_req_array, eval((r*CLIENT_PER_RESPONSE)), FINISH((((r+1)*CLIENT_PER_RESPONSE))-1), r, chip, this_server);
		')
		//'

		// if got here from "jmp 9f", then skip checking the rest of sockets, otherwise return to check the rest
		__asm__ __volatile__ (	"jmp 10f \n\t"
								"13: \n\t"
							 	"jmp skip_the_rest_of_socks \n\t"
							 	"10:" :::"memory");

}

#ifdef SKIP_POLL
inline int __attribute__((always_inline)) inner_poll(){
	this_server->skip_poll++;
	if(this_server->skip_poll % 4 == 0)
		return 1;
	else return 0;
}
#elif ADAPTIVE_SKIP_POLL
inline int __attribute__((always_inline)) inner_poll(){
	this_server->skip_poll++;
	if(this_server->skip_poll_size <= 0) return 1;
	if(this_server->skip_poll % this_server->skip_poll_size == 0)
		return 1;
	else return 0;
}
#elif NT_STORE
inline int __attribute__((always_inline)) inner_poll(){
	__m128i new_doorbell = doorbell[this_server->server_core];
	//__m128i new_doorbell = _mm_load_si128(&doorbell[this_server->server_core]);
	__m128i neq = _mm_xor_si128(new_doorbell, this_server->old_doorbell);
	if( !_mm_testz_si128(neq, neq)){
		//old_doorbell[i] = _mm_cvtsi128_si128(new_doorbell);
		this_server->old_doorbell = new_doorbell;
		this_server->counter = 0;
		return 1;	
	}
	else {
	  	this_server->counter++;
		return 0;
	}
}
#elif SERVER_CONTROLLED_DOORBELL
inline int __attribute__((always_inline)) inner_poll(){
	if (this_server->old_doorbell == 1)
		return 1;
	if (doorbell[this_server->server_core] == 0){
		return 0;
	}
	if (doorbell[this_server->server_core] == 1){
		this_server->old_doorbell = 1;
		return 1; 
	}

}
#else 
inline int __attribute__((always_inline)) inner_poll(){
	return 1;
}
#endif

inline void __attribute__((always_inline)) server_inner_poll(){

	int mycoreid = thread_attrs[this_server->server_core]->coreid_in_chip;
	int shift_base = (mycoreid * REQS_LINES_PER_THREAD) % 64;
	uint64_t start, end, loop_duration; 
	unsigned int ui;
	double old_m_i;

#ifdef PROFILE_SERVER_POLL_LATENCY
	//Take start time
	start = __rdtscp(&ui);
	//start = __rdtsc();
#endif
	forloop(`chip', `0', MAX_SOCK-1, `
	per_chip_process(this_server->`server_local_resp_flags'[chip], this_server, this_server->server_local_responses[chip], this_server->`chip'chip, chip);

	')
	//'

	__asm__ __volatile__ ("skip_the_rest_of_socks:");

#ifdef PROFILE_SERVER_POLL
        this_server->poll_size[this_server->resp_ready]++;
        this_server->tot_polls++;
	this_server->resp_ready = 0;
#endif

#ifdef PROFILE_SERVER_POLL_LATENCY
	//Take end time 
	end = __rdtscp(&ui);
	//end = __rdtsc();
	
	//Don't consider empty loops
	if(this_server->resp_ready != 0){
		this_server->tot_polls++;
		this_server->tot_requests += this_server->resp_ready;
		loop_duration = end - start;
		old_m_i = this_server->m_i;

		if (this_server->current_window < SAMPLING_SIZE + SAMPLING_OFFSET){	
			if ( this_server->tot_polls % SAMPLING_INTERVAL == 0 ){
				this_server->CPU_perc[this_server->current_window % (SAMPLING_SIZE+SAMPLING_OFFSET)] = this_server->current_CPU_perc / ((double)10000.0);
				this_server->current_CPU_perc = 0.0;
				this_server->current_window++;
			}
			double CPU_perc = 1.0 - (500.0 / ((double)loop_duration));
			this_server->current_CPU_perc += (CPU_perc > 0.0) ? CPU_perc : 0.0; 
		}
		/*
		if (this_server->current_window == (SAMPLING_SIZE+SAMPLING_OFFSET)){
			printf("[%d] ERROR - window exceeded\n", this_server->server_core);
			this_server->current_window++;
		}
		*/
		if(this_server->tot_polls == 1){
			this_server->m_i = loop_duration;
			this_server->mean_requests_per_loop = this_server->resp_ready;
		}
		else {
			this_server->mean_requests_per_loop += ((this_server->resp_ready - this_server->mean_requests_per_loop) / this_server->tot_polls);
			this_server->m_i = old_m_i + ((loop_duration - old_m_i) / this_server->tot_polls);
			this_server->s_i = this_server->s_i + (loop_duration - old_m_i) * (loop_duration - this_server->m_i);
		}
		this_server->resp_ready = 0;
	}
#endif
       
#ifdef ADAPTIVE_SKIP_POLL
	if (this_server->resp_ready == 0 && this_server->skip_poll_size <= 4)
		this_server->skip_poll_size++;
	else if (this_server->resp_ready > 8 && this_server->skip_poll_size > 0)
		this_server->skip_poll_size-=2;
	this_server->resp_ready = 0;
#elif SERVER_CONTROLLED_DOORBELL
	if (this_server->resp_ready == 0)
		this_server->old_doorbell = 0;
#endif
	
	if (this_server->any_server_fiber_waiting > 0){
		poll_server_resp(this_server, this_server->manager, shift_base);
	}

	__asm__ __volatile__ ("sfence" ::: "memory");


}

void* server_func(void* input){

	uint64_t rsp, rbp; 
	__asm__ __volatile__ ("movq %%rsp, %0" : "=m" (rsp):: "memory");
	__asm__ __volatile__ ("movq %%rbp, %0" : "=m" (rbp):: "memory");

	this_server = (struct server_args*) input;
	struct server_args* local_server_arg = this_server;

#ifdef PTHREAD
	// pin the server thread
	pin_the_thread(this_server->server_core);
#else
	this_server->manager = fiber_manager_get();
	fiber_manager_get()->this_server = this_server;
	main_server_fiber = fiber_manager_get()->current_fiber;
#endif

	int local_num_of_server_launched = num_of_server_launched;
	int i, k, j = 0;

	// ************* each instance of the inline function "process_request()" needs its own set of labels
	// ************* here we are using a linker trick (found here: https://gist.github.com/gby/3847477) to store the addresses of the labels in the inline function
	void ** labels_jmp_table;
	// Start a new block in the jump table
	start_here(labels_jmp_table);
	int label_number = 0;

	labels_jmp_table = (void**)((uint64_t)labels_jmp_table+ (uint64_t)server_func);
	uint64_t ret_addrs[MAX_SOCK*MAX_REQS_PER_CHIP][3];

	//initialize the label addresses in the jump table
	for (i=0; i<MAX_SOCK; i++){
		for (j=0; j<MAX_REQS_PER_CHIP; j++){
			this_server->ret_addrs[(i * MAX_REQS_PER_CHIP)+j][0] = (uint64_t)labels_jmp_table[label_number+1] + (uint64_t)server_func; //label 6
	 		this_server->ret_addrs[(i * MAX_REQS_PER_CHIP)+j][1] = (uint64_t)labels_jmp_table[label_number] + (uint64_t)server_func; //label 3
	 		this_server->ret_addrs[(i * MAX_REQS_PER_CHIP)+j][2] = (uint64_t)labels_jmp_table[label_number+2] + (uint64_t)server_func; //label 5

	 		//all the requests in one resp_group see the same label address, but for the next resp group update the labels
	 		if ((j+1) % CLIENT_PER_RESPONSE == 0){
	 			label_number+=3;
	 		}
		}
	}

#ifdef DEBUG_STRUCTS	
	printf("Server fiber: [is_server: %d, my_id: %d, id_in_chip: %d, id: %ld]\n", main_server_fiber->is_server, main_server_fiber->my_id, main_server_fiber->id_in_chip, main_server_fiber->id);
	printf("Server args: [current_id_in_chip: %d, server_numa_node: %d, server_core: %d]\n", this_server->current_id_in_chip, this_server->server_numa_node, this_server->server_core);
#endif
	
	// main server loop
	int scan_nr = 1;
	while(*this_server->finished != 1){
	        if ( inner_poll() != 0 )
			server_inner_poll();

#ifdef DEBUG_YIELD 		
		if(this_server->server_core == 0){
	//		printf("[%d] server yielding\n", test);
			test++;
		}
#endif

		//Yield the CPU - we should check if there are clients running on the same core before, otherwise useless overhead
		SERVER_SCAN
		

#ifdef DEBUG_YIELD
		if(this_server->server_core == 0){
	//		printf("[%d] server resuming\n", test);
			test++;
		}
#endif
	}

	return 0;
}

void* ffwd_client_start(void* param) {
	struct ffwd_context *context = param;

#ifdef PTHREAD
	pin_the_thread(context->id);
#endif
	void* retval = context->initfunc(context->initvalue);

	return retval;
}

// This function creates fibers starting from the first available client core and continues filling sockets in order
fiber_t* ffwd_thread_create(void *(* func) (void *), void* value){
	struct ffwd_context *context = malloc(sizeof(struct ffwd_context)); 
	context->initfunc = func;
	context->initvalue = value;
#ifdef PTHREAD
	pthread_t* thread = malloc(sizeof(pthread_t*));
	do{
    	id_tracker = (id_tracker+1) % (TOTAL_NUM_OF_THREADS);
    }while(thread_attrs[all_threads[id_tracker]]->is_server == 1);
	context->id = all_threads[id_tracker];
	pthread_create(thread, 0, &ffwd_client_start, (void*)(context));
#else
	fiber_t* thread;
	thread = fiber_create(4096, &ffwd_client_start, context);
#ifdef DEBUG_STRUCTS
	printf("STD Client fiber: [is_server: %d, my_id: %d, core: %d, id: %ld]\n", thread->is_server, thread->my_id, ((fiber_manager_t*)thread->my_manager)->core_id, thread->id);
#endif

#endif

	return thread;
}

// use this function if you want to specify which core you need the fiber on
fiber_t* ffwd_thread_create_and_pin(void *(* func) (void *), void* value, int core_id){
	struct ffwd_context *context = malloc(sizeof(struct ffwd_context)); 
	context->initfunc = func;
	context->initvalue = value;
#ifdef PTHREAD
	pthread_t* thread = malloc(sizeof(pthread_t*));
	context->id = core_id;
	pthread_create(thread, 0, &ffwd_client_start, (void*)(context));
#else
	fiber_t* thread;
	thread = fiber_create_and_pin(4096, &ffwd_client_start, context, 0, core_id);
#ifdef DEBUG_STRUCTS
	printf("Client-Server fiber: [is_server: %d, my_id: %d, core: %d, id: %ld]\n", thread->is_server, thread->my_id, ((fiber_manager_t*)thread->my_manager)->core_id, thread->id);
#endif

#endif

	return thread;
}

void ffwd_shutdown() {

	int i;
	for (i=0; i< num_of_server_launched; i++){
		finished[i * 128] = 1;
	}
	
#ifndef PTHREAD
	servers_join();
#endif

#ifdef PROFILE_SERVER_POLL
	uint64_t poll_size_accumulator[MAX_NUM_OF_REQUESTS] = {0};
        uint64_t tot_polls_accumulator = 0;
#endif

#ifdef PROFILE_SERVER_POLL_LATENCY
	uint64_t tot_requests_accumulator = 0;
	for (i=0; i<num_of_server_launched; i++){
		tot_requests_accumulator += server_arg[i]->tot_requests;
	}
#endif

	for (i=0; i<num_of_server_launched; i++){
		forloop(`chip', `0', MAX_SOCK-1, 
		`numa_free(`chip'chip[i], REQ_MEMORY_SIZE_ALIGNED);
		')

#ifdef PROFILE_SERVER_POLL
                int j;
                for (j=0; j<MAX_NUM_OF_REQUESTS; j++){
                        //if(server_arg[i]->poll_size[j] != 0)
			//printf("%d %.3f\n", j, ((double)server_arg[i]->poll_size[j]) / ((double)server_arg[i]->tot_polls));
			poll_size_accumulator[j] += server_arg[i]->poll_size[j];
		}
		tot_polls_accumulator += server_arg[i]->tot_polls;		
#endif

#ifdef PROFILE_SERVER_POLL_LATENCY
		double variance = server_arg[i]->s_i / (server_arg[i]->tot_polls - 1);
		printf("[server] %i %.3f %.3f %.3f %.3f %.3f %.3f %ld ",
			       	i,
			       	server_arg[i]->m_i,
			       	variance,
			       	sqrt(variance),
			       	((double) server_arg[i]->tot_requests / (double) tot_requests_accumulator),
			       	server_arg[i]->m_i / server_arg[i]->mean_requests_per_loop,
			       	server_arg[i]->mean_requests_per_loop,
			       	server_arg[i]->tot_requests);

		for (int j=0; j<(SAMPLING_SIZE+SAMPLING_OFFSET); j++){
			printf("%.3f ", server_arg[i]->CPU_perc[j]);
		}
		printf("\n");
#endif

#ifdef PROFILE_SCHEDULER_QUEUE_LEN
 		fiber_scheduler_dist_t* scheduler = (fiber_scheduler_dist_t*)(((fiber_manager_t*)(server_arg[i]->manager))->scheduler);
		printf("[server] %i %.3f %.3f\n", i, scheduler->avg_queue1_length, scheduler->avg_queue2_length);
#endif
		numa_free(server_response_group_set[i], sizeof(struct server_set));
		numa_free(server_arg[i], sizeof(struct server_args));
	}

#ifdef PROFILE_SERVER_POLL
                int j;
                for (j=0; j<MAX_NUM_OF_REQUESTS; j++){
                   	printf("[%d] %.3f\n", j, ((double)poll_size_accumulator[j]) / ((double)tot_polls_accumulator));
		}		
#endif

}

void * numa_alloc_onnode_with_memset(int size, int node){
	void * m = numa_alloc_onnode(size, node);
	memset(m, 0, size);
	return m;
}

void ffwd_init() {
	
	int i, j;
	if(numa_available() < 0){
		printf("System does not support NUMA API!\n");
		exit(1);
	}
	register_ffwd_callback(ffwd_poll_resp);
	num_of_req_lines_to_check = num_of_hwth_to_check*REQS_LINES_PER_THREAD;

	int coreid_in_chip, thread_id;

	// the index in thread_attrs[] is the actual core id
	for (i = 0; i < TOTAL_NUM_OF_THREADS+1; i++){
		
		// for the main thread, in case we need it
		if (i==TOTAL_NUM_OF_THREADS){
			thread_id = TOTAL_NUM_OF_THREADS;
			thread_attrs[thread_id] = (struct thread_attr *) numa_alloc_onnode_with_memset(sizeof(struct thread_attr), 0);
		}
		else{
			thread_id = all_threads[i];
			thread_attrs[thread_id] = (struct thread_attr *) numa_alloc_onnode_with_memset(sizeof(struct thread_attr), (i/MAX_THREADS_PER_SOCK));
		}

		// assign hyperthreads ids next to each other
		thread_attrs[thread_id]->coreid_in_chip = i % MAX_THREADS_PER_SOCK;
		thread_attrs[thread_id]->chip_num = (i/MAX_THREADS_PER_SOCK);
		thread_attrs[thread_id]->is_server = 0;

		for (j=0; j < MAX_REQUEST_LINE_PER_CORE; j++){
			thread_attrs[thread_id]->is_locked[j] = 0;
		}

		for (j=0; j < MAX_REQUEST_LINE_PER_CORE; j++){
			thread_attrs[thread_id]->local_client_flag[j] = 0;
		}
	}
}

fiber_t* launch_server_and_pin(int server_core){
	int i, k, j;
	int server_numa_node;
	server_numa_node = thread_attrs[server_core]->chip_num;
	thread_attrs[server_core]->is_server = 1;

	server_response_group_set[num_of_server_launched] = (struct server_set*)numa_alloc_onnode_with_memset(sizeof(struct server_set), server_numa_node);
	for (i = 0; i < eval(MAX_SOCK * RESP_GROUP_PER_SOCK); i++){ 
		(server_response_group_set[num_of_server_launched]->server_response_groups[i]) = (struct server_response_group*)numa_alloc_onnode_with_memset(sizeof(struct server_response_group), server_numa_node);
		for (k=0; k < CLIENT_PER_RESPONSE; k++){
			server_response_group_set[num_of_server_launched]->server_response_groups[i]->responses[k].flag = 0;
		}
	}

	forloop(`chip', `0', MAX_SOCK-1, 
	``chip'chip[num_of_server_launched] = (struct request*)numa_alloc_onnode_with_memset(REQ_MEMORY_SIZE_ALIGNED, chip);
	memset(`chip'chip[num_of_server_launched], 0, REQ_MEMORY_SIZE_ALIGNED);
	')
	//'

	forloop(`chip', `0', MAX_SOCK-1, 
	`mprotect((void*)`chip'chip[num_of_server_launched], REQ_MEMORY_SIZE_ALIGNED, PROT_EXEC | PROT_READ | PROT_WRITE);
	')

	//prepare server's input arguments
	server_arg[num_of_server_launched] = (struct server_args*) numa_alloc_onnode_with_memset(sizeof(struct server_args), server_numa_node);
	server_arg[num_of_server_launched]->server_core = server_core;
	server_arg[num_of_server_launched]->server_numa_node = server_numa_node;
	server_arg[num_of_server_launched]->server_local_resp_flags = numa_alloc_onnode_with_memset(MAX_SOCK*sizeof(uint64_t*), server_numa_node);
	server_arg[num_of_server_launched]->server_local_responses = numa_alloc_onnode_with_memset(MAX_SOCK*sizeof(struct server_response *), server_numa_node);


	forloop(`chip', `0', MAX_SOCK-1, 
	`server_arg[num_of_server_launched]->server_local_resp_flags[chip] = numa_alloc_onnode_with_memset((eval((REQS_LINES_PER_THREAD * MAX_THREADS_PER_SOCK)/64 + eval((REQS_LINES_PER_THREAD * MAX_THREADS_PER_SOCK)%64>0)))*sizeof(uint64_t), server_numa_node);
	server_arg[num_of_server_launched]->server_local_responses[chip] = numa_alloc_onnode_with_memset(CLIENT_PER_RESPONSE*RESP_GROUP_PER_SOCK*sizeof(struct server_response), server_numa_node);
	server_arg[num_of_server_launched]->`chip'chip = `chip'chip[num_of_server_launched];
	')
	//'

	server_arg[num_of_server_launched]->server_response_group = server_response_group_set[num_of_server_launched];

	int my_chip;
	for (i = 0; i < TOTAL_NUM_OF_THREADS+1; i++){

		my_chip = thread_attrs[i]->chip_num;

		switch(my_chip){
			forloop(`chip', `0', MAX_SOCK-1, 
			`case chip:
					for (j=0; j < REQS_LINES_PER_THREAD; j++){
						thread_attrs[i]->request[num_of_server_launched * REQS_LINES_PER_THREAD + j] = &(`chip'chip[num_of_server_launched][(thread_attrs[i]->coreid_in_chip) * REQS_LINES_PER_THREAD + j]);
					}
			break;
			')
		}

		for (j=0; j < REQS_LINES_PER_THREAD; j++){
			thread_attrs[i]->core_resp[num_of_server_launched * REQS_LINES_PER_THREAD + j] = &(server_response_group_set[num_of_server_launched]->server_response_groups[(my_chip * RESP_GROUP_PER_SOCK) + ((thread_attrs[i]->coreid_in_chip)/ eval( (MAX_REQS_PER_CHIP/(RESP_GROUP_PER_SOCK*REQS_LINES_PER_THREAD)) + eval( eval((MAX_REQS_PER_CHIP%(RESP_GROUP_PER_SOCK*REQS_LINES_PER_THREAD))>0)) ))]->responses[((thread_attrs[i]->coreid_in_chip) % (eval( (MAX_REQS_PER_CHIP/(RESP_GROUP_PER_SOCK*REQS_LINES_PER_THREAD)) + eval( eval((MAX_REQS_PER_CHIP%(RESP_GROUP_PER_SOCK*REQS_LINES_PER_THREAD))>0)) ))) * REQS_LINES_PER_THREAD + j]);
		}
	}

	server_arg[num_of_server_launched]->finished = &finished[num_of_server_launched * 128];
	server_arg[num_of_server_launched]->any_server_fiber_waiting = 0;

	for (i=0; i < MAX_NUM_OF_REQUESTS; i++){
		server_arg[num_of_server_launched]->request_fibers[i] = 0;
        #ifdef PROFILE_SERVER_POLL
                server_arg[num_of_server_launched]->poll_size[i] = 0;
        #endif
	}

#ifdef PROFILE_SERVER_POLL      
        server_arg[num_of_server_launched]->tot_polls = 0;
	server_arg[num_of_server_launched]->resp_ready = 0;
        //printf("max_num_of_requests = %d\n", MAX_NUM_OF_REQUESTS);
#endif

#ifdef PROFILE_SERVER_POLL_LATENCY
	server_arg[num_of_server_launched]->tot_polls = 0;
	server_arg[num_of_server_launched]->mean_requests_per_loop = 0;
	server_arg[num_of_server_launched]->tot_requests = 0;
	server_arg[num_of_server_launched]->m_i = 0;
	server_arg[num_of_server_launched]->s_i = 0;

	server_arg[num_of_server_launched]->current_CPU_perc = 0.0;
	server_arg[num_of_server_launched]->current_window = 0;
	server_arg[num_of_server_launched]->initial_polls = 0;
	for (int j=0; j<(SAMPLING_SIZE+SAMPLING_OFFSET); j++){
		server_arg[num_of_server_launched]->CPU_perc[j] = 0.0;
	}
#endif

	server_arg[num_of_server_launched]->skip_poll = 0;
	server_arg[num_of_server_launched]->skip_poll_size = 4;

#ifdef PTHREAD
	pthread_t* thread = malloc(sizeof(pthread_t*));
	pthread_create(thread, 0, &server_func, (void*)(server_arg[num_of_server_launched]));
#else
	fiber_t* thread = server_create(4096*4, &server_func, (void*) (server_arg[num_of_server_launched]), server_core);
	thread->my_id = -server_arg[num_of_server_launched]->server_core;
#endif


	//printf("Server fiber: [is_server: %d, my_id: %d, id_in_chip: %d, id: %ld]\n", thread->is_server, thread->my_id, thread->id_in_chip, thread->id);
	//printf("Server args: [current_id_in_chip: %d, server_numa_node: %d, server_core: %d]\n", server_arg[num_of_server_launched]->current_id_in_chip, server_arg[num_of_server_launched]->server_numa_node, server_arg[num_of_server_launched]->server_core);
	num_of_server_launched++;

	return thread;

}

void launch_servers(int num_of_servers){
	int i, s, k, j;
	int server_core, server_numa_node;

	for (s = 0; s < num_of_servers; s++){
		// start pinning servers on the first hyperthreads on each chip, then move to second hyperthreads
		server_core = all_threads[(s*MAX_THREADS_PER_SOCK) % TOTAL_NUM_OF_THREADS + ((s/MAX_SOCK)*2) % MAX_THREADS_PER_SOCK + (s/(TOTAL_NUM_OF_THREADS/2))];
		launch_server_and_pin(server_core);
	}

	
}

int launch_server_flat_delegation(){
	int server_core, index;
	
	index = (num_of_server_launched < 27) ? num_of_server_launched : num_of_server_launched + 1;
	
	//server_core = all_threads[num_of_server_launched % MAX_THREADS_PER_SOCK + (num_of_server_launched/(TOTAL_NUM_OF_THREADS/2))];
	
	server_core = all_threads[index];
        
	// start pinning servers on the first hyperthreads on each chip, then move to second hyperthreads
	//server_core = all_threads[(num_of_server_launched*MAX_THREADS_PER_SOCK) % TOTAL_NUM_OF_THREADS + ((num_of_server_launched/MAX_SOCK)*2) % MAX_THREADS_PER_SOCK + (num_of_server_launched/(TOTAL_NUM_OF_THREADS/2))];
	

	launch_server_and_pin(server_core);

	// Use this number for pinning the instrumented client fibers	
	return server_core;	
}

