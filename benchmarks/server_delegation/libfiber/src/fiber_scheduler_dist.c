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

#include "fiber_scheduler.h"
#include "spsc_fifo.h"
#include <x86intrin.h>
#include "mpsc_fifo.h"
#include <assert.h>
#include <stddef.h>
#include "fiber_manager.h"

static size_t fiber_scheduler_num_threads = 0;
static fiber_scheduler_dist_t* fiber_schedulers = NULL;

int fiber_scheduler_dist_init(fiber_scheduler_dist_t* scheduler, size_t id)
{
    assert(scheduler);
    scheduler->id = id;
    scheduler->steal_count = 0;
    scheduler->failed_steal_count = 0;
    
    scheduler->curr_queue1_length = 0;
    scheduler->curr_queue2_length = 0;
    
    scheduler->avg_queue1_length = 0.0;
    scheduler->avg_queue2_length = 0.0;

    scheduler->server_fiber = NULL;
    scheduler->last_was_server = 0;

    if(!spsc_fifo_init(&(scheduler->runnable_queue1))) {
        return 0;
    }
    if(!spsc_fifo_init(&(scheduler->runnable_queue2))) {
        return 0;
    }

    scheduler->runnable_queue = &(scheduler->runnable_queue1);

    mpsc_fifo_init(&(scheduler->incoming_queue));

    int i;

    for (i=0; i< MAX_SERVERS; i++){
        spsc_fifo_init(&(scheduler->req_lock_queue[i]));
    }

    return 1;
}

int fiber_scheduler_init(size_t num_threads)
{
    assert(num_threads > 0);
    fiber_scheduler_num_threads = num_threads;

    fiber_schedulers = calloc(num_threads, sizeof(*fiber_schedulers));
    assert(fiber_schedulers);

    size_t i;
    for(i = 0; i < num_threads; ++i) {
        const int ret = fiber_scheduler_dist_init(&fiber_schedulers[i], i);
        (void)ret;
        assert(ret);
    }
    return 1;
}

fiber_scheduler_t* fiber_scheduler_for_thread(size_t thread_id)
{
    assert(fiber_schedulers);
    assert(thread_id < fiber_scheduler_num_threads);
    return (fiber_scheduler_t*)&fiber_schedulers[thread_id];
}

void fiber_scheduler_schedule(fiber_scheduler_t* scheduler, fiber_t* the_fiber)
{
    assert(scheduler);
    assert(the_fiber);
    mpsc_fifo_node_t* node = the_fiber->mpsc_fifo_node;
    assert(node);
    // the_fiber->mpsc_fifo_node = NULL;
    node->data = the_fiber;

    fiber_manager_t* the_fiber_manager = (fiber_manager_t*)(the_fiber->my_manager);

#ifdef FLAT_DELEGATION_SCHEDULER  

    if(	((fiber_scheduler_dist_t*) scheduler)->server_fiber == NULL && the_fiber->is_server){
	printf("[%d] initial scheduling of server %d\n", ((fiber_scheduler_dist_t*)scheduler)->id, the_fiber->my_id);
    	((fiber_scheduler_dist_t*) scheduler)->server_fiber = the_fiber;
    }

    if (the_fiber_manager->core_id == 0){
	if (the_fiber->is_server)
            printf("server calling fiber_scheduler_schedule\n");
	else 
            printf("fiber calling fiber_scheduler_schedule\n");
    }
#endif

    // someone else is accessing our scheduler so use mpsc queue
    if (the_fiber_manager != fiber_manager_get()){
        mpsc_fifo_push(&((fiber_scheduler_dist_t*)(the_fiber_manager->scheduler))->incoming_queue, node);
       
        //if (the_fiber_manager->core_id == 0)	
	//    printf("[fiber_scheduler_schedule] pushing to incoming queue\n");
    }
    else{
        //if (the_fiber_manager->core_id == 0)	
	//    printf("[fiber_scheduler_schedule] pushing to runnable queue\n");

        if (((fiber_scheduler_dist_t*)scheduler)->runnable_queue == &(((fiber_scheduler_dist_t*)scheduler)->runnable_queue1)){
            spsc_fifo_push(&(((fiber_scheduler_dist_t*)scheduler)->runnable_queue2), node);
            ((fiber_scheduler_dist_t*)scheduler)->curr_queue1_length++;
	}else{
            spsc_fifo_push(&(((fiber_scheduler_dist_t*)scheduler)->runnable_queue1), node);
            ((fiber_scheduler_dist_t*)scheduler)->curr_queue2_length++;
        }
    }

}

