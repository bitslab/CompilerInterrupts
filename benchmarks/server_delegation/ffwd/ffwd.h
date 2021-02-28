#ifndef _FFWD_H_
#define _FFWD_H_

#include <numa.h>
#include <pthread.h>
#include <stdarg.h>
#include <immintrin.h>
#include <x86intrin.h>
#include <locale.h>

#include "fiber_manager.h"
#include "fiber_barrier.h"

#ifdef DEBUG_YIELD
extern __thread int test;
#endif 

extern __thread struct server_args* this_server;
extern __thread fiber_t* main_server_fiber;
extern volatile int num_of_req_lines_to_check;
extern volatile int num_of_hwth_to_check;
#ifdef PTHREAD
	extern __thread int my_id;
	int clients_count;
#endif

typedef struct locks{
	int is_locked;
	int waiters_count;
	spsc_fifo_t *lock;
}serverlocks;

struct ffwd_context {
	int id;
	void *(* initfunc)(void*);
	void *initvalue;
};

struct thread_attr{
	uint64_t mask[REQS_LINES_PER_THREAD];
	int is_locked[REQS_LINES_PER_THREAD * MAX_SERVERS];
	int coreid_in_chip;
	int chip_num;
	int is_server;
	struct request* request[MAX_SERVERS * REQS_LINES_PER_THREAD];
	uint64_t server_last_request_time[MAX_SERVERS];
	volatile struct server_response_group* server_response_group[MAX_SERVERS * REQS_LINES_PER_THREAD];
	fiber_t* resp_waiting_fibers[REQS_LINES_PER_THREAD * MAX_SERVERS];
	uint64_t local_client_flag[REQS_LINES_PER_THREAD * MAX_SERVERS];
	struct server_response* core_resp[REQS_LINES_PER_THREAD * MAX_SERVERS];
}__attribute__((packed, aligned(128)));

extern struct thread_attr *thread_attrs[TOTAL_NUM_OF_THREADS+1];

// here should also check if there is a child fiber, if so no need to fork
#define FFWD_LOCK(the_lock) \
	if ((the_lock.is_locked)){ \
		fiber_t* child_fiber = server_fiber_fork(); \
		if (child_fiber != 0) { \
			/* parent should add the fiber to request_fibers and set the request_fibers' state to waiting*/ \
			fiber_t* current_fiber = ((fiber_manager_t*)(this_server->manager))->current_fiber; \
			current_fiber->request_state = FIBER_CHILD_WAITING; \
			current_fiber->lock_ptr = (uint64_t)&the_lock; \
			mpsc_fifo_node_t* const fiber_node = current_fiber->mpsc_fifo_node; \
			current_fiber->mpsc_fifo_node = NULL; \
			fiber_node->data = current_fiber; \
			spsc_fifo_push((the_lock.lock), (spsc_node_t*)fiber_node); \
			the_lock.waiters_count++; \
			this_server->request_fibers[this_server->req_fiber_index] = current_fiber; \
			main_server_fiber = child_fiber; \
			/* parent stays here and the child will continue running server loop*/ \
			switch_no_maintenance(); \
			/* if it gets here, it means the lock was available*/ \
			the_lock.is_locked = 1; \
			((fiber_manager_t*)(this_server->manager))->current_fiber->lock_ptr = 0; \
		} \
		the_lock.waiters_count--; \
	} \
	the_lock.is_locked = 1; 


#define FFWD_UNLOCK(the_lock) \
	/*unlock and wake the next one waiting on the lock*/ \
	if (the_lock.waiters_count > 0 ){ \
		spsc_node_t* waiting_node = spsc_fifo_trypop((the_lock.lock));\
		if (waiting_node){ \
			fiber_t* next_to_wakeup = (fiber_t*)waiting_node->data; \
			next_to_wakeup->mpsc_fifo_node = waiting_node; \
			next_to_wakeup->request_state = FIBER_REQUEST_RESUMABLE; \
		} \
	} \
	the_lock.is_locked = 0;

inline void push_and_wait_for_server_req_lock(fiber_manager_t* manager, fiber_t* fiber_to_push, int server_no){

	fiber_scheduler_t* scheduler = manager->scheduler;
	mpsc_fifo_node_t* const node = fiber_to_push->mpsc_fifo_node;
	assert(node);
	fiber_to_push->mpsc_fifo_node = 0;
	node->data = fiber_to_push;
	spsc_fifo_push(&(((fiber_scheduler_dist_t*)scheduler)->req_lock_queue[server_no]), (spsc_node_t*)node);	
}

