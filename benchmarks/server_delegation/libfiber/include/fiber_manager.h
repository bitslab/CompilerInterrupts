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

#ifndef _FIBER_MANAGER_H_
#define _FIBER_MANAGER_H_

#include "fiber.h"
#include "fiber_mutex.h"
#include "fiber_cond.h"
#include "fiber_spinlock.h"
#include "work_stealing_deque.h"
#include "mpsc_fifo.h"
#include "spsc_fifo.h"
#include "spsc_lifo.h"
#include "mpmc_fifo.h"
#include "mpmc_lifo.h"
#include "fiber_scheduler.h"
#include "spsc_fifo_queue.h"

typedef struct fiber_scheduler_dist
{
    spsc_fifo_t *runnable_queue;
    spsc_fifo_t runnable_queue1;
    spsc_fifo_t runnable_queue2;
    mpsc_fifo_t incoming_queue; // At first all fibers are pushed to this Q by main fiber - also for cond and mutex
    spsc_fifo_t req_lock_queue[MAX_SERVERS];
    
    fiber_t* server_fiber;
    int last_was_server;

    int curr_queue1_length;
    int curr_queue2_length;
    uint64_t schedule_next_count;
    double avg_queue1_length;
    double avg_queue2_length;

    size_t id;
    uint64_t steal_count;
    uint64_t failed_steal_count;
} __attribute__((__packed__)) fiber_scheduler_dist_t;

typedef struct fiber_mpsc_to_push
{
    mpsc_fifo_t* fifo;
    mpsc_fifo_node_t* node;
} fiber_mpsc_to_push_t;

typedef struct fiber_mpmc_to_push
{
    mpmc_fifo_t* fifo;
    mpmc_fifo_node_t* node;
} fiber_mpmc_to_push_t;

typedef struct fiber_manager
{
    fiber_t* maintenance_fiber;
    int req_fiber_index;
    struct server_args* this_server;
    int is_server;
    int server_id;
    int running;
    uint64_t calloc_count;
    fiber_t* volatile current_fiber;
    fiber_t* volatile old_fiber;
    fiber_t* thread_fiber;
    fiber_t* volatile to_schedule;
    fiber_t* resp_waiting_fibers[MAX_REQUEST_LINE_PER_CORE]; // REQS_PER_CORE * NUM_OF_SERVERS
    spsc_lifo_t recyled_fibers;
    fiber_mpsc_to_push_t mpsc_to_push;
    hazard_pointer_thread_record_t* mpmc_hptr;
    fiber_mpmc_to_push_t mpmc_to_push;
    fiber_mutex_t* volatile mutex_to_unlock;
    fiber_spinlock_t* volatile spinlock_to_unlock;
    void** volatile set_wait_location;
    void* volatile set_wait_value;
    fiber_scheduler_t* scheduler;
    fiber_t* volatile done_fiber;
    int core_id;
    int is_main_manager;
    int last_client;
    uint64_t last_time;
    uint64_t yield_count;
    uint64_t spin_count;
    uint64_t signal_spin_count;
    uint64_t multi_signal_spin_count;
    uint64_t wake_mpsc_spin_count;
    uint64_t wake_mpmc_spin_count;
    uint64_t poll_count;
    uint64_t event_wait_count;
    uint64_t lock_contention_count;
    int num_of_fibers_done;
    int num_of_fibers;
    int event_fd;
    int timer_fd;
} fiber_manager_t;

