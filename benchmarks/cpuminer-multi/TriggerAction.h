#ifndef CI_HANDLER
#define CI_HANDLER

#include <unistd.h>
#include <stdio.h>
#include "TriggerActionDecl.h"

uint64_t total_hashes = 0;
//uint64_t total_hashes2 = 0;
struct timeval g_tv_start;
__thread unsigned long timeofday;

#ifdef CI
  #include <rte_ethdev.h>
  #include <rte_lcore.h>

  /* For Shenango */
  #include <base/init.h>
  #include <base/log.h>
  #include <base/stddef.h>

  #include "defs.h"

  #ifdef STATS
  uint64_t next_log_time;
  #endif
  uint64_t last_time;
  uint64_t last_printed_time;

  #define CORES_ADJUST_INTERVAL_US	5
  #define LOG_INTERVAL_US		(1000 * 1000)
  struct dataplane dp;

  struct init_entry {
    const char *name;
    int (*init)(void);
  };

  #define IOK_INITIALIZER(name) \
    {__cstr(name), &name ## _init}

  /* iokernel subsystem initialization */
  static const struct init_entry iok_init_handlers[] = {
    /* base */
    IOK_INITIALIZER(base),

    /* general iokernel */
    IOK_INITIALIZER(cores),

    /* control plane */
    IOK_INITIALIZER(control),

    /* data plane */
    IOK_INITIALIZER(dpdk),
    IOK_INITIALIZER(rx),
    IOK_INITIALIZER(tx),
    IOK_INITIALIZER(dp_clients),
    IOK_INITIALIZER(dpdk_late),
  };

  static pthread_t mine_thread; 

  static int run_init_handlers(const char *phase, const struct init_entry *h,
      int nr)
  {
    int i, ret;

    printf("ENTERING '%s' init phase\n", phase);
    for (i = 0; i < nr; i++) {
      printf("INIT -> %s\n", h[i].name);
      ret = h[i].init();
      if (ret) {
        printf("FAILED, ret = %d", ret);
        return ret;
      }
    }

    return 0;
  }

  void dummy(long ic) {
  }

  static int get_ir_interval() {
    char *ir_interval = getenv("CI_IR_INTERVAL");
    assert(ir_interval && "CI_IR_INTERVAL environment variable is not set!");
    int interval = atoi(ir_interval);
    assert(interval>0 && "CI_IR_INTERVAL cannot be less than or equal to 0!");
    return interval;
  }

  static int get_cycles_interval() {
    char *cycles_interval = getenv("CI_CYCLES_INTERVAL");
    assert(cycles_interval && "CI_CYCLES_INTERVAL environment variable is not set!");
    int interval = atoi(cycles_interval);
    assert(interval>0 && "CI_CYCLES_INTERVAL cannot be less than or equal to 0!");
    return interval;
  }

  __thread static int debug_print=0;
  void compiler_interrupt_handler(long ic) {

#if 0
    if(pthread_self() != mine_thread) {
      char th_name[128];
      pthread_getname_np(pthread_self(), th_name, 128);
      printf("Wrong thread is calling CI Handler-> curr thread: %lu (%s), mine_thread: %lu. Aborting.\n", pthread_self(), th_name, mine_thread);
      exit(1);
    }
#endif
    bool work_done;
    //int accumulator=0;
    uint64_t now;

    static bool first = true;
    if(first)
      timeofday = (unsigned long)time(NULL);
    else
      first = false;

#ifdef PROFILE
    if(debug_print==0) {
      struct timeval tv_end;
      gettimeofday(&tv_end, NULL);
      double diff_sec = (double)((tv_end.tv_sec - g_tv_start.tv_sec)*1000000 + (tv_end.tv_usec - g_tv_start.tv_usec))/1000000;
      printf("Data plane in CI called after %lf sec from start\n", diff_sec);
    }
    if(debug_print==1000000)
      debug_print=0;
    else
      debug_print++;

#else

    /* Shenango code */
    do {
      work_done = false;

      //printf("Data plane in CI\n");
      /* handle a burst of ingress packets */
      work_done |= rx_burst();

      /* handle control messages */
      if (!work_done)
        dp_clients_rx_control_lrpcs();

      now = microtime();

      /* adjust core assignments */
      if (now - last_time > CORES_ADJUST_INTERVAL_US) {
        cores_adjust_assignments();
        last_time = now;
      }

      /* Print hashrate every second */
      if(now - last_printed_time > LOG_INTERVAL_US) {
			  double hashrate =
				  total_hashes / ((now - last_printed_time) * 1e-6);
        /* Hashrate in KH/s, hashes in last second, duration in ms */
        //printf("Hashrate: %lu, %lu, %.0f, %lu, %f\n", (unsigned long)time(NULL), timeofday++, hashrate / 1e3, total_hashes, (now - last_printed_time) * 1e-3);
        printf("Hashrate: %lu, %.2f\n", timeofday++, hashrate / 1e3);
        total_hashes = 0;
        last_printed_time = now;
      }

      /* process a batch of commands from runtimes */
      work_done |= commands_rx();

      /* drain overflow completion queues */
      work_done |= tx_drain_completions();

      /* send a burst of egress packets */
      work_done |= tx_burst();

      STAT_INC(BATCH_TOTAL, IOKERNEL_RX_BURST_SIZE);

      #ifdef STATS
      if (microtime() > next_log_time) {
        print_stats();
        dpdk_print_eth_stats();
        next_log_time += LOG_INTERVAL_US;
      }
      #endif

#if 0
      if(work_done)
        accumulator++;
      else
        accumulator=accumulator/2;
#endif
    } while (work_done);
    //} while (accumulator);
#endif
  }

#endif

void init_stats() {
  //total_hashes=0;
  gettimeofday((struct timeval *) &g_tv_start, NULL);
#ifdef CI
  static bool first = true;
  printf("CI version of miner is running\n");
  if(!intvActionHook) {
    printf("intvActionHook is not present in module!\n");
    exit(1);
  }

  //if(first) {
    first = false;
    int ret = run_init_handlers("iokernel", iok_init_handlers,
        ARRAY_SIZE(iok_init_handlers));
    if (ret) {
      printf("IOKernel init handlers failed. Exiting.");
      exit(0);
    }

    #ifdef STATS
    next_log_time = microtime();
    #endif
    last_time = microtime();

    /*
     * Check that the port is on the same NUMA node as the polling thread
     * for best performance.
     */
    printf("DPDK port: %d\n", dp.port);
    if (rte_eth_dev_socket_id(dp.port) > 0
        && rte_eth_dev_socket_id(dp.port) != (int) rte_socket_id())
      printf("main: port %u is on remote NUMA node to polling thread (%d).\n\t"
          "Performance will not be optimal.", dp.port, (int) rte_socket_id());

    printf("main: core %u running dataplane. [Ctrl+C to quit]",
        rte_lcore_id());

    //register_ci(compiler_interrupt_handler);
  //}
  //else {
    //register_ci(dummy);
  //}
  mine_thread = pthread_self();
  printf("CREATED MINER THREAD(%lu) CI\n", mine_thread);
  register_ci(get_ir_interval(), get_cycles_interval(), &compiler_interrupt_handler);
#else
  printf("Original version of miner is running\n");
#endif
}

void init_stats_others() {
  //total_hashes=0;
  gettimeofday((struct timeval *) &g_tv_start, NULL);
#ifdef CI
  printf("CI version of other threads(%lu) are running\n", pthread_self);
    if(!intvActionHook) {
      printf("intvActionHook is not present in module!\n");
      exit(1);
    }
    #ifdef STATS
    //next_log_time = microtime();
    #endif
    //last_time = microtime();
  //register_ci(compiler_interrupt_handler);
  //register_ci(dummy);
#else
  printf("Original version of threads are running\n");
#endif
}

#endif
