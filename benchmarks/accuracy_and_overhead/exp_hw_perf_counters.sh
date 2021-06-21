#!/bin/bash
# this script is used for finding performance overhead comparison between CI and Hardware performance counters over varying target intervals (in cycles)
CUR_PATH=`pwd`/$(dirname "${BASH_SOURCE[0]}")/
SUB_DIR="${SUB_DIR:-"comp_with_hw_counters"}"
DIR=$CUR_PATH/exp_results/$SUB_DIR
PLOTS_DIR="$CUR_PATH/plots"
TMP_FILE="$DIR/tmp"

CYCLE="${CYCLE:-5000}"
CI_SETTINGS="2"
PREFIX=""
RUNS="${RUNS:-10}"
OUTLIER_THRESHOLD="5"
THREADS="1"
#PREFIX="LD_PRELOAD=$LIBCALL_WRAPPER_PATH"

INTERVALS="${INTERVALS:-"2000 5000 10000 15000 20000 50000 75000 100000 150000 300000 500000 750000 1000000"}"

source $CUR_PATH/include.sh

#1 - benchmark name, 2 - #thread, 3 - 0:orig run, 1:ci run
# Do not print anything in this function as a value is returned from this
summarize_overhead_runs() {

  if [ $# -ne 6 ]; then
    echo "summarize_overhead_runs() requires 6 arguments"
  fi

  bench=$1
  thread=$2
  suffix_conf=$3
  ci_setting=$4

  # Dry run
  dry_run_exp $bench $suffix_conf > /dev/null

  # For debugging turn this on
  if [ 0 -eq 1 ]; then
    RUNS=1
    #PREFIX="perf stat -B -e cache-misses -o $DIR/perf_stat_${bench}_th${threads}"
    #PREFIX="perf stat -o $DIR/perf_stat_${1}_th${threads}"
    PREFIX="perf record --call-graph=dwarf -o $DIR/perf_${bench}_th${threads}_${suffix_conf}"
  fi

  declare duration_set cycles_set ir_set
  for j in `seq 1 $RUNS`
  do
    # exp run
    run_exp $bench $suffix_conf $thread $ci_setting $5 $6 > /dev/null

    time_in_us=`cat $OUT_FILE | grep "$bench runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`

    if [ -z "$time_in_us" ]; then
      echo "Run failed. Output: " >> $CMD_LOG
      cat $OUT_FILE >> $CMD_LOG
      echo -e "\nRun $j failed. Continue to next run." >> $CMD_LOG
      continue
    fi

    duration_set="$duration_set $time_in_us"

    # Process cycles & ir data where available
    cat $OUT_FILE | grep "avg_intv_cycles:" > $TMP_FILE

    if [ -s "$TMP_FILE" ]; then
      cycles=`awk -F'[,:]' '{sum1 += ($2 * $4); sum2 += $2} END { if (sum2 > 0) printf "%0.2f", sum1 / sum2; }' $TMP_FILE`
      ir=`awk -F'[,:]' '{sum1 += ($2 * $6); sum2 += $2} END { if (sum2 > 0) printf "%.2f", sum1 / sum2; }' $TMP_FILE`

      cycles_set="$cycles_set $cycles"
      ir_set="$ir_set $ir"
    fi
    
    echo "Run $j: $time_in_us us, average $cycles cycles, average $ir IR instructions" >> $CMD_LOG
  done

  avg_time_in_us=$(get_avg $duration_set)
  avg_cycles=$(get_avg $cycles_set)
  avg_ir=$(get_avg $ir_set)

  header="Duration outliers from runs of $bench" get_outliers $avg_time_in_us $duration_set
  header="Cycles outliers from runs of $bench" get_outliers $avg_cycles $cycles_set
  header="IR outliers from runs of $bench" get_outliers $avg_ir $ir_set

  avg_time_in_ms=`echo "scale=2;($avg_time_in_us/1000)" | bc`
  echo "Average: $avg_time_in_ms ms, average $avg_cycles cycles, average $avg_ir IR instructions" >> $CMD_LOG
  echo -n $avg_time_in_ms
  if [ "$avg_cycles" != "0" ]; then echo -ne "\t$avg_cycles"; fi
  if [ "$avg_ir" != "0" ]; then echo -ne "\t$avg_ir"; fi
}

perf_overhead() {

  if [ $# -ne 4 ]; then
    echo "perf_overhead() requires 4 arguments"
  fi

  run_type=$1
  thread=$THREADS
  bench=$2
  ci_setting=$3
  intv=$4

  avg=$(summarize_overhead_runs $bench $thread $run_type $ci_setting $intv $intv)

  if [ $run_type -eq $PTHREAD_RUN ]; then
    EXP_FILE="$DIR/pthread-${bench}"
    echo -e "$avg" >> $EXP_FILE
  elif [ $run_type -eq $CI_RUN ]; then
    ci_str=$(get_ci_str_in_lower_case $ci_setting)
    EXP_FILE="$DIR/${ci_str}-${bench}"
    echo -e "$intv\t$avg" >> $EXP_FILE
  elif [ $run_type -eq $HW_PC_RUN ]; then
    EXP_FILE="$DIR/hwc-${bench}"
    echo -e "$intv\t$avg" >> $EXP_FILE
  fi
}

perf_orig_test() {
  echo "Running original pthread program for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS thread, app list: $*"
  thread=$THREADS
  for bench in $*; do
    echo "runtime" > $DIR/pthread-${bench}
    echo "Running performance experiment for $bench with $THREADS threads & orig type" | tee -a $CMD_LOG
    set_benchmark_info $bench

    build_orig $bench $thread
    perf_overhead $PTHREAD_RUN $bench 0 0
  done
}

perf_overhead_ci_test() {
  echo "Experiment for Performance for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS threads, app list: $*"

  thread=$THREADS

  # Run with compiler interrupts
  for ci_setting in $CI_SETTINGS; do
    for bench in $*; do
      ci_str=$(get_ci_str_in_lower_case $ci_setting)
      echo -e "interval\truntime\tcycles\tir" > $DIR/${ci_str}-${bench}
      for interval in $INTERVALS; do
        echo "Running performance experiment for $bench with target interval $interval, $THREADS thread & $ci_str type" | tee -a $CMD_LOG
        set_benchmark_info $bench

        EXTRA_FLAGS="-DPERF_CNTR" build_ci $bench $ci_setting $thread $interval
        perf_overhead $CI_RUN $bench $ci_setting $interval
      done
    done
  done
}

perf_overhead_hwc_test() {
  echo "Experiment for Performance for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS threads, app list: $*"

  thread=$THREADS
  # Run with compiler interrupts
  for bench in $*; do
    echo -e "interval\truntime\tcycles\tret_inst" > $DIR/hwc-${bench}
    for interval in $INTERVALS; do
      echo "Running performance experiment for $bench with target interval $interval, $THREADS thread & with hardware performance counters" | tee -a $CMD_LOG
      set_benchmark_info $bench

      EXTRA_FLAGS="-DPAPI" build_orig $bench $thread
      perf_overhead $HW_PC_RUN $bench 0 $interval
    done
  done
}

plot_data() {
  mkdir -p $PLOTS_DIR
  plot_file="$PLOTS_DIR/perf-hwc.pdf"

  ci_path="$DIR/overhead-ci-*"
  hwc_path="$DIR/overhead-hwc-*"
  gnuplot -e "ofile='$plot_file'" -e "ci_path='$ci_path'" -e "hwc_path='$hwc_path'" plot_hwc.gp
  printf "${GREEN}Generated summary overhead data in $ci_path and $hwc_path & plot in $plot_file\n${NC}"
}

# Assumption: Order of benchmarks in all files are the same
process_perf_data() {
  mkdir -p $PLOTS_DIR
  plot_file="$PLOTS_DIR/perf-hwc.pdf"

  for bench in $*; do
    pthread_file="$DIR/pthread-${bench}"
    ci_file="$DIR/ci-${bench}"
    #ci_cycles_file="$DIR/ci-cycles-${bench}"
    hwc_file="$DIR/hwc-${bench}"

    ci_ofile="$DIR/overhead-ci-${bench}"
    #ci_cycles_ofile="$DIR/overhead-ci-cycles-${bench}"
    hwc_ofile="$DIR/overhead-hwc-${bench}"

    pthread_runtime=`awk 'NR==2 {printf "%.2f", $0}' $pthread_file`
    awk -v orig=$pthread_runtime '
    NR>1 {
      if($3=="") {printf "?\t"} else {printf "%.2f\t", $3}
      if($2==0) {printf "?\n"} else {printf "%.2f\n", ($2-orig)*100/orig}
      }' $ci_file > $ci_ofile
    #awk -v orig=$pthread_runtime 'NR>1 {printf "%.2f\t%.2f\n", $3, ($2-orig)*100/orig}' $ci_cycles_file > $ci_cycles_ofile
    awk -v orig=$pthread_runtime '
    NR>1 {
      if($3=="") {printf "?\t"} else {printf "%.2f\t", $3}
      if($2==0) {printf "?\n"} else {printf "%.2f\n", ($2-orig)*100/orig}
    }' $hwc_file > $hwc_ofile
  done

  plot_data $*
}

mkdir -p $PLOTS_DIR
benches="$splash2_benches $phoenix_benches"

# Usage:
#   No argument : run for all benchmark suites
#   $1=0, $2=<name of benchmark>
#   $1=1, $2=<name of benchmark suite>

if [ $# -ne 0 ]; then
  if [ $1 -eq 1 ]; then
    benches=""
    for arg in $@; do
      if [ "$arg" == "splash2" ]; then
        benches="$benches$splash2_benches "
      elif [ "$arg" == "phoenix" ]; then
        benches="$benches$phoenix_benches "
      elif [ "$arg" == "parsec" ]; then
        benches="$benches$parsec_benches "
      fi
    done
  else
    benches="${@:2}"
  fi
fi

#build_libcall_wrapper
perf_orig_test $benches
perf_overhead_ci_test $benches
perf_overhead_hwc_test $benches
process_perf_data $benches

rm -f $TMP_FILE
