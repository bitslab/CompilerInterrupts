#define _GNU_SOURCE

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

#include "ci_lib.h"

#define BASE_VAL 1000000

void interrupt_handler(long ic);
void *increment(void *arg);
void *decrement(void *arg);
