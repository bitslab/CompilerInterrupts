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

#include <pthread.h>
#include <stdint.h>
// #include "test_helper.h"
#include <sys/time.h>

int volatile counter = 0;
pthread_mutex_t mutex;
#define PER_FIBER_COUNT 1000000
#define NUM_FIBERS 100
#define NUM_THREADS 4

void* run_function(void* param)
{
    int i;
    for(i = 0; i < PER_FIBER_COUNT; ++i) {
        pthread_mutex_lock(&mutex);
        ++counter;
        pthread_mutex_unlock(&mutex);
    }
    return NULL;
}

int main()
{
    //fiber_manager_init(NUM_THREADS);
    struct timespec t_start, t_end;
    pthread_mutex_init(&mutex, NULL);

    pthread_t fibers[NUM_FIBERS];
    int i;
    for(i = 0; i < NUM_FIBERS; ++i) {
        pthread_create(&fibers[i], NULL, &run_function, NULL);
    }

    clock_gettime(CLOCK_MONOTONIC, &t_start);

    for(i = 0; i < NUM_FIBERS; ++i) {
        pthread_join(fibers[i], NULL);
    }

    clock_gettime(CLOCK_MONOTONIC, &t_end);


    uint64_t start = (t_start.tv_sec * 1000000000LL) + t_start.tv_nsec;
    uint64_t finish = (t_end.tv_sec * 1000000000LL) + t_end.tv_nsec;
    uint64_t duration = finish - start;
    double duration_sec = (double)(duration) / 1000000000LL;

    printf("%.3f \n", duration_sec);

    printf("%d\n", counter);
    

    // test_assert(counter == NUM_FIBERS * PER_FIBER_COUNT);

    return 0;
}

