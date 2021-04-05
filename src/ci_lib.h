/* interrupt handler prototype */
typedef void (*ci_handler)(long);

/* prototype of function that can be called before CI is disabled or after CI is enabled in the interrupt handler */
typedef void (*ci_margin_hook)(void);

#ifdef __cplusplus
extern "C" {
#endif

/* for internal use by CI Pass - left here only for debugging */
extern __thread int lc_disabled_count;

/* register interrupt handler */
int register_ci(ci_handler func);

/* de-register interrupt handler */
void deregister();

/* register a function to be called just before CI is disabled in the interrupt handler */
void register_ci_disable_hook(ci_margin_hook ci_func);

/* register a function to be called just after CI is enabled in the interrupt handler */
void register_ci_enable_hook(ci_margin_hook ci_func);

/* disable interrupt calls */
void ci_disable();

/* enable interrupt calls */
void ci_enable();

/* disable probe instrumentation, that is, the code should be non-preemptible*/
void instr_disable();

/* enable probe instrumentation */
void instr_enable();

/* for internal use by CI Pass - left here only for debugging */
extern __thread ci_handler intvActionHook;

#ifdef __cplusplus
}
#endif
