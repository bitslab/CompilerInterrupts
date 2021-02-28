// C program for array implementation of queue

#ifndef _SPEC_FIFO_QUEUE_H_
#define _SPEC_FIFO_QUEUE_H_

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <stdint.h>
#include <assert.h>

#define MAX_LOCKS_AVAILABLE 1000
 
// A structure to represent a queue
typedef struct Queue
{
    int front, rear, size;
    unsigned capacity;
    uint64_t * array;
    int is_available;
    uint64_t holding_fiber;
    char padding[128 - 20];

} lock_fifo_queue;
 
// function to create a queue of given capacity. 
// It initializes size of queue as 0
static inline void initQueue(lock_fifo_queue** queue, unsigned capacity)
{
    lock_fifo_queue* the_queue = (lock_fifo_queue*) malloc(sizeof(lock_fifo_queue));
    assert(the_queue);
    the_queue->capacity = capacity;
    the_queue->front = the_queue->size = 0; 
    the_queue->rear = capacity - 1;
    the_queue->is_available = 1;
    // make the_queue->array allocation 128-byte alligned
    the_queue->array = (uint64_t*) malloc(((the_queue->capacity & ~0x0f)+16) * sizeof(uint64_t));
    int i;
    for(i=0; i<the_queue->capacity; i++){
        the_queue->array[i] = 0;
    }

    *queue = the_queue;

    return;
}
 
// Queue is full when size becomes equal to the capacity 
static inline int isFull(lock_fifo_queue* queue)
{  return (queue->size == queue->capacity);  }
 
// Queue is empty when size is 0
static inline int isEmpty(lock_fifo_queue* queue)
{  return (queue->size == 0); }
 
// Function to add an item to the queue.  
// It changes rear and size
static inline void enqueue(lock_fifo_queue* queue, uint64_t item)
{
    assert(!isFull(queue));
    queue->rear = (queue->rear + 1)%queue->capacity;
    queue->array[queue->rear] = item;
    queue->size = queue->size + 1;
}
 
// Function to remove an item from queue. 
// It changes front and size
static inline uint64_t dequeue(lock_fifo_queue* queue)
{
    if (isEmpty(queue))
        return 0;
    uint64_t item = queue->array[queue->front];
    queue->array[queue->front] = 0;
    queue->front = (queue->front + 1)%queue->capacity;
    queue->size = queue->size - 1;
    return item;
}

static inline uint64_t read_front_of_queue(lock_fifo_queue* queue)
{
    if (isEmpty(queue))
        return 0;
    return queue->array[queue->front];
}

#endif
 