void push_and_wait_for_req_lock(int server_no){

    fiber_manager_t* manager = fiber_manager_get();
    fiber_t* current_fiber = manager->current_fiber;
    current_fiber->state = FIBER_STATE_WAIT_FOR_REQ_LINE;

    fiber_scheduler_t* scheduler = manager->scheduler;
    mpsc_fifo_node_t* node = current_fiber->mpsc_fifo_node;
    assert(node);
	current_fiber->mpsc_fifo_node = 0;
    node->data = current_fiber;

    spsc_fifo_push(&(((fiber_scheduler_dist_t*)scheduler)->req_lock_queue[server_no]), (spsc_node_t*)node);

#ifdef DEBUG_YIELD
    if(manager->core_id == 0)
	printf("[%d] yielding after submitting new request\n", current_fiber->my_id);
#endif
    fiber_yield();
}

fiber_t* (*ffwd_poll_resp_callback)(fiber_manager_t* manager, fiber_scheduler_t* sched) = 0;

#ifdef FLAT_DELEGATION_SCHEDULER
fiber_t* fiber_scheduler_next(fiber_scheduler_t* sched)
{
        fiber_scheduler_dist_t* const scheduler = (fiber_scheduler_dist_t*)sched;
        assert(scheduler);
        spsc_node_t* node = NULL;
        fiber_t* new_fiber;

        fiber_manager_t* manager = fiber_manager_get();
        fiber_t* current_fiber = manager->current_fiber;

        //uint64_t before = __rdtsc();
		
        do {

/*		if(scheduler->server_fiber != NULL && scheduler->last_was_server == 0){
			scheduler->last_was_server = 1;
			return scheduler->server_fiber;
		}
*/
		node = spsc_fifo_trypop(scheduler->runnable_queue);
		if (!node){
		  node = mpsc_fifo_trypop(&(scheduler->incoming_queue));
		}
		if(node) {
			new_fiber = (fiber_t*)node->data;
			if(new_fiber->state == FIBER_STATE_SAVING_STATE_TO_WAIT) { // SEPIDEH: this never happens because of my changes
				assert(0);
				spsc_fifo_push(scheduler->runnable_queue, node);
			} else {
				new_fiber->mpsc_fifo_node = node;
				
				scheduler->last_was_server = new_fiber->is_server;
			/*
				if (manager->core_id == 0){	
					if(scheduler->last_was_server == 1)
						printf("scheduling server\n");
					else 
						printf("scheduling dummy fiber\n");
				}
			*/
				return new_fiber;
			}
		}
		else {
			ffwd_poll_resp_callback(manager, (fiber_scheduler_t*)scheduler);

			// switch queues
			if (scheduler->runnable_queue == &(scheduler->runnable_queue1)){
				scheduler->runnable_queue = &(scheduler->runnable_queue2);
			}
			else{
				scheduler->runnable_queue = &(scheduler->runnable_queue1);
			}

		}
				
        }
        while ( (current_fiber->state != FIBER_STATE_RUNNING) && 
        		(current_fiber->state != FIBER_STATE_SAVING_STATE_TO_WAIT) && 
        		(current_fiber->state != FIBER_STATE_EPOLL_WAITING) && 
        		(current_fiber->state != FIBER_STATE_WAITING) && 
        		!fiber_shutting_down);
	
    return NULL;
}
#else
fiber_t* fiber_scheduler_next(fiber_scheduler_t* sched)
{
        fiber_scheduler_dist_t* const scheduler = (fiber_scheduler_dist_t*)sched;
        assert(scheduler);
        spsc_node_t* node = NULL;
        fiber_t* new_fiber;

        fiber_manager_t* manager = fiber_manager_get();
        fiber_t* current_fiber = manager->current_fiber;

        //uint64_t before = __rdtsc();

	//scheduler->schedule_next_count++;	
	//scheduler->avg_queue1_length += ((scheduler->curr_queue1_length - scheduler->avg_queue1_length)/scheduler->schedule_next_count);
	//scheduler->avg_queue2_length += ((scheduler->curr_queue2_length - scheduler->avg_queue2_length)/scheduler->schedule_next_count);

#ifdef DEBUG_YIELD
	if (manager->core_id == 0)
		printf("[%d] new call to scheduler [is_server=%d; this_server->server_core=%d]\n", current_fiber->my_id, manager->is_server, manager->this_server->server_core);
#endif
        do {

#ifdef DEBUG_YIELD
			if(manager->core_id == 0)
				printf("[%d] trying to schedule a new fiber\n",current_fiber->my_id);
#endif
				node = spsc_fifo_trypop(scheduler->runnable_queue);
				if (!node){
				  node = mpsc_fifo_trypop(&(scheduler->incoming_queue));
				} else {
				  if (scheduler->runnable_queue == &(scheduler->runnable_queue1))
				    scheduler->curr_queue1_length--;
				  else 
				   scheduler->curr_queue2_length--;
				}
				if(node) {

					new_fiber = (fiber_t*)node->data;
					if(new_fiber->state == FIBER_STATE_SAVING_STATE_TO_WAIT) { // SEPIDEH: this never happens because of my changes
						assert(0);
						spsc_fifo_push(scheduler->runnable_queue, node);
					} else {
						new_fiber->mpsc_fifo_node = node;
						return new_fiber;
					}
				}
				else {
#ifdef DEBUG_YIELD
					if( manager->core_id == 0) printf("[%d] skip next callback\n", current_fiber->my_id);
					//if(manager->core_id == 0) printf("executing callback\n");	
#endif

#ifdef SERVER_NO_POLL
					if(!manager->is_server) 
						ffwd_poll_resp_callback(manager, (fiber_scheduler_t*)scheduler);
#else
						ffwd_poll_resp_callback(manager, (fiber_scheduler_t*)scheduler);
#endif

                    // switch queues
                    if (scheduler->runnable_queue == &(scheduler->runnable_queue1)){
                        scheduler->runnable_queue = &(scheduler->runnable_queue2);
                    }
                    else{
                        scheduler->runnable_queue = &(scheduler->runnable_queue1);
                    }

                    // if all fibers are waiting for response, we have to check events here
//                    if (manager->is_main_manager == 1 && __rdtsc()-before > 20000){
//						fiber_poll_events();
//						before = __rdtsc();
//					}

				}
				
        }
        while ( (current_fiber->state != FIBER_STATE_RUNNING) && 
        		(current_fiber->state != FIBER_STATE_SAVING_STATE_TO_WAIT) && 
        		(current_fiber->state != FIBER_STATE_EPOLL_WAITING) && 
        		(current_fiber->state != FIBER_STATE_WAITING) && 
        		!fiber_shutting_down);

    return NULL;
}
#endif


