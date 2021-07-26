#define _GNU_SOURCE

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

#include "ci_lib.h"

#define BASE_VAL 1000000
#define MAX_THREADS 64

// define this flag to check ci_enable functionality
// #define CHECK_ENABLE

// define this flag to check de-register functionality
// #define CHECK_DEREGISTER

/* the handler should only be called in the CI-integrated binary */
void interrupt_handler(long ic) {
  /* This print should only appear in the CI integrated build */
  static __thread long previous_ic = 0;
  char thread_name[32];
  pthread_getname_np(pthread_self(), thread_name, 32);

  if (ic - previous_ic < 0) {
    printf("Interval cannot be negative. Something went wrong!\n");
    exit(1);
  }

  printf("CI @ %s: last interval = %ld IR\n", thread_name, ic - previous_ic);
  previous_ic = ic;
}

void pre_disable() {
  printf("This function is being called before ci_disable()\n");
}

void post_enable() {
  printf("This function is being called after ci_enable()\n");
}

void *increment(void *arg) {
  int i;
  int counter = 0;
  int thr_no = (int)(size_t)arg;
  int iterations = BASE_VAL + (rand() % 10);
  register_ci(10000, 10000, interrupt_handler);

  for (i = 0; i < iterations; i++) {
    counter += rand() % 10;
  }
  printf("increment(): thread: %d -> counter: %d\n", thr_no, counter);
  return NULL;
}

void *decrement(void *arg) {
  int i;
  int counter = 0;
  int thr_no = (int)(size_t)arg;
  int iterations = BASE_VAL + (rand() % 10);
  register_ci(10000, 10000, interrupt_handler);

  /* temporarily disable CI for the remaining code */
  ci_disable();

#ifdef CHECK_ENABLE
  /* register CI hooks */
  register_ci_disable_hook(pre_disable);
  register_ci_enable_hook(post_enable);

  /* there must be as many enable calls after a fixed number of disable calls
   * to re-enable CI, more number of enable calls will not make a difference */
  ci_disable(); /* will make no difference since CI is already disabled */
  ci_enable(); /* won't be enabled yet as there were two disable calls before */
  ci_enable(); /* will enable CI again */
#endif

#ifdef CHECK_DEREGISTER
  deregister_ci(); /* deregisters CI */
#endif

  for (i = 0; i < iterations; i++) {
    counter -= rand() % 10;
  }
  printf("decrement(): thread: %d -> counter: %d\n", thr_no, counter);
  return NULL;
}

int main(int argc, char **argv) {
  /* register the interrupt handler */
  register_ci(1000, 1000, interrupt_handler);

  pthread_t t1[MAX_THREADS];
  pthread_t t2[MAX_THREADS];
  char thread_name[32];
  int num_threads = 2;
  if (argc == 2) {
    num_threads = atoi(argv[1]);
    if (num_threads > MAX_THREADS) {
      printf("Maximum thread count exceeded. Aborting...\n");
      exit(1);
    }
  }

  pthread_setname_np(pthread_self(), "main");

  printf("Starting %d increment threads\n", num_threads);
  for (int i = 0; i < num_threads; i++) {
    pthread_create(&t1[i], NULL, increment, (void *)(uintptr_t)i);
    sprintf(thread_name, "inc%d", i);
    pthread_setname_np(t1[i], thread_name);
  }

  printf("Starting %d decrement threads\n", num_threads);
  for (int i = 0; i < num_threads; i++) {
    pthread_create(&t2[i], NULL, decrement, (void *)(uintptr_t)i);
    sprintf(thread_name, "dec%d", i);
    pthread_setname_np(t2[i], thread_name);
  }

  for (int i = 0; i < num_threads; i++) {
    pthread_join(t1[i], NULL);
  }

  for (int i = 0; i < num_threads; i++) {
    pthread_join(t2[i], NULL);
  }

  return 0;
}
