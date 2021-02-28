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

#ifndef _FIBER_FIBER_H_
#define _FIBER_FIBER_H_

#include <stdint.h>
#include "ffwd_macros.h"
#include <sys/epoll.h>
#include "thread_layout.h"
#include "fiber_context.h"
#include "mpsc_fifo.h"
#include "spsc_fifo.h"
#include "spsc_lifo.h"
#include "spsc_fifo_queue.h"

#include <immintrin.h>

typedef int fiber_state_t;

struct fiber_manager;

#define FIBER_STATE_RUNNING (1)
#define FIBER_STATE_READY (2)
#define FIBER_STATE_WAITING (3)
#define FIBER_STATE_DONE (4)
#define FIBER_STATE_SAVING_STATE_TO_WAIT (5)
#define FIBER_STATE_WAIT_FOR_REQ_LINE (6)
#define FIBER_STATE_WAIT_FOR_RESP (7)
#define FIBER_STATE_EPOLL_WAITING (8)
#define FIBER_STATE_IS_SERVER (9)

#define FIBER_DETACH_NONE (0)
#define FIBER_DETACH_WAIT_FOR_JOINER (1)
#define FIBER_DETACH_WAIT_TO_JOIN (2)
#define FIBER_DETACH_DETACHED (3)

#define FIBER_CHILD_WAITING_FOR_NESTED 3
#define FIBER_CHILD_WAITING 2
#define FIBER_REQUEST_RESUMABLE 1
#define FIBER_STATELESS 0

#define SAMPLING_SIZE 100
#define SAMPLING_OFFSET 80
#define SAMPLING_INTERVAL (1000000/SAMPLING_SIZE)

struct server_response
{
	volatile uint64_t return_value;
    volatile uint64_t flag;
};

struct server_response_group
{
    struct server_response responses[CLIENT_PER_RESPONSE];

} __attribute__((packed));

struct server_set{
    struct server_response_group* server_response_groups[MAX_SOCK * RESP_GROUP_PER_SOCK];
};

struct fiber;
typedef struct fiber fiber_t;


// 64byte structure, no need for padding with hyperthreads
struct request{
    uint64_t (*fptr)(int);
    uint64_t argv[6];
    uint64_t flag;
} __attribute__((packed, aligned(64)));

struct fiber
{
	// keep request_state & lock_ptr at the top of the struct
    uint64_t request_state;
    uint64_t lock_ptr;
    //*************************************
    uint64_t response_retval;
    struct request my_request;
    volatile fiber_state_t state;
    mpsc_fifo_node_t* volatile mpsc_fifo_node;
    fiber_context_t context;
    int fork_done;
    int my_id;
    int id_in_chip;
    uint64_t* my_manager;
    int fork_parent;
    int is_joining;
    int is_server;
    fiber_run_function_t run_function;
    void* param;
    uint64_t volatile id;/* not unique globally, only within this fiber instance. used for joining */
    void* volatile result;
    int volatile detach_state;
    struct fiber* volatile join_info;
    void* volatile scratch;//to be used by internal fiber mechanisms. be sure mechanisms do not conflict! (ie. only use scratch while a fiber is sleeping/waiting)
    int num_events;
    struct epoll_event *events;
    int maxevents;
    
} __attribute__((packed, aligned(128)));


struct server_args{
	// keep these fields at the top of the struct
    uint64_t rbx;
    uint64_t r12;
    uint64_t r13;
    uint64_t r14;
    uint64_t r15;
	uint64_t req_fiber_index;
	fiber_t* request_fibers[MAX_NUM_OF_REQUESTS];
    //**************************************
    uint64_t **server_local_resp_flags;
    struct server_response **server_local_responses;
    int still_need_to_wait;

#ifdef PROFILE_SERVER_POLL
	uint64_t tot_polls;
	uint64_t poll_size[MAX_NUM_OF_REQUESTS];
	uint64_t tot_ops;
#endif

#ifdef PROFILE_SERVER_POLL_LATENCY
	uint64_t tot_polls;
	uint64_t tot_requests;
	uint64_t latency_accumulator;
	double m_i;
	double s_i;
	double mean_requests_per_loop;
	int current_window;
	int initial_polls;
	double current_CPU_perc;
	double CPU_perc[SAMPLING_SIZE+SAMPLING_OFFSET]; 
#endif

#ifdef NT_STORE
	__m128i old_doorbell;
	int counter;
#elif SERVER_CONTROLLED_DOORBELL
	int old_doorbell;
#endif
	int skip_poll;
	int skip_poll_size;
	int resp_ready;
    uint64_t any_server_fiber_waiting;
	uint64_t ret_addrs[MAX_NUM_OF_REQUESTS][3];
	uint64_t waiting_for_nested_flag[MAX_SERVERS];
	int current_id_in_chip;
	uint64_t* manager;
	int server_numa_node;
	struct request* my_requests[MAX_SERVERS * REQS_LINES_PER_THREAD]; // my request to send to others
    uint64_t* request_fiber_return_addr[MAX_SERVERS * REQS_LINES_PER_THREAD];
	int server_core;
	struct request* chip0;
	struct request* chip1;
	struct request* chip2;
	struct request* chip3;
	volatile char * finished;
	struct server_set* server_response_group; // responses to clients
	struct request* servers_requests[MAX_SERVERS]; // other requests to be checked for any new requests
	struct server_response_group* my_reponses[MAX_SERVERS]; // my responses from other servers
	uint64_t local_flag[MAX_SERVERS];
    lock_fifo_queue* req_lock[MAX_SERVERS];
} __attribute__((packed));


#ifdef __cplusplus
extern "C" {
#endif

extern volatile __thread uint64_t rsp_before_del_call;
extern volatile int num_of_server_launched;

#define FIBER_DEFAULT_STACK_SIZE (102400)
#define FIBER_MIN_STACK_SIZE (1024)

extern fiber_t* fiber_create(size_t stack_size, fiber_run_function_t run, void* param);
extern fiber_t* server_create(size_t stack_size, fiber_run_function_t run, void* param, int server_core);

extern fiber_t* fiber_create_no_sched(size_t stack_size, fiber_run_function_t run, void* param, void* manager);

extern fiber_t* fiber_create_from_thread();
extern fiber_t* fiber_fork();
extern fiber_t* server_fiber_fork_and_push(spsc_fifo_t* lock_queue);
extern fiber_t* server_fiber_fork();

extern int fiber_join(fiber_t* f, void** result);

extern int fiber_tryjoin(fiber_t* f, void** result);

extern int fiber_yield();

extern void fiber_pop_from_lock_and_run();
extern void fiber_wait_for_resp();


extern int server_fiber_switch_to(fiber_t* f);

extern int fiber_detach(fiber_t* f);

#ifdef __cplusplus
}
#endif

#endif

