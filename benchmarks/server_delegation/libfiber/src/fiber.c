/*
 * Copyright (c) 2012-2015, Brian Watling and other contributors
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

// #include "fiber.h"
#include "fiber_manager.h"
#include "mpmc_lifo.h"
#include "fiber_cond.h"
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>


__thread volatile uint64_t rsp_before_del_call;

fiber_mutex_t mutex;
fiber_cond_t cond;
lock_fifo_queue* lock_queue;
volatile int num_of_fibers_finished = 0;

void fiber_join_routine(fiber_t* the_fiber, void* result)
{
    the_fiber->result = result;
    write_barrier();//make sure the result is available before changing the state
    
    fiber_manager_t* manager = fiber_manager_get();
    manager->num_of_fibers_done++;

    if(the_fiber->detach_state != FIBER_DETACH_DETACHED) {
        const int old_state = atomic_exchange_int((int*)&the_fiber->detach_state, FIBER_DETACH_WAIT_FOR_JOINER);
        if(old_state == FIBER_DETACH_NONE) {
            //need to wait until another fiber joins this one
            fiber_manager_set_and_wait(manager, (void**)&the_fiber->join_info, the_fiber);
        } else if(old_state == FIBER_DETACH_WAIT_TO_JOIN) {
            //the joining fiber is waiting for us to finish
            fiber_t* const to_schedule = fiber_manager_clear_or_wait(manager, (void**)&the_fiber->join_info);
            to_schedule->result = the_fiber->result;
            to_schedule->state = FIBER_STATE_READY;
            fiber_manager_schedule(manager, to_schedule);
        }
    }

    the_fiber->state = FIBER_STATE_DONE;

    manager->done_fiber = the_fiber;
    fiber_manager_yield(manager);
    printf("ERROR %p %p\n", the_fiber, manager->maintenance_fiber);
    assert(0 && "should never get here");
}

#ifdef FIBER_STACK_SPLIT
__attribute__((__no_split_stack__))
#endif
static void* fiber_go_function(void* param)
{
    fiber_t* the_fiber = (fiber_t*)param;

    /* do maintenance - this is usually done after fiber_context_swap, but we do it here too since we are coming from a new place */
    fiber_manager_do_maintenance();

    void* const result = the_fiber->run_function(the_fiber->param);

    fiber_manager_t* manager = fiber_manager_get();
    fiber_t* const current_fiber = manager->current_fiber;

    fiber_join_routine(current_fiber, result);

    return NULL;
}

mpmc_lifo_t fiber_free_fibers = MPMC_LIFO_INITIALIZER;

volatile int global_id = -1;

fiber_t* fiber_create_no_sched(size_t stack_size, fiber_run_function_t run_function, void* param, void* manager)
{
    fiber_manager_t* new_fiber_manager = (fiber_manager_t*) manager;
    mpsc_fifo_node_t* const node = (mpsc_fifo_node_t*)spsc_lifo_trypop(&(new_fiber_manager->recyled_fibers)); //mpmc_lifo_pop(&fiber_free_fibers);

    fiber_t* ret = NULL;
    if(!node) {
        ret = calloc(1, sizeof(*ret));
        if(!ret) {
            errno = ENOMEM;
            return NULL;
        }
        ret->mpsc_fifo_node = calloc(1, sizeof(*ret->mpsc_fifo_node));
        if(!ret->mpsc_fifo_node) {
            free(ret);
            errno = ENOMEM;
            return NULL;
        }
    } else {
        ret = (fiber_t*)node->data;
        ret->mpsc_fifo_node = node;
        //we got an old fiber for re-use - destroy the old stack
        fiber_context_destroy(&ret->context);
    }

    assert(ret->mpsc_fifo_node);

    ret->run_function = run_function;
    ret->param = param;
    ret->state = FIBER_STATE_READY;
    ret->detach_state = FIBER_DETACH_NONE;
    ret->join_info = NULL;
    ret->result = NULL;
    ret->id += 1;
    ret->is_joining = 0;
    ret->fork_done = 0;
    ret->fork_parent = 0;
    ret->request_state = 0;
    ret->num_events = 0;
    ret->lock_ptr = 0;
    ret->my_manager = new_fiber_manager;
    if(FIBER_SUCCESS != fiber_context_init(&ret->context, stack_size, &fiber_go_function, ret)) {
        free(ret);
        return NULL;
    }

    return ret;
}

