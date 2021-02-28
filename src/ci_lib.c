#include<stdio.h>
#include "ci_lib.h"

void dummy(long);

__thread ci_handler intvActionHook = &dummy;
__thread ci_margin_hook enableHook = NULL;
__thread ci_margin_hook disableHook = NULL;

void dummy(long instruction_count) {
}

#ifdef __cplusplus
extern "C" {
#endif

__thread int lc_disabled_count = 0;

int register_ci(ci_handler ci_func) {
  intvActionHook = ci_func;
}

void deregister() {
  intvActionHook = dummy;
}

void register_ci_disable_hook(ci_margin_hook ci_func) {
  disableHook = ci_func;
}

void register_ci_enable_hook(ci_margin_hook ci_func) {
  enableHook = ci_func;
}

void ci_disable() {
  lc_disabled_count++;
  if(disableHook)
    disableHook();
}

void ci_enable() {
  if(lc_disabled_count > 0)
    lc_disabled_count--;
  if(enableHook)
    enableHook();
}

void instr_disable() {
}

void instr_enable() {
}

#ifdef __cplusplus
}
#endif
