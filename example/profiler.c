#define _GNU_SOURCE

#include <errno.h>
#include <perfmon/perf_event.h>
#include <perfmon/pfmlib.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ci_lib.h"
#include "util.h"

#define BASE_VAL 1000000
#define MAX_THREADS 2
#define BUF_SIZE 50000

__thread uint64_t *buffer_tsc = NULL;
__thread long *buffer_ic = NULL;
__thread unsigned int ci_count = 0;
unsigned int ci_interval = 10000;

/* the handler should only be called in the CI-integrated binary */
void interrupt_handler(long curr_ic) {
  static __thread long previous_ic = 0;
  static __thread int last_tsc = 0;
  static __thread int buf_size = BUF_SIZE;
  char thread_name[32];

  pthread_getname_np(pthread_self(), thread_name, 32);

  if (curr_ic - previous_ic < 0) {
    printf("Interval cannot be negative. Something went wrong!\n");
    exit(1);
  }

  /* calculate cycles elapsed */
  uint64_t rax_lo, rdx_hi, aux_cpuid;
  asm volatile("rdtscp\n" : "=a"(rax_lo), "=d"(rdx_hi), "=c"(aux_cpuid) : :);
  uint64_t curr_tsc = (rdx_hi << 32) + rax_lo;

  /*
  // Calculate retired instructions
  // For retired instruction count
  //
  https://software.intel.com/en-us/forums/software-tuning-performance-optimization-platform-monitoring/topic/595214
  int ecx = (1<<30);
  asm volatile("rdpmc\n" : "=a"(rax_lo), "=d"(rdx_hi) : "c"(ecx));
  uint64_t curr_ret_ic = (rax_lo | (rdx_hi << 32));
  */

  if (ci_count == buf_size) {
    buf_size += BUF_SIZE;
    buffer_tsc = realloc(buffer_tsc, buf_size * sizeof(*buffer_tsc));
    buffer_ic = realloc(buffer_ic, buf_size * sizeof(*buffer_ic));
    if (!buffer_tsc || !buffer_ic) {
      printf("Reallocation failed. Aborting!");
      exit(1);
    }
  }

  if (ci_count != 0) {
    buffer_tsc[ci_count - 1] = curr_tsc - last_tsc;
    buffer_ic[ci_count - 1] = curr_ic - previous_ic;
  }
  ci_count++;

  /* Resetting all static variables */
  previous_ic = curr_ic;
  last_tsc = curr_tsc;
}

void print_intervals() {
  int i;
  FILE *fp;
  char thread_name[32];
  char filename[64];
  pthread_getname_np(pthread_self(), thread_name, 32);
  sprintf(filename, "%s_intervals.txt", thread_name);

  deregister_ci();
  insertionSort(buffer_tsc, buffer_ic, ci_count);

  // printf("%s:- total CI: %d\n", thread_name, ci_count);

  fp = fopen(filename, "w");
  fprintf(fp, "percentile, interval(in cycles)\n");
  for (i = 0; i < ci_count - 1; i++) {
    double percentile = (double)(i) / (ci_count - 2);
    fprintf(fp, "%.5lf, %ld\n", percentile, buffer_tsc[i]);
  }

  if (ci_count > 2) {
    i = (int)((ci_count - 2) * .5);
    printf("Thread %s:- median interval: %ld cycles\n", thread_name,
           buffer_tsc[i]);
  }

  /*
  i = (int)((ci_count-2)*.1);
  printf("%s:- 90pc: %ld\n", thread_name, buffer_tsc[i]);
  i = (int)((ci_count-2)*.9);
  printf("%s:- 90pc: %ld\n", thread_name, buffer_tsc[i]);
  */

  fclose(fp);

  free(buffer_ic);
  free(buffer_tsc);
  buffer_ic = NULL;
  buffer_tsc = NULL;
}

static void pin_thread() {
  cpu_set_t cpuset;
  char thread_name[32];
  int max_cpus = sysconf(_SC_NPROCESSORS_ONLN);

  pthread_getname_np(pthread_self(), thread_name, 32);

#ifdef SYS_gettid
  int thread_id = syscall(SYS_gettid);
#else
#error "SYS_gettid unavailable on this system"
#endif
  int cpu = thread_id % (max_cpus - 1);

  CPU_ZERO(&cpuset);
  CPU_SET(cpu, &cpuset);
  pthread_t thread = pthread_self();
  int ret = pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset);
  if (ret != 0)
    printf("Unable to set thread affinity for thread %s to cpu %d. Returned: "
           "%d. Error: %s\n",
           thread_name, cpu, ret, strerror(errno));
}

void init_timer() {
  pin_thread();

  /* This setting is done per thread (using pid parameter of perf_event_open)*/
  struct perf_event_attr attr;
  memset(&attr, 0, sizeof(struct perf_event_attr));
  attr.type = PERF_TYPE_HARDWARE;
  attr.size = sizeof(struct perf_event_attr);
  attr.config = PERF_COUNT_HW_INSTRUCTIONS;
  attr.inherit = 1;
  attr.pinned = 1;
  attr.exclude_idle = 1;
  attr.exclude_kernel = 1;
  int perf_fds = perf_event_open(
      &attr, 0, -1, -1, 0); // measure counters for calling process/thread
  ioctl(perf_fds, PERF_EVENT_IOC_RESET, 0);  // Resetting counter to zero
  ioctl(perf_fds, PERF_EVENT_IOC_ENABLE, 0); // Start counters

  if (!buffer_tsc)
    buffer_tsc = (uint64_t *)calloc(BUF_SIZE, sizeof(uint64_t));
  if (!buffer_ic)
    buffer_ic = (long *)malloc(BUF_SIZE * sizeof(long));
}

void *increment(void *arg) {
  int i;
  int counter = 0;
  int thr_no = (int)(size_t)arg;
  int iterations = BASE_VAL + (rand() % 10);
  char thread_name[32];

  sprintf(thread_name, "inc%d", thr_no);
  pthread_setname_np(pthread_self(), thread_name);
  init_timer();
  register_ci(ci_interval, ci_interval, interrupt_handler);

  for (i = 0; i < iterations; i++) {
    counter += rand() % 10;
  }

  print_intervals();
  printf("increment(): thread: %d -> counter: %d\n", thr_no, counter);
  return NULL;
}

int main(int argc, char **argv) {
  /* register the interrupt handler */
  pthread_setname_np(pthread_self(), "main");
  init_timer();

  pthread_t t[MAX_THREADS];
  int num_threads = MAX_THREADS;
  if (argc == 2) {
    ci_interval = atoi(argv[1]);
    printf("Configured interrupt interval: %d IR\n", ci_interval);
  } else {
    printf("Using default interrupt interval: %d IR\nTo change the interval: "
           "./ci_profiler <interval in IR>\n",
           ci_interval);
  }

  register_ci(ci_interval, ci_interval, interrupt_handler);

  printf("Starting %d increment threads\n", num_threads);
  for (int i = 0; i < num_threads; i++) {
    pthread_create(&t[i], NULL, increment, (void *)(uintptr_t)i);
  }

  for (int i = 0; i < num_threads; i++) {
    pthread_join(t[i], NULL);
  }

  print_intervals();

  printf("Achieved intervals (in cycles) are exported to *_intervals.txt files "
         "per thread!\n");

  return 0;
}
