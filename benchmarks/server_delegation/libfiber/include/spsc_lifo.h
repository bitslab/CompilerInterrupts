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

#ifndef _SPSC_LIFO_H_
#define _SPSC_LIFO_H_
// test
/*
    Author: Brian Watling
    Email: brianwatling@hotmail.com
    Website: https://github.com/brianwatling

    Description: A single-producer single-consumer LIFO based on "Writing Lock-Free
                 Code: A Corrected Queue" by Herb Sutter. The node passed
                 into the push method is owned by the LIFO until it is returned
                 to the consumer via the pop method. This LIFO is wait-free.
                 NOTE: This SPSC LIFO provides strict LIFO ordering

    Properties: 1. Strict LIFO
                2. Wait free
*/

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "machine_specific.h"

typedef struct spsc_lifo_node
{
    void* data;
    struct spsc_lifo_node* volatile prev;
    char dummy[128-16];
} spsc_lifo_node_t;

typedef struct spsc_lifo
{
    spsc_lifo_node_t* tail;//consumer read items from tail
    char _cache_padding1[CACHE_SIZE - sizeof(spsc_lifo_node_t*)];
    spsc_lifo_node_t* head;//producer pushes onto the head
} spsc_lifo_t;

static inline int spsc_lifo_init(spsc_lifo_t* f)
{
    assert(f);
    f->head = NULL; //(spsc_lifo_node_t*)calloc(1, sizeof(*f->head));
    f->tail = f->head;
    if(!f->head) {
        return 0;
    }
    return 1;
}

static inline void spsc_lifo_destroy(spsc_lifo_t* f)
{
    if(f) {
        while(f->head != NULL) {
            spsc_lifo_node_t* const tmp = f->head;
            f->head = tmp->prev;
            free(tmp);
        }
    }
}

//the LIFO owns new_node after pushing
static inline void spsc_lifo_push(spsc_lifo_t* f, spsc_lifo_node_t* new_node)
{
    assert(f);
    assert(new_node);
    // new_node->prev = NULL;
    // write_barrier();//the node must be terminated before it's visible to the reader as the new head
    spsc_lifo_node_t* const prev_head = f->head;
    f->head = new_node;
    new_node->prev = prev_head;
}

//the caller owns the node after popping
static inline spsc_lifo_node_t* spsc_lifo_trypop(spsc_lifo_t* f)
{
    assert(f);
    spsc_lifo_node_t* const prev_head = f->head;
    if(prev_head) {
        spsc_lifo_node_t* const prev_head_prev = prev_head->prev;
        f->head = prev_head_prev;
        return prev_head;
    }
    return NULL;
}

#endif

