#include<stdio.h>
#include "ci_lib.h"

void dummy(long);
ci_handler intvActionHook = dummy;

void dummy(long instruction_count) {
}

int register_ci(ci_handler ci_func) {
  intvActionHook = ci_func;
}

void deregister() {
  intvActionHook = dummy;
}

void ci_disable() {
}

void ci_enable() {
}
