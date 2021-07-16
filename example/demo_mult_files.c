#include <pthread.h>
#include "utility_func.h"

#define MAX_THREADS 64

void interrupt_handler(long ic) {
  /* This print should only appear in the CI integrated build */
  static long previous_ic=0;
  printf("Compiler interrupt called with instruction count %ld\n", ic-previous_ic);
  previous_ic=ic;
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
    pthread_create(&t[i], NULL, (void* (*)(void*))increment, (void*)&i);
  }

  for(int i=0; i<(num_threads-1); i++) {
    pthread_join(t[i], NULL);
  }

  printf("Starting %d decrement threads\n", num_threads);
  for(int i=0; i<(num_threads-1); i++) {
    pthread_create(&t[i], NULL, (void* (*)(void*))decrement, (void*)&i);
  }

  for(int i=0; i<(num_threads-1); i++) {
    pthread_join(t[i], NULL);
  }

  return 0;
}
