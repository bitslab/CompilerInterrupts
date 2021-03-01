
#ifndef INSTRUCTION_COUNTER_H
#define INSTRUCTION_COUNTER_H

#include <papi.h>

typedef void (*ic_overflow_handler_t)(int, void *, long_long, void *);

int instruction_counter_init();

int instruction_counter_register_thread();

int instruction_counter_start();

int instruction_counter_stop();

int instruction_counter_pause();

int instruction_counter_resume();

int instruction_counter_reset();

long long instruction_counter_update();

long long instruction_counter_read();

long long instruction_counter_get_max_count();

int instruction_counter_set_handler(ic_overflow_handler_t handler, int threshold);

#endif