void fiber_scheduler_load_balance(fiber_scheduler_t* sched)
{
	assert(0);
    fiber_scheduler_dist_t* const scheduler = (fiber_scheduler_dist_t*)sched;
    size_t max_steal = 16;
    size_t i = scheduler->id + 1;
    const size_t end = i + fiber_scheduler_num_threads - 1;
    const size_t mod = fiber_scheduler_num_threads;
    for(; i < end; ++i) {
        const size_t index = i % mod;
        mpsc_fifo_t* const remote_queue = &fiber_schedulers[index].runnable_queue;
        assert(remote_queue != &scheduler->runnable_queue);
        if(!remote_queue) {
            continue;
        }
        while(max_steal > 0) {
            spsc_node_t* const stolen = mpsc_fifo_trypop(remote_queue);
            if(stolen == 0 || stolen == -1) {
                ++scheduler->failed_steal_count;
                break;
            }
            mpsc_fifo_push(&scheduler->runnable_queue, stolen);
            --max_steal;
            ++scheduler->steal_count;
        }
    }
}

void fiber_scheduler_stats(fiber_scheduler_t* sched, uint64_t* steal_count, uint64_t* failed_steal_count)
{
    fiber_scheduler_dist_t* const scheduler = (fiber_scheduler_dist_t*)sched;
    assert(scheduler);
    *steal_count += scheduler->steal_count;
    *failed_steal_count += scheduler->failed_steal_count;
}

