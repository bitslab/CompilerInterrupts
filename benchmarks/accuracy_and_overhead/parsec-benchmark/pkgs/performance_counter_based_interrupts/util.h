#ifndef HUGEPAGE_META_UTIL_H
#define HUGEPAGE_META_UTIL_H

#include <unistd.h>
#include <sys/syscall.h>

#define MAX_THREADS 4096

static inline pid_t util_get_tid(){
#ifdef SYS_gettid
    pid_t tid = syscall(SYS_gettid);
#else
    #error "SYS_gettid unavailable on this system"
#endif
    return tid;
}

#define MIN(x,y) ((x < y) ? x : y)

#define MAX(x,y) ((x > y) ? x : y)

static inline void print_bytes(char * x, int l) {
    for (int i = 0;i < l;i++) {
	fprintf(stderr, "%x:", x[i] & 0xff);
    }
    fprintf(stderr, "\n");
} 

static inline unsigned long time_us_diff(struct timespec * start, struct timespec * end){
    return ((end->tv_sec*1000000UL)+(end->tv_nsec/1000UL)) - 
		((start->tv_sec*1000000UL)+(start->tv_nsec/1000UL));
}

static inline unsigned long time_ms_diff(struct timespec * start, struct timespec * end){
    return ((end->tv_sec*1000UL)+(end->tv_nsec/1000000UL)) - 
		((start->tv_sec*1000UL)+(start->tv_nsec/1000000UL));
}


#endif


