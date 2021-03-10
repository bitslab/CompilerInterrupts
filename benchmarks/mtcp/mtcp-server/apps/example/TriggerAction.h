#include <unistd.h>
#include "mtcp_api.h"
#include "TriggerActionDecl.h"

void init_stats() {
#ifdef CI
  printf("CI version of app is running\n");
  register_ci(compiler_interrupt_handler);
#else
  printf("Original version of app is running\n");
#endif
}

void compiler_interrupt_handler(long ic) {
  if(mtcp_ctx && (void *)mtcp_ctx->mtcp_thr_ctx) {
    //printf("Calling CI RunMainLoop, mtcp context: %p\n", (void *)(mtcp_ctx->mtcp_thr_ctx));
    RunMainLoop((void *)mtcp_ctx->mtcp_thr_ctx);
  }
  else
    printf("MTCP context not initialized yet\n");
}
