#!/bin/bash
# this script is used for finding performance impact of CI, for a configuration to reach the target interval in cycles
CUR_PATH=`pwd`/$(dirname "${BASH_SOURCE[0]}")/
SUB_DIR="${SUB_DIR:-"overhead"}"
DIR=$CUR_PATH/exp_results/$SUB_DIR
PLOTS_DIR="$CUR_PATH/plots"

CYCLE="${CYCLE:-5000}"
THREADS="${THREADS:-"1 32"}"
CI_SETTINGS="12 2 6 10 4"
PREFIX=""
TOTAL_RUNS="${TOTAL_RUNS:-10}"
OUTLIER_THRESHOLD="20"

CI_SETTINGS_FOR_INTV_COMP="2 12"
LARGE_INTV="1000000"

#CI_SETTINGS="2 12"
#THREADS="1"

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

  if [ $thread -gt 1 ]; then
    long_running_app=$(is_a_long_duration_app $bench)
    if [ $long_running_app -eq 1 ]; then
      RUNS=10
    else
      RUNS=50
    fi
  else
    RUNS=$TOTAL_RUNS
  fi

  # Dry run
  dry_run_exp $bench $suffix_conf > /dev/null

  # For debugging turn this on
  if [ 0 -eq 1 ]; then
    RUNS=1
    #PREFIX="perf stat -B -e cache-misses -o $DIR/perf_stat_${bench}_th${thread}"
    #PREFIX="perf stat -o $DIR/perf_stat_${1}_th${thread}"
    PREFIX="perf record --call-graph=dwarf -o $DIR/perf_${bench}_th${threads}_${suffix_conf}"
  fi

  declare duration_set
  failed_runs=0
  for j in `seq 1 $RUNS`
  do
    # exp run
    #PREFIX="LD_PRELOAD=$LIBCALL_WRAPPER_PATH" run_exp $bench $suffix_conf $thread $ci_setting $5 $6 > /dev/null
    run_exp $bench $suffix_conf $thread $ci_setting $5 $6 > /dev/null

    time_in_us=`cat $OUT_FILE | grep "$bench runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`

    if [ -z "$time_in_us" ]; then
      printf "${RED}Run $j: Run failed for $bench. Output: ${NC}\n" >> $CMD_LOG
      cat $OUT_FILE >> $CMD_LOG
      printf "${RED}Moving on to next run!${NC}\n" >> $CMD_LOG
      failed_runs=`expr $failed_runs + 1`
      continue
    fi

    duration_set="$duration_set $time_in_us"
    echo "Run $j: $time_in_us us" >> $CMD_LOG
  done

  avg_time_in_us=$(get_median $duration_set)
  header="Outliers from runs of $bench with thread $thread, type $suffix_conf/$ci_setting" get_outliers $avg_time_in_us $duration_set
  avg_time_in_ms=`echo "scale=2;($avg_time_in_us/1000)" | bc`
  echo "Average: $avg_time_in_ms ms" >> $CMD_LOG
  echo "Total failed runs for $bench with thread $thread, type $suffix_conf/$ci_setting: $failed_runs" >> $CMD_LOG
  echo $avg_time_in_ms
}

