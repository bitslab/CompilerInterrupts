#include "utility_func.h"

/* the handler should only be called in the CI-integrated binary */
void interrupt_handler(long ic) {
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
  ci_disable();

// define this flag to check ci_enable functionality
#ifdef CHECK_ENABLE
  /* register CI hooks */
  register_ci_disable_hook(pre_disable);
  register_ci_enable_hook(post_enable);

  /* disable CI for the remaining code */
  ci_disable();

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
