#!/bin/bash
# this script is used for finding performance impact of CI, for a configuration to reach the target interval in cycles
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-"overhead"}"
DIR=$CUR_PATH/exp_results/$SUB_DIR

CYCLE="${CYCLE:-5000}"
THREADS="${THREADS:-"1 32"}"
CI_SETTINGS="2 12 4 6 10"
EXTRA_FLAGS="-DAVG_STATS"
PREFIX=""
RUNS="${RUNS:-10}"
OUTLIER_THRESHOLD="5"

CI_SETTINGS_FOR_INTV_COMP="2 12"
LARGE_INTV="1000000"

#CI_SETTINGS="2 12"
#THREADS="1"

source $CUR_PATH/include.sh

#1 - benchmark name, 2 - #thread, 3 - 0:orig run, 1:ci run
# Do not print anything in this function as a value is returned from this
summarize_overhead_runs() {
  bench=$1
  thread=$2
  suffix_conf=$3

  # Dry run
  dry_run_exp $bench $suffix_conf > /dev/null

  # For debugging turn this on
  if [ 0 -eq 1 ]; then
    RUNS=1
    #PREFIX="perf stat -B -e cache-misses -o $DIR/perf_stat_${bench}_th${threads}"
    #PREFIX="perf stat -o $DIR/perf_stat_${1}_th${threads}"
    PREFIX="perf record --call-graph=dwarf -o $DIR/perf_${bench}_th${threads}_${suffix_conf}"
  fi

  declare duration_set
  for j in `seq 1 $RUNS`
  do
    # exp run
    run_exp $bench $suffix_conf $thread > /dev/null

    time_in_us=`cat $OUT_FILE | grep "$bench runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`

    if [ -z "$time_in_us" ]; then
      echo "Run failed. Output: " >> $CMD_LOG
      cat $OUT_FILE >> $CMD_LOG
      exit
    fi

    duration_set="$duration_set $time_in_us"
    echo "Run $j: $time_in_us us" >> $CMD_LOG
  done

  avg_time_in_us=$(get_avg $duration_set)
  header="Outliers from runs of $bench with thread $thread" get_outliers $avg_time_in_us $duration_set
  avg_time_in_ms=`echo "scale=2;($avg_time_in_us/1000)" | bc`
  echo "Average: $avg_time_in_ms ms" >> $CMD_LOG
  echo $avg_time_in_ms
}

perf_overhead() {
  run_type=$1
  bench=$2
  thread=$3
  ci_setting=$4

  if [ $run_type -eq 0 ]; then
    EXP_FILE="$DIR/pthread-th$thread"
  elif [ $run_type -eq 1 ]; then
    ci_str=$(get_ci_str_in_lower_case $ci_setting)
    EXP_FILE="$DIR/${ci_str}-th$thread"
  elif [ $run_type -eq 2 ]; then
    ci_str=$(get_ci_str_in_lower_case $ci_setting)
    EXP_FILE="$DIR/no-interrupts-no-probes-${ci_str}-th$thread"
  else
    ci_str=$(get_ci_str_in_lower_case $ci_setting)
    EXP_FILE="$DIR/no-interrupts-${ci_str}-th$thread"
  fi

  avg_duration=$(summarize_overhead_runs $bench $thread $run_type)

  echo -e "$bench\t$avg_duration" >> $EXP_FILE
}

perf_overhead_of_ci_calls() {
  echo "Experiment for Performance for $CYCLE cycles, CI Settings $CI_SETTINGS_FOR_INTV_COMP, $THREADS threads, app list: $*"
  for thread in $THREADS; do
    # Compare with very high push & cycle interval
    for ci_setting in $CI_SETTINGS_FOR_INTV_COMP; do
      ci_str=$(get_ci_str_in_lower_case $ci_setting)
      rm -f $DIR/no-interrupts-no-probes-${ci_str}-th$thread

      for bench in $*; do
        ci_str=$(get_ci_str $ci_setting)
        echo "Running performance experiment for $bench with $thread threads & $ci_str type" | tee -a $CMD_LOG
        set_benchmark_info $bench

        orig_pi=$(read_tune_param $bench $ci_setting $thread)
        SMALL_CI=`echo "scale=0; $orig_pi/5" | bc`
        #LARGE_CI=`echo "scale=0; $LARGE_INTV/5" | bc`

        BACKUP_CYCLE=$CYCLE
        CYCLE=$LARGE_INTV
        build_ci $bench $ci_setting $thread $LARGE_INTV $SMALL_CI
        CYCLE=$BACKUP_CYCLE

        perf_overhead 2 $bench $thread $ci_setting
      done
    done
  done
}

