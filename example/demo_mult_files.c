#include "utility_func.h"

#include <pthread.h>

#define MAX_THREADS 64

/* the handler should only be called in the CI-integrated binary */
void interrupt_handler(long ic) {
  __thread static long previous_ic = 0;
  printf("CI: last interval = %ld IR\n", ic - previous_ic);
  previous_ic = ic;
}

int main(int argc, char **argv) {
  /* register the interrupt handler */
  register_ci(1000, 1000, interrupt_handler);

  pthread_t t[MAX_THREADS - 1];
  int num_threads = MAX_THREADS;
  if (argc == 2) {
    num_threads = atoi(argv[1]);
    if (num_threads > MAX_THREADS) {
      printf("Maximum thread count exceeded. Aborting...\n");
      exit(1);
    }
  }

  printf("Starting %d increment threads\n", num_threads);
  for (int i = 0; i < (num_threads - 1); i++) {
    pthread_create(&t[i], NULL, increment, (void *)(uintptr_t)i);
  }

  for (int i = 0; i < (num_threads - 1); i++) {
    pthread_join(t[i], NULL);
  }

  printf("Starting %d decrement threads\n", num_threads);
  for (int i = 0; i < (num_threads - 1); i++) {
    pthread_create(&t[i], NULL, decrement, (void *)(uintptr_t)i);
  }

  for (int i = 0; i < (num_threads - 1); i++) {
    pthread_join(t[i], NULL);
  }

  return 0;
}
