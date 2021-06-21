#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include "ci_lib.h"

#define BASE_VAL 10000
#define MAX_THREADS 64

//#define CHECK_ENABLE
//#define CHECK_DEREGISTER

void interrupt_handler(long ic) {
  /* This print should only appear in the CI integrated build */
  static previous_ic=0;
  printf("Compiler interrupt called with instruction count %ld\n", ic-previous_ic);
  previous_ic=ic;
}

void increment(void *arg)
{
  int i;
  int counter = 0;
  int thr_no = (int)arg;
  int iterations = BASE_VAL + (rand()%10);
  for(i=0; i<iterations; i++) {
    counter += rand() % 10;
  }
  printf("Counter: %d\n", counter);
}

void decrement(void *arg)
{
  int i;
  int counter = 0;
  int thr_no = (int)arg;
  int iterations = BASE_VAL + (rand()%10);
  /* disable CI for the remaining code */
  ci_disable();

#ifdef CHECK_ENABLE // define this flag to check ci_enable functionality
  /* There must be as many enable calls after a fixed number of disable calls, to make ci work. More number of enable calls will not make a difference */
  ci_disable(); /* will make no difference since CI is already disabled */
  ci_enable(); /* won't be enabled yet since there were two disable calls before this */
  ci_enable(); /* will enable CI again */
#endif

#ifdef CHECK_DEREGISTER // define this flag to check de-register functionality
  deregister(); /* deregisters ci */
#endif

  for(i=0; i<iterations; i++) {
    counter -= rand() % 10;
  }
  printf("Counter: %d\n", counter);
}

int main(int argc, char **argv) {

  /* register interrupt handler */
  register_ci(1000, 1000, interrupt_handler);

  pthread_t t[MAX_THREADS-1];
  int num_threads = MAX_THREADS;
  if(argc==2) {
    num_threads = atoi(argv[1]);
    if(num_threads > MAX_THREADS) {
      printf("Maximum thread count exceeded. Aborting.\n");
      exit(1);
    }
  }

  printf("Starting %d increment threads\n", num_threads);
  for(int i=0; i<(num_threads-1); i++) {
    pthread_create(&t[i], NULL, (void* (*)(void*))increment, (void*)i);
  }

  for(int i=0; i<(num_threads-1); i++) {
    pthread_join(t[i], NULL);
  }

  printf("Starting %d decrement threads\n", num_threads);
  for(int i=0; i<(num_threads-1); i++) {
    pthread_create(&t[i], NULL, (void* (*)(void*))decrement, (void*)i);
  }

  for(int i=0; i<(num_threads-1); i++) {
    pthread_join(t[i], NULL);
  }

  return 0;
}