fiber_t* fiber_create_and_pin(size_t stack_size, fiber_run_function_t run_function, void* param, int is_server, int core_id)
{

    fiber_manager_t* manager = fiber_managers[core_id];
    
    if (!fiber_managers[core_id]->running){
        pthread_mutex_lock(&manager_lock);
    	pthread_cond_signal(&manager_cond[core_id]);
    	pthread_mutex_unlock(&manager_lock);
    	fiber_managers[core_id]->running = 1;
	}

    fiber_t* const ret = fiber_create_no_sched(stack_size, run_function, param, manager);

    if(ret) {
        if (is_server == 0){
            ret->is_joining = 1;
            ret->my_id = global_id++;
        }
        if (is_server == 1){
            ret->is_server = 1;
            next_server_id++;
            fiber_managers[core_id]->server_id = next_server_id;
            fiber_managers[core_id]->is_server = 1;

	    fiber_managers[core_id]->this_server = ret;
        }

        fiber_manager_schedule(ret->my_manager, ret);
    }

    return ret;
}

fiber_t* server_create(size_t stack_size, fiber_run_function_t run_function, void* param, int server_core)
{
	assert(server_core<TOTAL_NUM_OF_THREADS);

	// avoid creating server on the same thread as the main fiber
	assert(server_core != main_manager->core_id && "cannot create a server on the same thread as the main thread -- change main_manager_tindex in fiber_manager_init()");
    return fiber_create_and_pin(stack_size, run_function, param, 1, server_core);
}

fiber_t* fiber_create(size_t stack_size, fiber_run_function_t run_function, void* param)
{

    fiber_manager_t* manager = fiber_manager_assign();
    fiber_t* const ret = fiber_create_no_sched(stack_size, run_function, param, manager);

    if(ret) {
        ret->is_joining = 1;
        ret->my_id = global_id++;
        fiber_manager_schedule(ret->my_manager, ret);
    }

    return ret;
}

fiber_t* server_fiber_fork()
{
    fiber_t* ret = 0;
    // uint64_t rsp = 0;
    fiber_manager_t* manager = fiber_manager_get();
    fiber_t* current_fiber = manager->current_fiber;
    current_fiber->fork_parent = 1;

    ret = fiber_create_no_sched(current_fiber->context.ctx_stack_size, current_fiber->run_function, current_fiber->param, manager);        

    // for context switch
    uint64_t* rbp, rbx, r12, r13, r14, r15, rip;
    __asm__ volatile
    (
        "movq %%rbp, %0 \n\t"
        "movq %%rbx, %1 \n\t"
        "movq %%r12, %2 \n\t"
        "movq %%r13, %3 \n\t"
        "movq %%r14, %4 \n\t"
        "movq %%r15, %5 \n\t"
        "leaq 0f(%%rip), %%rcx \n\t"
        "movq %%rcx, %6 \n\t"
        : "=m" (rbp), "=m" (rbx), "=m" (r12), "=m" (r13), "=m" (r14), "=m" (r15), "=m" (rip)
        :
        : "memory","rcx"
    );

    // find the current rsp of child (based on the relative addr of parent rsp)
    // -16 is to skip the return address and rbp of the call frame
    uint64_t* child_rsp = ret->context.ctx_stack + ((void*)(rsp_before_del_call - 16) - current_fiber->context.ctx_stack);


    // only copy necessary parts of stack
    uint64_t stack_size_to_copy = ((uint64_t)current_fiber->context.ctx_stack + (uint64_t)current_fiber->context.ctx_stack_size) - (rsp_before_del_call - 16);
    memcpy(child_rsp, (void*)(rsp_before_del_call-16), stack_size_to_copy);


    // what is the diff btween stack memory addresses of child and parent
    uint64_t stack_displacement;
 	stack_displacement = ret->context.ctx_stack - current_fiber->context.ctx_stack;

 	/* change the ret address on the stack to address of label 6 */
    *(child_rsp+1) = manager->this_server->ret_addrs[manager->this_server->req_fiber_index][0];
    /* update the rbp on the child's stack */
    *(child_rsp) = (((uint64_t)*child_rsp)+stack_displacement);
    uint64_t prev_frame_rbp = *(child_rsp);

    // because context_swap works this way in libfiber
    uint64_t* child_curr_frame_rbp = (uint64_t*)((uint64_t)rbp+stack_displacement);
    *--child_rsp = rip;
    *--child_rsp = child_curr_frame_rbp;
    *--child_rsp = rbx;
    *--child_rsp = r12;
    *--child_rsp = r13;
    *--child_rsp = r14;
    *--child_rsp = r15;
    ret->context.ctx_stack_pointer = child_rsp;

    current_fiber = manager->current_fiber;

    // parent
    if (current_fiber->fork_parent){

    	// change the return address for this fiber, so it returns to label 3 after it is done
    	*(((uint64_t*)rsp_before_del_call)-1) = manager->this_server->ret_addrs[manager->this_server->req_fiber_index][1];

    	// change the rbp of the last frame
    	uint64_t* child_prev_frame_rbp = (uint64_t*)(prev_frame_rbp);
    	*child_prev_frame_rbp = (*child_prev_frame_rbp) + (stack_displacement);


        return ret;
    }


    // child starts from here
    __asm__ volatile
    ( "0:\n\t"
    :
    : 
    : "memory"
    );

    // jump to label 6, which makes the child return and continue running the server loop
    __asm__ __volatile__ ("popq 	%%rbp \n\t"
    						"popq 	%%r15 \n\t"
    						"jmp 	*%%r15" ::: "r15");


    return 0;

}