perf_orig_test() {
  echo "Running original pthread program for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS threads, app list: $*"
  for thread in $THREADS; do
    rm -f $DIR/pthread-th$thread
    for bench in $*; do
      echo "Running performance experiment for $bench with $thread threads & orig type" | tee -a $CMD_LOG
      set_benchmark_info $bench

      build_orig $bench $thread
      perf_overhead 0 $bench $thread
    done
  done
}

perf_overhead_test() {
#THREADS="32"
#CI_SETTINGS="10"
  echo "Experiment for Performance for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS threads, app list: $*"
  for thread in $THREADS; do
    # Run with compiler interrupts
    for ci_setting in $CI_SETTINGS; do
      ci_str=$(get_ci_str_in_lower_case $ci_setting)
      rm -f $DIR/${ci_str}-th$thread

      for bench in $*; do
        ci_str=$(get_ci_str $ci_setting)
        echo "Running performance experiment for $bench with $thread threads & $ci_str type" | tee -a $CMD_LOG
        set_benchmark_info $bench

        build_ci $bench $ci_setting $thread
        perf_overhead 1 $bench $thread $ci_setting
      done
    done
  done
}

# Assumption: Order of benchmarks in all files are the same
process_perf_data() {
  for thread in $THREADS; do
    for ci_setting in $CI_SETTINGS; do
      ci_str=$(get_ci_str_in_lower_case $ci_setting)
      ci_file="$DIR/${ci_str}-th$thread"
      pthread_file="$DIR/pthread-th$thread"
      ofile="$DIR/overhead-${ci_str}-th$thread"

      printf "${GREEN}Generating overhead file $ofile from $pthread_file & $ci_file\n${NC}"
      gawk 'ARGIND==1 {bench[$1]=$2}
          ARGIND==2 {
            if(bench[$1])
              printf("%s\t%0.2f%\n", $1, (($2-bench[$1])*100)/bench[$1]);
            else
              printf("%s\t%0.2f%\n", $1, 0); 
          }' \
      $pthread_file $ci_file | tee $ofile
    done
  done
}

# Assumption: Order of benchmarks in all files are the same
# for comparison of small vs big intervals
process_perf_intv_diff_data() {
  for thread in $THREADS; do
    for ci_setting in $CI_SETTINGS; do
      ci_str=$(get_ci_str_in_lower_case $ci_setting)
      ci_file="$DIR/${ci_str}-th$thread"
      pthread_file="$DIR/pthread-th$thread"
      large_intv_ci_file="$DIR/no-interrupts-no-probes-${ci_str}-th$thread"
      ofile="$DIR/large_interval_overhead-${ci_str}-th$thread"

      printf "${GREEN}Generating overhead file $ofile from $pthread_file & $large_intv_ci_file\n${NC}"
      gawk 'ARGIND==1 {bench[$1]=$2}
          ARGIND==2 {
            if(bench[$1])
              printf("%s\t%0.2f%\n", $1, (($2-bench[$1])*100)/bench[$1]);
            else
              printf("%s\t%0.2f%\n", $1, 0); 
          }' \
      $pthread_file $large_intv_ci_file | tee $ofile
    done
  done
}

benches="$splash2_benches $phoenix_benches $parsec_benches"

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

perf_orig_test $benches
perf_overhead_test $benches
process_perf_data

#perf_overhead_of_ci_calls $benches
#process_perf_intv_diff_data
