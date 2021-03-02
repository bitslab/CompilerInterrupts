/*
 * main.c - initialization and main dataplane loop for the iokernel
 */

#include <rte_ethdev.h>
#include <rte_lcore.h>

#include <base/init.h>
#include <base/log.h>
#include <base/stddef.h>

#include "defs.h"

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

static int run_init_handlers(const char *phase, const struct init_entry *h,
		int nr)
{
	int i, ret;

	log_debug("ENTERING '%s' init phase with %d INIT HANDLERS", phase, nr);
	for (i = 0; i < nr; i++) {
		log_debug("INIT (%d) -> %s", i, h[i].name);
		ret = h[i].init();
		if (ret) {
			log_debug("failed, ret = %d\n", ret);
			return ret;
		}
		log_debug("FINISHED INIT (%d) -> %s", i, h[i].name);
	}

	return 0;
}

/*
 * The main dataplane thread.
 */
void dataplane_loop()
{
	bool work_done;
#ifdef STATS
	uint64_t next_log_time = microtime();
#endif
	uint64_t now, last_time = microtime();

	/*
	 * Check that the port is on the same NUMA node as the polling thread
	 * for best performance.
	 */
	if (rte_eth_dev_socket_id(dp.port) > 0
			&& rte_eth_dev_socket_id(dp.port) != (int) rte_socket_id())
		log_warn("main: port %u is on remote NUMA node (%d) to polling thread.\n"
        "Current socket id: %d\n\t"
				"Performance will not be optimal.", dp.port, rte_eth_dev_socket_id(dp.port), rte_socket_id());

	log_info("main: core %u running dataplane. [Ctrl+C to quit]",
			rte_lcore_id());

	/* run until quit or killed */
	for (;;) {
		work_done = false;

		/* handle a burst of ingress packets */
		work_done |= rx_burst();

		/* handle control messages */
		if (!work_done)
			dp_clients_rx_control_lrpcs();

		now = microtime();

		/* adjust core assignments */
		if (now - last_time > CORES_ADJUST_INTERVAL_US) {
#ifdef DBG
      core_adjustment_cnt++;
#endif
			cores_adjust_assignments();
			last_time = now;
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
	}
}

#ifdef DBG
#include<signal.h>
int congested1 = 0;
int congested2 = 0;
int congested3 = 0;
int congested4 = 0;

int core_add1 = 0;
int core_add2 = 0;
int core_add3 = 0;
int core_add4 = 0;
int active_thrds = 0;
int total_core_alloc = 0;
int preempt_sig = 0;
int iok_park_thr = 0;
int iok_park_tx_pending = 0;
int iok_wakeup_thr = 0;
int gcores = 0;
unsigned long int core_adjustment_cnt = 0;

void signal_handler(int sig) {
  switch (sig) {
    case SIGINT:
      printf("SIGINT Received!\n");
      printf("Core added stats (total %d): %d, %d, %d, %d\n", total_core_alloc, 
          core_add1, core_add2, core_add3, core_add4);
      printf("Average active threads when there is congestion is approx 1. Max active thread: %d, guaranteed cores: %d\n", active_thrds, gcores); 
      printf("Congestion stats: %d, %d, %d, %d\n", 
          congested1, congested2, congested3, congested4);
      printf("Number of time core adjustments were tried: %lu\n", core_adjustment_cnt);
      printf("#parked thr: %d (leads to decrease in active threads), #parked thr pending tx packets: %d (thread_cede())\n", iok_park_thr, iok_park_tx_pending);
      printf("#woken up thr: %d (leads to increase in active threads) + preempt case increase on next line (thread_reserve())\n", iok_wakeup_thr);
      printf("Sent SigKill for preemption: %d times\n", preempt_sig);
      exit(0);
      break;
  }
}
#endif

int main(int argc, char *argv[])
{
	int ret;

#ifdef DBG
  signal(SIGINT, signal_handler);
#endif

	ret = run_init_handlers("iokernel", iok_init_handlers,
			ARRAY_SIZE(iok_init_handlers));
	if (ret)
		return ret;

	dataplane_loop();
	return 0;
}
