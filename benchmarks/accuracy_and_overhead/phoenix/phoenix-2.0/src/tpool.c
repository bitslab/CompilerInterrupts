/* Copyright (c) 2007-2009, Stanford University
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of Stanford University nor the names of its 
*       contributors may be used to endorse or promote products derived from 
*       this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY STANFORD UNIVERSITY ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL STANFORD UNIVERSITY BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/ 

#ifndef LIBFIBER
#include <pthread.h>
#include <semaphore.h>
#else
#include "fiber_manager.h"
#include "fiber_semaphore.h"
//#include "fiber_cond.h"
#endif
#include <assert.h>

#include "atomic.h"
#include "memory.h"
#include "tpool.h"
#include "stddefines.h"
#include "ci_lib.h"

typedef struct {
#ifndef LIBFIBER
    sem_t           sem_run;
#else
    fiber_semaphore_t sem_run;
#endif
    unsigned int    *num_workers_done;
#ifndef LIBFIBER
    sem_t           *sem_all_workers_done;
#else
    fiber_semaphore_t *sem_all_workers_done;
#endif
    thread_func     *thread_func;
    void            **thread_func_arg;
    void            **ret;
    int             *num_workers;
    int             *die;
    unsigned int    index;
} thread_arg_t;

struct tpool_t {
    int             num_threads;
    int             num_workers;
    int             die;
    thread_func     thread_func;
#ifndef LIBFIBER
    sem_t           sem_all_workers_done;
#else
    fiber_semaphore_t sem_all_workers_done;
#endif
    unsigned int    num_workers_done;
    void            **args;
#ifndef LIBFIBER
    pthread_t       *threads;
#else
    fiber_t       **threads;
#endif
    thread_arg_t    *thread_args;
};

static void* thread_loop (void *);

tpool_t* tpool_create (int num_threads)
{
    int             i, ret;
    tpool_t         *tpool;
    pthread_attr_t  attr;

    tpool = mem_calloc (1, sizeof (tpool_t));
    if (tpool == NULL) 
        return NULL;

    tpool->num_threads = num_threads;
    tpool->num_workers = num_threads;

    tpool->args = (void **)mem_malloc (sizeof (void *) * num_threads);
    if (tpool->args == NULL) 
        goto fail_args;

#ifndef LIBFIBER
    tpool->threads = (pthread_t *)mem_malloc (sizeof (pthread_t) * num_threads);
#else
    tpool->threads = (fiber_t **)mem_malloc (sizeof (fiber_t *) * num_threads);
#endif
    if (tpool->threads == NULL) 
        goto fail_threads;

    tpool->thread_args = (thread_arg_t *)mem_malloc (
        sizeof (thread_arg_t) * num_threads);
    if (tpool->thread_args == NULL) 
        goto fail_thread_args;

#ifndef LIBFIBER
    ret = sem_init (&tpool->sem_all_workers_done, 0, 0);
    if (ret != 0) 
        goto fail_all_workers_done;

    CHECK_ERROR (pthread_attr_init (&attr));
    CHECK_ERROR (pthread_attr_setscope (&attr, PTHREAD_SCOPE_SYSTEM));
    CHECK_ERROR (pthread_attr_setdetachstate (&attr, PTHREAD_CREATE_DETACHED));
#else
    ret = fiber_semaphore_init (&tpool->sem_all_workers_done, 0);
    if (ret != FIBER_SUCCESS) 
        goto fail_all_workers_done;
#endif

    tpool->die = 0;
    for (i = 0; i < num_threads; ++i) {
        /* Initialize thread argument. */
#ifndef LIBFIBER
        CHECK_ERROR (sem_init (&(tpool->thread_args[i].sem_run), 0, 0));
#else
        fiber_semaphore_init(&(tpool->thread_args[i].sem_run), 0);
#endif
        tpool->thread_args[i].sem_all_workers_done = 
            &tpool->sem_all_workers_done;
        tpool->thread_args[i].num_workers_done = 
            &tpool->num_workers_done;
        tpool->thread_args[i].die = &tpool->die;
        tpool->thread_args[i].thread_func = &tpool->thread_func;
        tpool->thread_args[i].thread_func_arg = &tpool->args[i];
        tpool->thread_args[i].ret = (void **)mem_malloc (sizeof (void *));
        CHECK_ERROR (tpool->thread_args[i].ret == NULL);
        tpool->thread_args[i].num_workers = &tpool->num_workers;
        tpool->thread_args[i].index = i+2;
        
#ifndef LIBFIBER
        ret = pthread_create (
            &tpool->threads[i], &attr, thread_loop, &tpool->thread_args[i]);
        if (ret) 
            goto fail_thread_create;
#else
        tpool->threads[i] = fiber_create (8192,
            thread_loop, &tpool->thread_args[i]);
        if(tpool->threads[i] == NULL)
            goto fail_thread_create;
#endif
    }

    return tpool;

fail_thread_create:
    --i;
    while (i >= 0)
    {
#ifndef LIBFIBER
        pthread_cancel (tpool->threads[i]);
#endif
        --i;
    }