#ifdef __cplusplus
extern "C" {
#endif

extern volatile int fiber_shutting_down;
extern mpmc_lifo_t fiber_free_fibers;
extern fiber_manager_t** fiber_managers;
extern volatile int next_server_id;
extern pthread_cond_t manager_cond[TOTAL_NUM_OF_THREADS];
extern pthread_mutex_t manager_lock;
extern fiber_manager_t* main_manager;
// extern fifo_queue* lock_queue;

extern __thread fiber_manager_t* fiber_the_manager;
inline fiber_manager_t* fiber_manager_get();

inline fiber_manager_t* fiber_manager_get()
{
    return fiber_the_manager;
}

extern fiber_manager_t* fiber_manager_create(fiber_scheduler_t* scheduler);

static inline void fiber_manager_schedule(fiber_manager_t* manager, fiber_t* the_fiber)
{
    assert(manager);
    assert(the_fiber);
    fiber_scheduler_schedule(manager->scheduler, the_fiber);
}

extern void fiber_manager_yield(fiber_manager_t* manager);

extern void fiber_manager_switch_to(fiber_manager_t* manager, fiber_t* old_fiber, fiber_t* new_fiber);
extern void fiber_manager_switch_no_maintenance(fiber_manager_t* manager, fiber_t* old_fiber, fiber_t* new_fiber);


extern fiber_manager_t* fiber_manager_assign();
extern fiber_manager_t* server_fiber_manager_assign(int);

/* this should be called immediately when the applicaion starts */
extern int fiber_manager_init(size_t num_threads);

extern void fiber_join_and_shutdown();
extern void servers_join();

#define FIBER_MANAGER_STATE_NONE (0)
#define FIBER_MANAGER_STATE_STARTED (1)
#define FIBER_MANAGER_STATE_ERROR (2)

extern int fiber_manager_get_state();

extern int fiber_manager_get_kernel_thread_count();

extern void fiber_manager_do_maintenance();

extern void fiber_manager_wait_in_mpmc_queue(fiber_manager_t* manager, mpmc_fifo_t* fifo);

extern int fiber_manager_wake_from_mpmc_queue(fiber_manager_t* manager, mpmc_fifo_t* fifo, int count);

extern void fiber_manager_wait_in_mpsc_queue(fiber_manager_t* manager, mpsc_fifo_t* fifo);

extern void fiber_manager_wait_in_mpsc_queue_and_unlock(fiber_manager_t* manager, mpsc_fifo_t* fifo, fiber_mutex_t* mutex);

extern int fiber_manager_wake_from_mpsc_queue(fiber_manager_t* manager, mpsc_fifo_t* fifo, int count);

extern void fiber_manager_set_and_wait(fiber_manager_t* manager, void** location, void* value);

extern void* fiber_manager_clear_or_wait(fiber_manager_t* manager, void** location);

extern void register_ffwd_callback(fiber_t* (*callback)(fiber_manager_t* manager, fiber_scheduler_t* sched));
extern fiber_t* (*ffwd_poll_resp_callback)(fiber_manager_t* manager, fiber_scheduler_t* sched);

extern void* fiber_load_symbol(const char* symbol);

extern void fiber_do_real_sleep(uint32_t seconds, uint32_t useconds);

extern hazard_pointer_thread_record_t* fiber_manager_get_hazard_record(fiber_manager_t* manager);

extern mpmc_fifo_node_t* fiber_manager_get_mpmc_node();

extern void fiber_manager_return_mpmc_node(mpmc_fifo_node_t* node);

typedef struct fiber_manager_stats
{
    uint64_t yield_count;
    uint64_t steal_count;
    uint64_t failed_steal_count;
    uint64_t spin_count;
    uint64_t signal_spin_count;
    uint64_t multi_signal_spin_count;
    uint64_t wake_mpsc_spin_count;
    uint64_t wake_mpmc_spin_count;
    uint64_t poll_count;
    uint64_t event_wait_count;
    uint64_t lock_contention_count;
} fiber_manager_stats_t;

//stats are *added* to the values currently in *out
extern void fiber_manager_stats(fiber_manager_t* manager, fiber_manager_stats_t* out);

//stats are *added* to the values currently in *out
extern void fiber_manager_all_stats(fiber_manager_stats_t* out);

#ifdef __cplusplus
}
#endif

#endif

