#include "utility_func.h"

void *increment(void *arg) {
  int i;
  int counter = 0;
  int thr_no = (int)(size_t)arg;
  int iterations = BASE_VAL + (rand() % 10);
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

  /* disable CI for the remaining code */
  ci_disable();

// define this flag to check ci_enable functionality
#ifdef CHECK_ENABLE
  /* there must be as many enable calls after a fixed number of disable calls
   * to re-enable CI, more number of enable calls will not make a difference */
  ci_disable(); /* will make no difference since CI is already disabled */
  ci_enable(); /* won't be enabled yet as there were two disable calls before */
  ci_enable(); /* will enable CI again */
#endif

#ifdef CHECK_DEREGISTER
  deregister(); /* deregisters CI */
#endif

  for (i = 0; i < iterations; i++) {
    counter -= rand() % 10;
  }
  printf("decrement(): thread: %d -> counter: %d\n", thr_no, counter);
  return NULL;
}
