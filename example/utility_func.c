#include "utility_func.h"

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
