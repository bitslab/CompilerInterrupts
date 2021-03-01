#include <papi.h>
#include <pthread.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>

#include "instructionCounter.h"
#include "util.h"

#define num_hwcntrs  1
#define ins_counter_index 0

static __thread int events[num_hwcntrs] = { PAPI_TOT_INS };
static int event_set[MAX_THREADS];
static __thread long long counter_values[num_hwcntrs] = { 0LL };
static long long current_ins_count[MAX_THREADS];
static __thread int counter_id;
static __thread long long stopped_counter = 0;
static int counter_id_alloc = 0;

int __get_id_and_increment(){
    //using the gcc atomic built-ins
    return __sync_fetch_and_add(&counter_id_alloc, 1);
}

int instruction_counter_init(){
    int retval = PAPI_library_init( PAPI_VER_CURRENT );
    //set my id
    counter_id = __get_id_and_increment();
    //clear counters
    memset(current_ins_count, 0, sizeof(long long) * MAX_THREADS);
    memset(event_set, PAPI_NULL, sizeof(int) * MAX_THREADS);

    if ( retval != PAPI_VER_CURRENT ){
	perror("PAPI: library failed...");
	return -1;
    }
    if (PAPI_thread_init(pthread_self) != PAPI_OK) {
	perror("PAPI: failed to init thread...");
	return -1;
    }
    /*set domain*/
    if (PAPI_set_domain(PAPI_DOM_USER) != PAPI_OK) {
	perror("PAPI: domain set failed...");
	return -1;
    }
    
    /* Create an EventSet */ 
    if (PAPI_create_eventset(&event_set[counter_id]) != PAPI_OK) {
	perror("PAPI: event set failed...");
	return -1;
    }

    if (PAPI_add_event(event_set[counter_id], PAPI_TOT_INS) != PAPI_OK) {
	perror("PAPI: add event failed...");
	return -1;
    }

    return 0;
}

int __reset() {
    if (PAPI_reset(event_set[counter_id]) != PAPI_OK){
	perror("PAPI: failed to read counter...");
	return -1;
    }
    else{
	return 0;
    }
}

int instruction_counter_register_thread(){
    counter_id = __get_id_and_increment();
    PAPI_register_thread();
    /*set domain*/
    if (PAPI_set_domain(PAPI_DOM_USER) != PAPI_OK) {
	perror("PAPI: domain set failed...");
	return -1;
    }
    /* Create an EventSet */ 
    if (PAPI_create_eventset(&event_set[counter_id]) != PAPI_OK) {
	perror("PAPI: event set failed...");
	return -1;
    }

    if (PAPI_add_event(event_set[counter_id], PAPI_TOT_INS) != PAPI_OK) {
	perror("PAPI: add event failed...");
	return -1;
    }
}

int instruction_counter_start() {
    if (PAPI_start(event_set[counter_id]) != PAPI_OK) {
	perror("PAPI: failed to start counter...");
	return -1;
    }
    return 0;
}

int instruction_counter_stop() {
    if (PAPI_stop(event_set[counter_id], counter_values) != PAPI_OK) {
	perror("PAPI: failed to stop counter...");
	return -1;
    }
    return 0;
}

long long instruction_counter_update(){
    if (PAPI_read(event_set[counter_id], counter_values) != PAPI_OK){
	perror("PAPI: failed to read counter...");
	return -1;
    }
    assert(counter_values[ins_counter_index] >= 0);
    current_ins_count[counter_id] += counter_values[ins_counter_index];
    __reset();
    return current_ins_count[counter_id];
}

long long instruction_counter_read(){
    return current_ins_count[counter_id];
}

long long instruction_counter_get_max_count(){
    assert(counter_id_alloc < MAX_THREADS);
    assert(counter_id_alloc > 0);

    long long max = 0;
    for (int i = 0; i < counter_id_alloc; i++) {
	if (current_ins_count[i] > max) {
	    max = current_ins_count[i];
	}
    }
    return max;
}

int instruction_counter_pause(){ 
    //NOP
    return 0;
}

int instruction_counter_resume(){
    return __reset();
}

int instruction_counter_reset(){
    return __reset();
}


int instruction_counter_set_handler(ic_overflow_handler_t handler, int threshold){

    if (threshold == 0 && stopped_counter == 1) {
	return 0;
    }
    else if (threshold == 0) {
	stopped_counter = 1;
    }    
    else{
	stopped_counter = 0;
    }
    if (PAPI_overflow(event_set[counter_id], PAPI_TOT_INS, threshold, 0, handler) != PAPI_OK){
	perror("PAPI: failed to stop counter...");
	return -1;
    }
    else{
	return 0;
    }
}