fiber_t* fiber_fork()
{
    fiber_t* ret;
    uint64_t rsp;

    __asm__ __volatile__ ("movq %%rsp, %0" : "=m" (rsp):: "memory");

    // find the fiber that has called fork
    fiber_manager_t* manager;
    fiber_t* current_fiber;

    manager = fiber_manager_get();
    current_fiber = manager->current_fiber;
    current_fiber->fork_parent = 1;

    // create a new fiber
    ret = fiber_create_no_sched(current_fiber->context.ctx_stack_size ,current_fiber->run_function, current_fiber->param, manager);
    void * start_of_current_stack = current_fiber->context.ctx_stack;
    void * start_of_new_stack = ret->context.ctx_stack;

    fiber_manager_schedule(manager, ret);

    uint64_t* rbp, rbx, r12, r13, r14, r15, rip;

    __asm__ volatile
    (
        "movq %%rbp, %0 \n\t"
        "movq %%rbx, %1 \n\t"
        "movq %%r12, %2 \n\t"
        "movq %%r13, %3 \n\t"
        "movq %%r14, %4 \n\t"
        "movq %%r15, %5 \n\t"
        "leaq 0f(%%rip), %%rcx \n\t"
        "movq %%rcx, %6 \n\t"
        : "=m" (rbp), "=m" (rbx), "=m" (r12), "=m" (r13), "=m" (r14), "=m" (r15), "=m" (rip)
        :
        : "memory","rcx"
    );

   // copy the current fiber context to the new fiber
    memcpy(start_of_new_stack, start_of_current_stack, current_fiber->context.ctx_stack_size);
    uint64_t* child_rsp = ret->context.ctx_stack + ((void*)rsp - current_fiber->context.ctx_stack);

    *--child_rsp = rip;
    *--child_rsp = rbp;
    *--child_rsp = rbx;
    *--child_rsp = r12;
    *--child_rsp = r13;
    *--child_rsp = r14;
    *--child_rsp = r15;
    ret->context.ctx_stack_pointer = child_rsp;


    __asm__ volatile
    ( "0:\n\t"
         :
    : 
    : "memory"
    );

    current_fiber = manager->current_fiber;

    // parent
    if (current_fiber->fork_parent){
        return ret;
    }
    // child
    if (!current_fiber->fork_parent){
        fiber_manager_do_maintenance();
        return 0;
    }
    
    return ret;

}

fiber_t* fiber_create_from_thread()
{
    fiber_t* ret;

    ret = calloc(1, sizeof(*ret));
    if(!ret) {
        errno = ENOMEM;
        return NULL;
    }
    ret->mpsc_fifo_node = calloc(1, sizeof(*ret->mpsc_fifo_node));
    if(!ret->mpsc_fifo_node) {
        free(ret);
        errno = ENOMEM;
        return NULL;
    }

    ret->state = FIBER_STATE_RUNNING;
    ret->detach_state = FIBER_DETACH_NONE;
    ret->join_info = NULL;
    ret->result = NULL;
    ret->id = 1;
    ret->is_joining = 0;
    ret->fork_done = 0;
    ret->fork_parent = 0;
    ret->request_state = 0;
    ret->lock_ptr = 0;

    if(FIBER_SUCCESS != fiber_context_init_from_thread(&ret->context)) {
        free(ret);
        return NULL;
    }

    return ret;
}

