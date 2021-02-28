typedef void (*ci_handler)(long);
typedef void (*ci_margin_hook)(void);

#ifdef __cplusplus
extern "C" {
#endif

extern __thread int lc_disabled_count;
int register_ci(ci_handler func);
void deregister();
void register_ci_disable_hook(ci_margin_hook ci_func);
void register_ci_enable_hook(ci_margin_hook ci_func);
void ci_disable();
void ci_enable();
void instr_disable();
void instr_enable();
extern __thread ci_handler intvActionHook;

#ifdef __cplusplus
}
#endif
