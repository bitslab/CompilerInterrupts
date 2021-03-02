#ifndef CI_LIB
#define CI_LIB
typedef void (*ci_handler)(long);
int register_ci(ci_handler func);
void deregister();
void ci_disable();
void ci_enable();
extern __thread ci_handler intvActionHook __attribute__((used));
#endif
