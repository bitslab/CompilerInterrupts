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

#include "fiber_cond.h"
#include "fiber_manager.h"
#include "test_helper.h"
#include <time.h>
#include <sys/time.h>

fiber_mutex_t smutex;
fiber_cond_t scond;

#define PER_FIBER_COUNT 1
#define NUM_FIBERS 120
#define NUM_THREADS 128
int per_thread_count[NUM_THREADS];
int switch_count = 0;

volatile int fiber_count = 0;
volatile int start = 0;

volatile int count = 0;


void* run_function(void* param)
{
    int * test = (int*) calloc(1, sizeof(int));

    // int id = (int)param;
    // int core_lock_id, rdtscp_id;
    // __asm__ __volatile__ (  "rdtscp \n\t" \
    //                                 "movl   %%ecx, %0" \
    //                                 :"=r"(rdtscp_id)::); \
    // core_lock_id = rdtscp_id & 0x00000FFF; \
    int my_copy = 0;

    fiber_manager_t* const original_manager = fiber_manager_get();
    int i;
    for(i = 0; i < PER_FIBER_COUNT; ++i) {
        fiber_manager_t* const current_manager = fiber_manager_get();
        // if(current_manager != original_manager) {
            // __sync_fetch_and_add(&switch_count, 1);
        // }
        // my_copy = count++;
        // __sync_fetch_and_add(&per_thread_count[current_manager->id], 1);
        // printf("fiber %p yield with id %d count %d\n", current_manager->current_fiber, id, my_copy);
        fiber_yield();
        *test++;

    }

    // fiber_t* return_f = fiber_fork();
    // if (return_f == 0){
    //     fiber_manager_t* manager = fiber_manager_get();
    //     printf(" hi from child\n");
    // }
    // else{
    //     fiber_manager_t* manager = fiber_manager_get();
    //     printf("hi from parent\n");
    // }
    // fiber_yield();
    // if (return_f == 0){
    //     fiber_manager_t* manager = fiber_manager_get();
    //     printf(" bye from child\n");
    // }
    // else{
    //     fiber_manager_t* manager = fiber_manager_get();
    //     printf("bye from parent\n");
    // }

    // fiber_mutex_lock(&smutex);
    // count++;
    // printf("count is %d\n", count);
    // fiber_cond_signal(&scond);
    // fiber_mutex_unlock(&smutex);

    // printf("done\n");
    printf("%p\n", test);

    return NULL;
}

int main()
{
    fiber_manager_init(NUM_THREADS);

    // fiber_mutex_init(&smutex);
    // fiber_cond_init(&scond);

    printf("starting %d fibers with %d backing threads, running %d yields per fiber\n", NUM_FIBERS, NUM_THREADS, PER_FIBER_COUNT);
    fiber_t* fibers[NUM_FIBERS] = {};
    int i;
    for(i = 0; i < NUM_FIBERS; ++i) {
        fibers[i] = fiber_create(100000, &run_function, (void*)i, 0);
        if(!fibers[i]) {
            printf("failed to create fiber!\n");
            return 1;
        }
    }

    for(i = 0; i < NUM_FIBERS; ++i) {
        fiber_join(fibers[i], NULL);
    }

    int duration = 1000;
    struct timespec timeout;
    timeout.tv_sec = duration / 1000;
    timeout.tv_nsec = (duration % 1000) * 1000000;
    nanosleep(&timeout, NULL);


    // fiber_mutex_lock(&smutex);
    // printf("waiting for coutn = %d\n", NUM_FIBERS);
    // while(count < NUM_FIBERS){
    //     fiber_cond_wait(&scond, &smutex);
    // }
    // printf("nwo should join\n");

    // fiber_mutex_unlock(&smutex);

    fiber_join_and_shutdown();

    // printf("SUCCESS\n");

    // for(i = 0; i < NUM_THREADS; ++i) {
    //     printf("thread %d count: %d\n", i, per_thread_count[i]);
    // }
    // printf("switch_count: %d\n", switch_count);
    // fflush(stdout);

    // fiber_manager_print_stats();
    return 0;
}