#define SERVER_FFWD_EXEC(server_num, function, ret, ...) \
 	/*if there is no request fiber created for this client, fork a request fiber, else use the existing one */ \
 	if(((fiber_manager_t*)(this_server->manager))->current_fiber == main_server_fiber){ \
	 	fiber_t* child_fiber = server_fiber_fork(); \
	 	/* parent's return value is a pointer to the child fiber, child's retrn value is null*/ \
		if (child_fiber != 0) { \
			fiber_t* current_fiber = ((fiber_manager_t*)(this_server->manager))->current_fiber; \
			struct request* req = &current_fiber->my_request; \
			req->fptr = function; \
			prepare_request_argvs(req, __VA_ARGS__); \
			current_fiber->request_state = FIBER_CHILD_WAITING; \
			current_fiber->id_in_chip = this_server->current_id_in_chip; \
			push_and_wait_for_server_req_lock(((fiber_manager_t*)(this_server->manager)), current_fiber, server_num); \
			this_server->request_fibers[this_server->req_fiber_index] = current_fiber; \
			this_server->any_server_fiber_waiting++; \
			main_server_fiber = child_fiber; \
			switch_no_maintenance(); \
		} \
	} \
	else{ \
		fiber_t* current_fiber = ((fiber_manager_t*)(this_server->manager))->current_fiber; \
		struct request* req = &current_fiber->my_request; \
		req->fptr = function; \
		prepare_request_argvs(req, __VA_ARGS__); \
		current_fiber->request_state = FIBER_CHILD_WAITING; \
		current_fiber->id_in_chip = this_server->current_id_in_chip; \
		push_and_wait_for_server_req_lock(((fiber_manager_t*)(this_server->manager)), current_fiber, server_num); \
		this_server->request_fibers[this_server->req_fiber_index] = current_fiber; \
		this_server->any_server_fiber_waiting++; \
		this_server->still_need_to_wait = 1; \
		switch_no_maintenance(); \
	} \
	ret = ((fiber_manager_t*)(this_server->manager))->current_fiber->response_retval; \
	this_server->any_server_fiber_waiting--; \
	/*change return address to be label 3*/ \
	/*find the first rbp after call and change it*/

#define GET_ARGS(num_args, ...) __VA_ARGS__


#ifdef PTHREAD
	#define FFWD_EXEC(server_num, function, ret, ...) \
		{ \
			struct thread_attr * my_thread = thread_attrs[my_id]; \
			my_thread->request[server_num]->fptr = function; \
			prepare_request_argvs(my_thread->request[server_num], __VA_ARGS__); \
			my_thread->request[server_num]->flag ^= 1; \
			uint64_t local_flag = my_thread->request[server_num]->flag;\
			int mycoreid = my_thread->coreid_in_chip;\
			int shift_base = (mycoreid * REQS_LINES_PER_THREAD)%64;\
			while((( (my_thread->core_resp[server_num]->flag >> (shift_base + (server_num%REQS_LINES_PER_THREAD))) ^ (my_thread->request[server_num]->flag)) & ((uint64_t)1 ) )){ \
				__asm__ __volatile__ ("rep:nop;" ::: "memory");\
			}\
			ret = my_thread->core_resp[server_num]->return_value;\
		}
#else
	// call FFWD_EXEC for both nested and non nested delegation
	#define FFWD_EXEC(server_num, function, ret, ...) \
		{ \
			fiber_manager_t* manager = fiber_manager_get(); \
			/* if a server is calling FFWD_EXEC and it is a nested call (server_num != manager->server_id), then call SERVER_FFWD_EXEC otherwise just call the function */ \
			if (manager->is_server && server_num == manager->server_id){ \
				if (server_num == manager->server_id){\
					function(GET_ARGS(__VA_ARGS__)); \
				}\
				else{ \
					SERVER_FFWD_EXEC(server_num, function, ret, __VA_ARGS__) \
				} \
			} \
			else{ \
				struct request* ffwd_req; \
				fiber_t* const myself = manager->current_fiber; \
				ffwd_req = &myself->my_request; \
				ffwd_req->fptr = function; \
				prepare_request_argvs(ffwd_req, __VA_ARGS__); \
				fiber_push_and_wait_for_req_lock(server_num); \
				ret = myself->response_retval;\
			} \
		}
#endif



extern inline void prepare_request_argvs(struct request* myrequest, int arg_count, ...);
void ffwd_init();
void launch_servers(int);
int launch_server_flat_delegation();
void ffwd_shutdown();
struct ffwd_context* ffwd_get_context();
fiber_t* ffwd_poll_resp(fiber_manager_t* manager, fiber_scheduler_t* sched);
fiber_t* ffwd_thread_create(void *(* func) (void *), void* value);
fiber_t* ffwd_thread_create_and_pin(void *(* func) (void *), void* value, int core_id);
void switch_no_maintenance();
void poll_server_resp(struct server_args* this_server, fiber_manager_t* manager, int shift_base);
#endif
