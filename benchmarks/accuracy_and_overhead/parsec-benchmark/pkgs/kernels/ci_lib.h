typedef void (*ci_handler)(long);
extern ci_handler intvActionHook;

extern "C" int register_ci(ci_handler func);
void deregister();
void ci_disable();
void ci_enable();
