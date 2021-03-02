/*
 * stat.c - support for statistics and counters
 */

#include <string.h>
#include <stdio.h>
#include <sys/time.h>

#include <base/stddef.h>
#include <base/log.h>
#include <base/time.h>
#include <runtime/thread.h>
#include <runtime/udp.h>

#include "defs.h"

/* port 40 is permanently reserved, so should be fine for now */
#define STAT_PORT	40

static struct kthread *allks[NCPU];
static unsigned int nrallks;
static DEFINE_SPINLOCK(stat_lock);
static FILE *stat_fp = NULL;
static FILE *stat_cumulative_fp = NULL;
static uint64_t prev_stats[STAT_NR] = {0};

static const char *stat_names[] = {
	/* scheduler counters */
	"reschedules_per_sec",
	"sched_cycles_per_sec",
	"program_cycles_per_sec",
	"threads_stolen_per_sec",
	"softirqs_stolen_per_sec",
	"softirqs_local_per_sec",
	"parks_per_sec",
	"preemptions_per_sec",
	"preemptions_stolen_per_sec",
	"core_migrations_per_sec",

	/* network stack counters */
	"rx_bytes_per_sec",
	"rx_packets_per_sec",
	"tx_bytes_per_sec",
	"tx_packets_per_sec",
	"drops_per_sec",
	"rx_tcp_in_order_per_sec",
	"rx_tcp_out_of_order_per_sec",
	"rx_tcp_text_cycles_per_sec",
};

static const char *stat_cumulative_names[] = {
	/* scheduler counters */
	"reschedules",
	"sched_cycles",
	"program_cycles",
	"threads_stolen",
	"softirqs_stolen",
	"softirqs_local",
	"parks",
	"preemptions",
	"preemptions_stolen",
	"core_migrations",

	/* network stack counters */
	"rx_bytes",
	"rx_packets",
	"tx_bytes",
	"tx_packets",
	"drops",
	"rx_tcp_in_order",
	"rx_tcp_out_of_order",
	"rx_tcp_text_cycles",
};

/* must correspond exactly to STAT_* enum definitions in defs.h */
BUILD_ASSERT(ARRAY_SIZE(stat_names) == STAT_NR);
BUILD_ASSERT(ARRAY_SIZE(stat_cumulative_names) == STAT_NR);

static void print_stat_header()
{
  int i;
	for (i = 0; i < STAT_NR; i++) {
	  fprintf(stat_fp, "%s,", stat_names[i]);
	  fprintf(stat_cumulative_fp, "%s,", stat_cumulative_names[i]);
  }
	fprintf(stat_fp, "cycles_per_us\n");
	fprintf(stat_cumulative_fp, "cycles_per_us\n");
}

#if 1
static int append_stat(FILE *fp, const char *name, uint64_t val, bool last_stat)
{
	//snprintf(pos, len, "%s:%ld,", name, val);
  if(last_stat) {
	  return fprintf(fp, "%ld\n", val);
    fflush(fp);
  }
  else
	  return fprintf(fp, "%ld,", val);
}
#else
static int append_stat(char *pos, size_t len, const char *name, uint64_t val, bool last_stat)
{
	snprintf(pos, len, "%s:%ld,", name, val);
}
#endif

static ssize_t stat_write_buf(char *buf, size_t len, int elapsed_sec)
{
	uint64_t stats[STAT_NR];
	uint64_t stats_per_sec[STAT_NR];
	char *pos = buf, *end = buf + len;
	int i, j, ret;

	memset(stats, 0, sizeof(stats));
	memset(stats_per_sec, 0, sizeof(stats_per_sec));

	/* gather stats from each kthread */
	/* FIXME: not correct when parked kthreads removed from @ks */
	for (i = 0; i < nrallks; i++) {
		for (j = 0; j < STAT_NR; j++)
			stats[j] += allks[i]->stats[j];
	}

#if 1
  for(i = 0; i < STAT_NR; i++) {
    stats_per_sec[i] = (stats[i] - prev_stats[i])/elapsed_sec;
    prev_stats[i] = stats[i];
  }
#endif

	/* write out the stats to the buffer */
	for (j = 0; j < STAT_NR; j++) {
	  //ret = append_stat(pos, end - pos, stat_names[j], stats[j], false);
		ret = append_stat(stat_fp, stat_names[j], stats_per_sec[j], false);
		ret = append_stat(stat_cumulative_fp, stat_cumulative_names[j], stats[j], false);
		if (ret < 0) {
			return -EINVAL;
		} else if (ret >= end - pos) {
			return -E2BIG;
		}
		pos += ret;
	}

	/* report the clock rate */
	//ret = append_stat(pos, end - pos, "cycles_per_us", cycles_per_us, true);
	ret = append_stat(stat_fp, "cycles_per_us", cycles_per_us, true);
	ret = append_stat(stat_cumulative_fp, "cycles_per_us", cycles_per_us, true);
	if (ret < 0) {
		return -EINVAL;
	} else if (ret >= end - pos) {
		return -E2BIG;
	}

	pos += ret;
	//pos[-1] = '\0'; /* clip off last ',' */
  //fprintf(stat_fp, "\n");
	return pos - buf;
}

