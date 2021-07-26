#include "utility_func.h"

#include <pthread.h>

#define MAX_THREADS 64

int main(int argc, char **argv) {
  char thread_name[32];

  /* register the interrupt handler */
  register_ci(1000, 1000, interrupt_handler);

  pthread_t t[MAX_THREADS];
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
  for (int i = 0; i < (num_threads - 1); i++) {
    pthread_create(&t[i], NULL, increment, (void *)(uintptr_t)i);
    sprintf(thread_name, "inc%d", i);
    pthread_setname_np(t[i], thread_name);
  }

  for (int i = 0; i < (num_threads - 1); i++) {
    pthread_join(t[i], NULL);
  }

  printf("Starting %d decrement threads\n", num_threads);
  for (int i = 0; i < (num_threads - 1); i++) {
    pthread_create(&t[i], NULL, decrement, (void *)(uintptr_t)i);
    sprintf(thread_name, "dec%d", i);
    pthread_setname_np(t[i], thread_name);
  }

  for (int i = 0; i < (num_threads - 1); i++) {
    pthread_join(t[i], NULL);
  }

  return 0;
}