perf_overhead() {

  if [ $# -ne 6 ]; then
    echo "perf_overhead() requires 6 arguments"
  fi

  run_type=$1
  bench=$2
  thread=$3
  ci_setting=$4

  if [ $run_type -eq $PTHREAD_RUN ]; then
    EXP_FILE="$DIR/pthread-th$thread"
  elif [ $run_type -eq $CI_RUN ]; then
    ci_str=$(get_ci_str_in_lower_case $ci_setting)
    EXP_FILE="$DIR/${FILE_PREFIX}${ci_str}-th$thread"
  fi

  avg_duration=$(summarize_overhead_runs $bench $thread $run_type $ci_setting $5 $6)
  echo -e "$bench\t$avg_duration" >> $EXP_FILE
}

perf_overhead_of_ci_calls() {
  echo "Experiment for Performance for $CYCLE cycles, CI Settings $CI_SETTINGS_FOR_INTV_COMP, $THREADS threads, app list: $*"
  for thread in $THREADS; do
    # Compare with very high push & cycle interval
    for ci_setting in $CI_SETTINGS_FOR_INTV_COMP; do
      ci_str=$(get_ci_str_in_lower_case $ci_setting)
      rm -f $DIR/no-interrupts-${ci_str}-th$thread

      for bench in $*; do
        ci_str=$(get_ci_str $ci_setting)
        echo "Running performance experiment for $bench with $thread threads & $ci_str type" | tee -a $CMD_LOG
        set_benchmark_info $bench

        orig_pi=$(read_tune_param $bench $ci_setting $thread)

        CYCLE=$LARGE_INTV EXTRA_FLAGS="-DAVG_STATS" build_ci $bench $ci_setting $thread $LARGE_INTV
        FILE_PREFIX="no-interrupts-" perf_overhead $CI_RUN $bench $thread $ci_setting $LARGE_INTV $LARGE_INTV
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
      perf_overhead $PTHREAD_RUN $bench $thread 0 0 0
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

        EXTRA_FLAGS="-DAVG_STATS" build_ci $bench $ci_setting $thread
        perf_overhead $CI_RUN $bench $thread $ci_setting 0 $CYCLE
      done
    done
  done
}

# Assumption: Order of benchmarks in all files are the same
process_perf_data() {
  mkdir -p $PLOTS_DIR
  for thread in $THREADS; do
    summary_file="$DIR/overhead-th$thread"
    plot_file="$PLOTS_DIR/overhead-th$thread.pdf"
    pthread_file="$DIR/pthread-th$thread"
    gawk 'BEGIN {print "Application"} {print $1}' $pthread_file > $summary_file

    for ci_setting in $CI_SETTINGS; do
      ci_str=$(get_ci_str_in_lower_case $ci_setting)
      ci_file="$DIR/${ci_str}-th$thread"
      ofile="$DIR/overhead-${ci_str}-th$thread"

      #printf "${GREEN}Generating overhead file $ofile from $pthread_file & $ci_file\n${NC}"
      gawk 'ARGIND==1 {bench[$1]=$2}
          ARGIND==2 {
            if(bench[$1])
              printf("%s\t%0.2f%\n", $1, (($2-bench[$1])*100)/bench[$1]);
            else
              printf("%s\t%0.2f%\n", $1, 0); 
          }' \
      $pthread_file $ci_file | tee $ofile

      gawk -v str=$(get_ci_str $ci_setting) \
        'ARGIND==1 {bench[$1]=$2}
         ARGIND==2 && FNR==1 { printf("%s\t%s\n", $0, str) }
         ARGIND==2 && FNR>1 {
            if(bench[$1])
              printf("%s\t%0.2f\n", $0, bench[$1]);
            else
              printf("%s\t%0.2f\n", $0, 0);
         }' \
      $ofile $summary_file > tmp; 
      mv tmp $summary_file
    done

    gnuplot -e "ofile='$plot_file'" -e "ifile='$summary_file'" plot_overhead.gp
    printf "${GREEN}Generated summary overhead data in $summary_file & plot in $plot_file\n${NC}"
    cat $summary_file
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
      large_intv_ci_file="$DIR/no-interrupts-${ci_str}-th$thread"
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

create_absolute_runtime_table() {
  out_file="$PLOTS_DIR/runtime.txt"
  sep="\t"
  echo -e "Benchmark $sep PThread(1Th) $sep CI(1Th) $sep Naive(1Th) $sep PThread(32Th) $sep CI(32Th) $sep Naive(32Th)" > $out_file

  prefix="pthread ci naive"
  threads="1 32"

  for bench in $*
  do
    echo -ne "$bench" >> $out_file
    for th in $threads
    do
      for p in $prefix
      do
        ifile="$DIR/${p}-th${th}"
        rt=`grep $bench $ifile | awk '{print int($2)}'`
        echo -ne " $sep $rt" >> $out_file
      done
    done
    echo "" >> $out_file
  done
}

mkdir -p $PLOTS_DIR
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
create_absolute_runtime_table $benches
print_end_notice

#perf_overhead_of_ci_calls $benches
#process_perf_intv_diff_data