#include <stdio.h>

int fiber_join(fiber_t* f, void** result)
{
    assert(f);
    if(result) {
        *result = NULL;
    }
    if(f->detach_state == FIBER_DETACH_DETACHED) {
        return FIBER_ERROR;
    }

    const int old_state = atomic_exchange_int((int*)&f->detach_state, FIBER_DETACH_WAIT_TO_JOIN);
    if(old_state == FIBER_DETACH_NONE) {
        //need to wait till the fiber finishes
        fiber_manager_t* const manager = fiber_manager_get();
        fiber_t* const current_fiber = manager->current_fiber;
        fiber_manager_set_and_wait(manager, (void**)&f->join_info, current_fiber);
        if(result) { 
            *result = current_fiber->result;
        }
        current_fiber->result = NULL;
    } else if(old_state == FIBER_DETACH_WAIT_FOR_JOINER) {
        //the other fiber is waiting for us to join
        if(result) { 
            *result = f->result;
        }
        fiber_t* const to_schedule = fiber_manager_clear_or_wait(fiber_manager_get(), (void**)&f->join_info);
        to_schedule->state = FIBER_STATE_READY;
        // fiber_manager_schedule(fiber_manager_get(), to_schedule);
        fiber_manager_schedule(to_schedule->my_manager, to_schedule);

    } else {
        //it's either WAIT_TO_JOIN or DETACHED - that's an error!
        return FIBER_ERROR;
    }

    return FIBER_SUCCESS;

}

int fiber_tryjoin(fiber_t* f, void** result)
{
    assert(f);
    if(result) {
        *result = NULL;
    }
    if(f->detach_state == FIBER_DETACH_DETACHED) {
        return FIBER_ERROR;
    }

    if(f->detach_state == FIBER_DETACH_WAIT_FOR_JOINER) {
        //here we've read that the fiber is waiting to be joined.
        //if the fiber is still waiting to be joined after we atmically change its state,
        //then we can go ahead and wake it up. if the fiber's state has changed, we can
        //assume the fiber has been detached or has be joined by some other fiber
        const int old_state = atomic_exchange_int((int*)&f->detach_state, FIBER_DETACH_WAIT_TO_JOIN);
        if(old_state == FIBER_DETACH_WAIT_FOR_JOINER) {
            //the other fiber is waiting for us to join
            if(result) { 
                *result = f->result;
            }
            fiber_t* const to_schedule = fiber_manager_clear_or_wait(fiber_manager_get(), (void**)&f->join_info);
            to_schedule->state = FIBER_STATE_READY;
            fiber_manager_schedule(fiber_manager_get(), to_schedule);
            return FIBER_SUCCESS;
        }
    }

    return FIBER_ERROR;
}

int server_fiber_switch_to(fiber_t* new_fiber)
{
    fiber_manager_t* manager = fiber_manager_get();

    fiber_manager_switch_to(manager, manager->current_fiber, new_fiber);
    return 1;
}

/*
void fiber_push_and_wait_for_req_lock(int server_no){
    push_and_wait_for_req_lock(server_no);
}
*/

int fiber_yield()
{
    fiber_manager_t* manager = fiber_manager_get();
    //if(manager->current_fiber->is_server)
//	    manager->current_fiber->state = FIBER_STATE_IS_SERVER;
    fiber_manager_yield(manager);
    return 1;
}

int fiber_detach(fiber_t* f)
{
    if(!f) {
        return FIBER_ERROR;
    }
    const int old_state = atomic_exchange_int((int*)&f->detach_state, FIBER_DETACH_DETACHED);
    if(old_state == FIBER_DETACH_WAIT_FOR_JOINER
       || old_state == FIBER_DETACH_WAIT_TO_JOIN) {
        //wake up the fiber or the fiber trying to join it (this second case is a convenience, pthreads specifies undefined behaviour in that case)
        fiber_t* const to_schedule = fiber_manager_clear_or_wait(fiber_manager_get(), (void**)&f->join_info);
        to_schedule->state = FIBER_STATE_READY;
        fiber_manager_schedule(fiber_manager_get(), to_schedule);
    } else if(old_state == FIBER_DETACH_DETACHED) {
        return FIBER_ERROR;
    }
    return FIBER_SUCCESS;
}