static void stat_worker(void *arg)
{
  log_debug("STAT WORKER INITIALIZED\n");
	const size_t cmd_len = strlen("stat");
	char buf[UDP_MAX_PAYLOAD];
	struct netaddr laddr, raddr;
	udpconn_t *c;
	ssize_t ret, len;
  struct timeval cur_tv, prev_tv;

	laddr.ip = 0;
	laddr.port = STAT_PORT;

	ret = udp_listen(laddr, &c);
	if (ret) {
		log_err("stat: udp_listen failed, ret = %ld", ret);
		return;
	}
  log_debug("STARTED LISTENING at port %d!!\n", STAT_PORT);

  gettimeofday(&prev_tv, NULL);
	while (true) {
#if 0
    log_debug("WAITING TO READ FROM port %d!!\n", STAT_PORT);
		ret = udp_read_from(c, buf, UDP_MAX_PAYLOAD, &raddr);
    log_debug("READ %s(len %d) from port %d!!\n", buf, ret, STAT_PORT);
		if (ret < cmd_len)
			continue;
		if (strncmp(buf, "stat", cmd_len) != 0)
			continue;
		len = stat_write_buf(buf, UDP_MAX_PAYLOAD);
		if (len < 0) {
			log_err("stat: couldn't generate stat buffer");
			continue;
		}
		assert(len <= UDP_MAX_PAYLOAD);

		ret = udp_write_to(c, buf, len, &raddr);
		WARN_ON(ret != len);
#endif
    gettimeofday(&cur_tv, NULL);
    int elapsed_us = 
      (cur_tv.tv_sec*1000000 + cur_tv.tv_usec)
        - (prev_tv.tv_sec*1000000 + prev_tv.tv_usec);

    if(elapsed_us > 1000000) {
      len = stat_write_buf(buf, UDP_MAX_PAYLOAD, elapsed_us/1000000);
      prev_tv.tv_sec = cur_tv.tv_sec;
      prev_tv.tv_usec = cur_tv.tv_usec;
      if (len < 0) {
        log_err("stat: couldn't generate stat buffer");
        continue;
      }
      assert(len <= UDP_MAX_PAYLOAD);

      //ret = udp_write_to(c, buf, len, &raddr);
      //WARN_ON(ret != len);
    }
	}
}

/**
 * stat_init_thread - initializes per-thread state for stats
 *
 * Returns 0 (always successful).
 */
int stat_init_thread(void)
{
  log_debug("STAT THREAD INITIALIZED\n");
  if(stat_fp == NULL) {
    char hostbuffer[256];
    //struct timeval cur_tv;
    //gettimeofday(&cur_tv, NULL);
    if(gethostname(hostbuffer, sizeof(hostbuffer)) == -1) {
      printf("gethostname failed.\n");
      exit(0);
    }
    char filename[128];
    //sprintf(filename, "stat.%ld", (cur_tv.tv_sec * 1000000) + cur_tv.tv_usec);
    sprintf(filename, "stats.%s.%d", hostbuffer, getpid());
    printf("Stat file: %s\n", filename);
    //log_debug("STAT FILE FOR EXPORT: %s\n", filename);
    stat_fp = fopen(filename, "w");

    sprintf(filename, "cumulative_stats.%s.%d", hostbuffer, getpid());
    printf("Cumulative stat file: %s\n", filename);
    stat_cumulative_fp = fopen(filename, "w");

    print_stat_header();
  }
	memset(prev_stats, 0, sizeof(prev_stats));
	spin_lock(&stat_lock);
	allks[nrallks++] = myk();
	spin_unlock(&stat_lock);

	return 0;
}

/**
 * stat_init_late - starts the stat responder thread
 *
 * Returns 0 if succesful.
 */
int stat_init_late(void)
{
	return thread_spawn(stat_worker, NULL);
}