fail_all_workers_done:
    mem_free (tpool->thread_args);
fail_thread_args:
    mem_free (tpool->threads);
fail_threads:
    mem_free (tpool->args);
fail_args:

    return NULL;
}

int tpool_set (
    tpool_t *tpool, thread_func thread_func, void **args, int num_workers)
{
    int             i;
    
    assert (tpool != NULL);

    tpool->thread_func = thread_func;

    assert (num_workers <= tpool->num_threads);
    tpool->num_workers = num_workers;

    for (i = 0; i < num_workers; ++i)
    {
        tpool->args[i] = args[i];
    }
    

    return 0;
}

int tpool_begin (tpool_t *tpool)
{
    int             i, ret;

    assert (tpool != NULL);

    if (tpool->num_workers == 0)
        return 0;

    tpool->num_workers_done = 0;

    for (i = 0; i < tpool->num_workers; ++i) {
#ifndef LIBFIBER
        ret = sem_post (&(tpool->thread_args[i].sem_run));
        if (ret != 0) 
            return -1;
#else
        ret = fiber_semaphore_post (&(tpool->thread_args[i].sem_run));
        //if (ret != 0) 
            //return -1;
#endif
    }

    return 0;
}

int tpool_wait (tpool_t *tpool)
{
    int             ret;

    assert (tpool != NULL);

    if (tpool->num_workers == 0)
        return 0;

#ifndef LIBFIBER
    ret = sem_wait (&tpool->sem_all_workers_done);
    if (ret != 0) 
        return -1;
#else
    ret = fiber_semaphore_wait (&tpool->sem_all_workers_done);
    if (ret != FIBER_SUCCESS)
        return -1;
#endif

    return 0;
}

void** tpool_get_results (tpool_t *tpool)
{
    int             i;
    void            **rets;

    assert (tpool != NULL);

    rets = (void **)mem_malloc (sizeof (void *) * tpool->num_threads);
    CHECK_ERROR (rets == NULL);

    for (i = 0; i < tpool->num_threads; ++i) {
        rets[i] = *(tpool->thread_args[i].ret);   
    }

    return rets;
}

int tpool_destroy (tpool_t *tpool)
{
    int             i;
    int             result;
    
    assert (tpool != NULL);
    assert (tpool->die == 0);

    result = 0;
    tpool->num_workers = tpool->num_threads;
    tpool->num_workers_done = 0;
    
    for (i = 0; i < tpool->num_threads; ++i) {
        mem_free (tpool->thread_args[i].ret);

        tpool->die = 1;
#ifndef LIBFIBER
        sem_post(&tpool->thread_args[i].sem_run);
#else
        fiber_semaphore_post(&tpool->thread_args[i].sem_run);
#endif
    }

#ifndef LIBFIBER
    sem_wait(&tpool->sem_all_workers_done);
#else
    fiber_semaphore_wait(&tpool->sem_all_workers_done);
#endif

#ifndef LIBFIBER
    sem_destroy(&tpool->sem_all_workers_done);
#else
    fiber_semaphore_destroy(&tpool->sem_all_workers_done);
#endif
    mem_free (tpool->args);
    mem_free (tpool->threads);
    mem_free (tpool->thread_args);

    mem_free (tpool);

    return result;
}

static void* thread_loop (void *arg)
{
    thread_arg_t    *thread_arg = arg;
    thread_func     thread_func;
    void            *thread_func_arg;
    void            **ret;
    int             num_workers_done;

    init_stats(0); // parameter is unused. Fix it in the library.
    assert (thread_arg);
    //int index = thread_arg->index;
    //printf("Thread loop index: %d\n", index);

    while (1)
    {
#ifndef LIBFIBER
        CHECK_ERROR (sem_wait (&thread_arg->sem_run));
#else
        fiber_semaphore_wait(&thread_arg->sem_run);
#endif
        if (*thread_arg->die)
            break;

        thread_func = *(thread_arg->thread_func);
        thread_func_arg = *(thread_arg->thread_func_arg);
        ret = thread_arg->ret;

        /* Run thread function. */
        *ret = (*thread_func)(thread_func_arg);

        num_workers_done = fetch_and_inc(thread_arg->num_workers_done) + 1;
        if (num_workers_done == *thread_arg->num_workers)
        {
            /* Everybody's done. */
#ifndef LIBFIBER
            CHECK_ERROR (sem_post (thread_arg->sem_all_workers_done));
#else
            fiber_semaphore_post(thread_arg->sem_all_workers_done);
#endif
        }
    }

#ifndef LIBFIBER
    sem_destroy (&thread_arg->sem_run);
#else
    fiber_semaphore_destroy (&thread_arg->sem_run);
#endif
    num_workers_done = fetch_and_inc(thread_arg->num_workers_done) + 1;
    if (num_workers_done == *thread_arg->num_workers)
    {
        /* Everybody's done. */
#ifndef LIBFIBER
        CHECK_ERROR (sem_post (thread_arg->sem_all_workers_done));
#else
        fiber_semaphore_post (thread_arg->sem_all_workers_done);
#endif
    }

    print_timing_stats();

    return NULL;
}
