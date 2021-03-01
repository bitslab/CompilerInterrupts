#!/bin/bash
CI=1000
PI="${PI:-5000}"
RUNS="${RUNS:-5}"
AD=100
CLOCK=1
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
DIR=$CUR_PATH/phoenix_stats/$SUB_DIR
THREADS="${THREADS:-"1 2 4 8 16 32"}"
CYCLE=5000

dry_run() {
  # Dry run - so that any disk caching does not hamper the process
  case "$1" in
    histogram)
#eo "MR_NUMTHREADS=$threads timeout 5m $prefix ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp" >> $DEBUG_FILE
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp > /dev/null 2>&1"
    ;;
    kmeans)
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program -d 100 -c 10 -p 500000 -s 50 > /dev/null 2>&1"
    ;;
    pca) 
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program -r 1000 -c 1000 -s 1000 > /dev/null 2>&1"
    ;;
    matrix_multiply) 
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program 900 600 1 > /dev/null 2>&1"
    ;;
    string_match)
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_100MB.txt > /dev/null 2>&1"
    ;;
    linear_regression)
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_500MB.txt > /dev/null 2>&1"
    ;;
    word_count)
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/word_50MB.txt > /dev/null 2>&1"
    ;;
    reverse_index)
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/www.stanford.edu/dept/news/ > /dev/null 2>&1"
    ;;
  esac
  echo "Dry run: "$command >> $DEBUG_FILE
  eval $command
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_time() {
  rm -f out
  threads=$2
  program=$1
  if [ $3 -eq 1 ]; then
    prefix="taskset 0x00000001 " # for pinning threads on 1core
  fi

  DIVISOR=`expr $RUNS \* 1000`
  rm -f sum
  #dry_run $program

  echo -n "scale=2;(" > sum
  for j in `seq 1 $RUNS`
  do
    case "$program" in
      histogram)
        command="MR_NUMTHREADS=$threads timeout 5m $prefix ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp > out 2>&1"
      ;;
      kmeans)
        command="MR_NUMTHREADS=$threads timeout 5m $prefix ./tests/$program/$program -d 100 -c 10 -p 500000 -s 50 > out 2>&1"
      ;;
      pca) 
        command="MR_NUMTHREADS=$threads timeout 5m $prefix ./tests/$program/$program -r 1000 -c 1000 -s 1000 > out 2>&1"
      ;;
      matrix_multiply) 
        command="MR_NUMTHREADS=$threads timeout 5m $prefix ./tests/$program/$program 900 600 1 > out 2>&1"
      ;;
      string_match)
        command="MR_NUMTHREADS=$threads timeout 5m $prefix ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_100MB.txt > out 2>&1"
      ;;
      linear_regression)
        command="MR_NUMTHREADS=$threads timeout 5m $prefix ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_500MB.txt > out 2>&1"
      ;;
      word_count)
        command="MR_NUMTHREADS=$threads timeout 5m $prefix ./tests/$program/$program ../input_datasets/${program}_datafiles/word_50MB.txt > out 2>&1"
      ;;
      reverse_index)
        command="MR_NUMTHREADS=$threads timeout 5m $prefix ./tests/$program/$program ../input_datasets/${program}_datafiles/www.stanford.edu/dept/news/ > out 2>&1"
      ;;
    esac
    echo $command >> $DEBUG_FILE
    eval $command
    time_in_us=`cat out | grep "$program runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    if [ ! -z "$time_in_us" ]; then
      echo $time_in_us | tr -d '\n' >> sum
      in_ms=`echo "scale=2;($time_in_us/1000)" | bc`
      echo $in_ms >> $BENCH_LOG
      echo "$time_in_us ms" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        echo -n "+" >> sum
      fi
    fi
  done
  echo ")/$DIVISOR" >> sum
  time_in_ms=`cat sum | bc`
  echo "Average: $time_in_ms ms" >> $DEBUG_FILE
  echo $time_in_ms
}

read_tune_param() {
  case "$2" in
    14) ci_type="opt-tl";;
    15) ci_type="opt-int";;
    *)
      echo "Wrong CI Type"
      exit
    ;;
  esac
  tune_file="./${ci_type}-tuning-${CYCLE}.txt"
  while read line; do
    present=`echo $line | grep $1 | wc -l`
    if [ $present -eq 1 ]; then
      intv=`echo $line | cut -d' ' -f 2`
      break
    fi
  done < $tune_file
  echo $intv
}

perf_test() {
  echo "=================================== PERFORMANCE TEST ==========================================="
  LOG_FILE="$DIR/perf_logs-$AD.txt"
  DEBUG_FILE="$DIR/perf_debug-$AD.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error-$AD.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log-$AD.txt"
  #FIBER_CONFIG is set in the Makefile. Unless needed, do not pass a new config from this script

  rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE

  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.txt"
    echo -e "benchmark\tPThread\tFiber-CI\tFiber-CI-Cycles\tFiber" > $PER_THREAD_STAT_FILE
  done

  for bench in $*
  do
    ORIG_STAT_FILE="$DIR/$bench-perf_orig-$AD.txt"
    FIBER_ORIG_STAT_FILE="$DIR/$bench-perf_orig_fiber-$AD.txt"
    FIBER_LC_STAT_FILE="$DIR/$bench-perf_lc_fiber-$AD.txt"
    FIBER_LC_CYCLE_STAT_FILE="$DIR/$bench-perf_lc_cycle_fiber-$AD.txt"
    echo "Pthread" > $ORIG_STAT_FILE
    echo "Fiber" > $FIBER_ORIG_STAT_FILE
    echo "Fiber-CI" > $FIBER_LC_STAT_FILE
    echo "Fiber-CI-Cycles" > $FIBER_LC_CYCLE_STAT_FILE
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-$thread-orig-runs-log.txt"
      echo "PThread - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-$thread-ci-fiber-runs-log.txt"
      echo "Fiber CI TL - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-$thread-ci-cycles-fiber-runs-log.txt"
      echo "Fiber CI Cycles TL - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-$thread-orig-fiber-runs-log.txt"
      echo "Fiber TL - Thread $thread, $RUNS runs" > $BENCH_LOG
    done
  done

  for bench in $*
  do
    #run original 
    echo "Building original program: " | tee -a $DEBUG_FILE
    make -f Makefile.orig clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    make -f Makefile.orig >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running original program: " | tee -a $DEBUG_FILE
    ORIG_STAT_FILE="$DIR/$bench-perf_orig-$AD.txt"
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-$thread-orig-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.txt"
      suffix="orig"; dry_run $bench
      orig_time=$(get_time $bench $thread 1)
      echo -ne "$bench" >> $PER_THREAD_STAT_FILE
      echo -ne "\t$orig_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$orig_time" >> $ORIG_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${orig_time}ms" | tee -a $DEBUG_FILE
    done

    #run fiber-ci
    CI_SETTING=14
    AD=100
    PI=$(read_tune_param $bench $CI_SETTING)
    CI=`echo "scale=0; $PI/5" | bc`
    echo "Building fiber with CI program for $bench with PI:$PI, CI:$CI, CYCLE:$CYCLE: " | tee -a $DEBUG_FILE
    make -f Makefile.lc.fiber clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING make -f Makefile.lc.fiber >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running fiber with CI program: " | tee -a $DEBUG_FILE
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-$thread-ci-fiber-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.txt"
      FIBER_LC_STAT_FILE="$DIR/$bench-perf_lc_fiber-$AD.txt"
      suffix="lc"; dry_run $bench
      lc_fiber_time=$(get_time $bench $thread 0)
      echo -ne "\t$lc_fiber_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$lc_fiber_time" >> $FIBER_LC_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${lc_fiber_time}ms" | tee -a $DEBUG_FILE
    done

    #run fiber-ci-cycles
    CI_SETTING=15
    AD=100
    PI=$(read_tune_param $bench $CI_SETTING)
    CI=`echo "scale=0; $PI/5" | bc`
    echo "Building fiber with CI Cycles program for $bench with PI:$PI, CI:$CI, CYCLE:$CYCLE: " | tee -a $DEBUG_FILE
    make -f Makefile.lc.fiber clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING make -f Makefile.lc.fiber >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running fiber with CI Cycles program: " | tee -a $DEBUG_FILE
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-$thread-ci-cycles-fiber-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.txt"
      FIBER_LC_CYCLE_STAT_FILE="$DIR/$bench-perf_lc_cycle_fiber-$AD.txt"
      suffix="lc"; dry_run $bench
      lc_fiber_time=$(get_time $bench $thread 0)
      echo -ne "\t$lc_fiber_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$lc_fiber_time" >> $FIBER_LC_CYCLE_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${lc_fiber_time}ms" | tee -a $DEBUG_FILE
    done

    #run orig-fiber
    echo "Building orig with fiber program: " | tee -a $DEBUG_FILE
    make -f Makefile.orig.fiber clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    make -f Makefile.orig.fiber >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running orig with CI program: " | tee -a $DEBUG_FILE
    FIBER_ORIG_STAT_FILE="$DIR/$bench-perf_orig_fiber-$AD.txt"
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-$thread-tl-orig-fiber-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.txt"
      suffix="orig"; dry_run $bench
      orig_fiber_time=$(get_time $bench $thread 0)
      echo -ne "\t$orig_fiber_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$orig_fiber_time" >> $FIBER_ORIG_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${orig_fiber_time}ms" | tee -a $DEBUG_FILE
    done

    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.txt"
      echo "" >> $PER_THREAD_STAT_FILE
      final_thread=$thread
    done
  done

  #Print
#echo "Statistics for $final_thread thread(s)"
#echo "Original Time: $orig_time ms" | tee -a $LOG_FILE
#echo "Naive Time: $naive_time ms" | tee -a $LOG_FILE
#echo "Optimized Periodic Time: $opt_time_periodic ms" | tee -a $LOG_FILE
#echo "Optimized Eager Time: $opt_time_eager ms" | tee -a $LOG_FILE
#echo "Passed Naive Time: $passed_naive_time ms" | tee -a $LOG_FILE
#echo "Passed Optimized Periodic Time: $passed_opt_time_periodic ms" | tee -a $LOG_FILE
#echo "Passed Optimized Eager Time: $passed_opt_time_eager ms" | tee -a $LOG_FILE
#
#slowdown_opt_periodic=`echo "scale = 3; ($opt_time_periodic / $orig_time)" | bc -l`
#slowdown_opt_eager=`echo "scale = 3; ($opt_time_eager / $orig_time)" | bc -l`
#slowdown_naive=`echo "scale = 3; ($naive_time / $orig_time)" | bc -l`
#slowdown_naive_opt_periodic=`echo "scale = 3; ($naive_time / $opt_time_periodic)" | bc -l`
#slowdown_naive_opt_eager=`echo "scale = 3; ($naive_time / $opt_time_eager)" | bc -l`
#slowdown_passed_opt_periodic=`echo "scale = 3; ($passed_opt_time_periodic / $orig_time)" | bc -l`
#slowdown_passed_opt_eager=`echo "scale = 3; ($passed_opt_time_eager / $orig_time)" | bc -l`
#slowdown_passed_naive=`echo "scale = 3; ($passed_naive_time / $orig_time)" | bc -l`
#echo "Slowdown of optimal periodic instrumentation over original program: ${slowdown_opt_periodic}x" | tee -a $LOG_FILE
#echo "Slowdown of optimal eager instrumentation over original program: ${slowdown_opt_eager}x" | tee -a $LOG_FILE
#echo "Slowdown of passed optimal periodic instrumentation over original program: ${slowdown_passed_opt_periodic}x" | tee -a $LOG_FILE
#echo "Slowdown of passed optimal eager instrumentation over original program: ${slowdown_passed_opt_eager}x" | tee -a $LOG_FILE
#echo "Slowdown of naive instrumentation over original program: ${slowdown_naive}x" | tee -a $LOG_FILE
#echo "Slowdown of passed naive instrumentation over original program: ${slowdown_passed_naive}x" | tee -a $LOG_FILE
}

run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
  else
    perf_test $@
  fi
}

echo "Note: Script has performance tests for both instantaneous & predictive clocks."
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: $THREADS, Output Directory: $DIR"
echo "WARNING: Remove Passed Config if you don't need it!"
mkdir -p $DIR;

if [ $# -eq 0 ]; then
  run_perf_test
else
  run_perf_test $@
fi

rm -f out sum
