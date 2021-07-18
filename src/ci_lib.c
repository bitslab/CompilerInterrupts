#include "ci_lib.h"

#define LARGE_INTERVAL 100000
#define SMALL_INTERVAL 10000

void dummy(long ic) {}

/* intvActionHook is used by the CI pass
 * ci_cycles_interval value is small till CI is registered */
__thread ci_handler intvActionHook = dummy;
__thread ci_handler app_handler = dummy;
__thread uint64_t ci_ir_interval = LARGE_INTERVAL;
__thread uint64_t ci_reset_ir_interval = LARGE_INTERVAL / 2;
__thread uint64_t ci_cycles_interval = SMALL_INTERVAL;
__thread uint64_t ci_cycles_threshold = 0.9 * LARGE_INTERVAL;
__thread ci_margin_hook enableHook = NULL;
__thread ci_margin_hook disableHook = NULL;

#ifdef __cplusplus
extern "C" {
#endif

/* for internal use by CI Pass */
__thread int LocalLC = 0;
__thread int lc_disabled_count = 0;

static void interrupt_handler(long ic) {
  intvActionHook = dummy;
  app_handler(ic);
  intvActionHook = interrupt_handler;
}

void register_ci(int ir_interval, int cycles_interval, ci_handler ci_func) {
  /* LocalLC should be reset before resetting ci_ir_interval.
   * ci_ir_interval was a large value initially.
   * Therefore, current counter should be incremented by the same amount
   * to trigger an interrupt that will reset its next interval. */
  LocalLC += ci_ir_interval;
  ci_ir_interval = ir_interval;
  ci_reset_ir_interval = ir_interval / 2;
  ci_cycles_interval = cycles_interval;
  ci_cycles_threshold = 0.9 * cycles_interval;

  app_handler = ci_func;
  intvActionHook = interrupt_handler;
}

void deregister_ci(void) {
  ci_ir_interval = LARGE_INTERVAL;
  ci_reset_ir_interval = LARGE_INTERVAL / 2;
  ci_cycles_interval = LARGE_INTERVAL;
  ci_cycles_threshold = 0.9 * LARGE_INTERVAL;

  app_handler = dummy;
  intvActionHook = dummy;
}

void register_ci_disable_hook(ci_margin_hook ci_disable_hook) {
  disableHook = ci_disable_hook;
}

void register_ci_enable_hook(ci_margin_hook ci_enable_hook) {
  enableHook = ci_enable_hook;
}

void ci_disable(void) {
  intvActionHook = dummy;
  lc_disabled_count++;
  if (disableHook)
    disableHook();
}

void ci_enable(void) {
  if (lc_disabled_count > 0)
    lc_disabled_count--;
  if (enableHook)
    enableHook();
  if (lc_disabled_count == 0)
    intvActionHook = interrupt_handler;
}

void instr_disable(void) {}

void instr_enable(void) {}

#ifdef __cplusplus
}
#endif
