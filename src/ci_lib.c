#include "ci_lib.h"

#include <stdio.h>

void dummy(long);

#define LARGE_INTERVAL 100000
#define SMALL_INTERVAL 10000

/* intvActionHook is used by the CI pass */
__thread ci_handler intvActionHook = dummy;
__thread ci_handler app_handler = dummy;
__thread uint64_t ci_ir_interval = LARGE_INTERVAL;
__thread uint64_t ci_reset_ir_interval = LARGE_INTERVAL / 2;
__thread uint64_t ci_cycles_interval =
    SMALL_INTERVAL;  // reset value is small till CI is registered
__thread uint64_t ci_cycles_threshold = (0.9 * LARGE_INTERVAL);
__thread ci_margin_hook enableHook = NULL;
__thread ci_margin_hook disableHook = NULL;

void dummy(long instruction_count) {
  // printf("Dummy called with %ld!!!!!\n", instruction_count);
}

#ifdef __cplusplus
extern "C" {
#endif

__thread int LocalLC = 0;
__thread int lc_disabled_count = 0;

static void interrupt_handler(long ir) {
  intvActionHook = dummy;
  app_handler(ir);
  intvActionHook = interrupt_handler;
}

void register_ci(int ir_interval, int cycles_interval, ci_handler ci_func) {
  app_handler = ci_func;
  /* LocalLC should be reset before resetting ci_ir_interval. Initial
   * ci_ir_interval was a large value. Therefore the current counter should be
   * incremented by the same amount to trigger an interrupt that will reset its
   * next interval */
  LocalLC += ci_ir_interval;
  ci_ir_interval = ir_interval;
  ci_reset_ir_interval = ir_interval / 2;
  ci_cycles_interval = cycles_interval;
  ci_cycles_threshold = (0.9 * cycles_interval);
  printf(
      "Using IR interval: %llu, cycles interval: %llu, "
      "IR reset value: %llu, cycles threshold: %llu\n",
      ci_ir_interval, ci_cycles_interval, ci_reset_ir_interval, ci_cycles_threshold);
  intvActionHook = interrupt_handler;
}

void deregister() {
  ci_ir_interval = LARGE_INTERVAL;
  ci_reset_ir_interval = LARGE_INTERVAL / 2;
  ci_cycles_interval = LARGE_INTERVAL;
  ci_cycles_threshold = (0.9 * LARGE_INTERVAL);
  app_handler = dummy;
  intvActionHook = dummy;
}

void register_ci_disable_hook(ci_margin_hook ci_disable_hook) { disableHook = ci_disable_hook; }

void register_ci_enable_hook(ci_margin_hook ci_enable_hook) { enableHook = ci_enable_hook; }

void ci_disable() {
  intvActionHook = dummy;
  lc_disabled_count++;
  if (disableHook) disableHook();
}

void ci_enable() {
  if (lc_disabled_count > 0) lc_disabled_count--;
  if (enableHook) enableHook();
  if (lc_disabled_count == 0) intvActionHook = interrupt_handler;
}

void instr_disable() {}

void instr_enable() {}

#ifdef __cplusplus
}
#endif
