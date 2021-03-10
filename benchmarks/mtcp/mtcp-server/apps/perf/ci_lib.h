typedef void (*ci_handler)(long);
int register_ci(ci_handler func);
void deregister();
void ci_disable();
void ci_enable();
ci_handler intvActionHook;
