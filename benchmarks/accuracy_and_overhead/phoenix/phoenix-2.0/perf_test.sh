#!/bin/bash
CI=1000
PI="${PI:-5000}"
RUNS="${RUNS:-5}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
DIR=$CUR_PATH/phoenix_stats/$SUB_DIR
THREADS="${THREADS:-"1 2 4 8 16 32"}"

dry_run() {
  # Dry run - so that any disk caching does not hamper the process
  case "$1" in
    histogram)
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

  DIVISOR=`expr $RUNS \* 1000`
  rm -f sum
  dry_run $program

  echo -n "scale=2;(" > sum
  for j in `seq 1 $RUNS`
  do
    case "$program" in
      histogram)
        command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp > out 2>&1"
      ;;
      kmeans)
        command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program -d 100 -c 10 -p 500000 -s 50 > out 2>&1"
      ;;
      pca) 
        command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program -r 1000 -c 1000 -s 1000 > out 2>&1"
      ;;
      matrix_multiply) 
        command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program 900 600 1 > out 2>&1"
      ;;
      string_match)
        command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_100MB.txt > out 2>&1"
      ;;
      linear_regression)
        command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_500MB.txt > out 2>&1"
      ;;
      word_count)
        command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/word_50MB.txt > out 2>&1"
      ;;
      reverse_index)
        command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/www.stanford.edu/dept/news/ > out 2>&1"
      ;;
    esac
    echo $command >> $DEBUG_FILE
    eval $command
    time_in_us=`cat out | grep "$program runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    echo $time_in_us | tr -d '\n' >> sum
    in_ms=`echo "scale=2;($time_in_us/1000)" | bc`
    echo $in_ms >> $BENCH_LOG
    echo "$time_in_us ms" >> $DEBUG_FILE
    if [ $j -lt $RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$DIVISOR" >> sum
  time_in_ms=`cat sum | bc`
  echo "Average: $time_in_ms ms" >> $DEBUG_FILE
  echo $time_in_ms
}

perf_test() {
  echo "=================================== PERFORMANCE TEST ==========================================="
  LOG_FILE="$DIR/perf_logs-ad$AD.txt"
  DEBUG_FILE="$DIR/perf_debug-ad$AD.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error-ad$AD.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log-ad$AD.txt"
  #FIBER_CONFIG is set in the Makefile. Unless needed, do not pass a new config from this script
#LEGACY_INTV="1 10 100 1000 10000"
  LEGACY_INTV="100 1000"

  rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE

  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
    echo -ne "Type" > $PER_THREAD_STAT_FILE
    for bench in $*
    do
      echo -ne "\t$bench" >> $PER_THREAD_STAT_FILE
    done
    echo "" >> $PER_THREAD_STAT_FILE
  done

  for bench in $*
  do
    ORIG_STAT_FILE="$DIR/$bench-perf_orig-ad$AD.txt"
    PERIODIC_STAT_FILE="$DIR/$bench-perf_periodic-ad$AD.txt"
    NAIVE_STAT_FILE="$DIR/$bench-perf_naive-ad$AD.txt"
    COREDET_TL_STAT_FILE="$DIR/$bench-perf_coredet_tl-ad$AD.txt"
    COREDET_LOCAL_STAT_FILE="$DIR/$bench-perf_coredet_local-ad$AD.txt"
    echo "pthread" > $ORIG_STAT_FILE
    echo "periodic" > $PERIODIC_STAT_FILE
    echo "naive" > $NAIVE_STAT_FILE
    echo "coredet-tl" > $COREDET_TL_STAT_FILE
    echo "coredet-local" > $COREDET_LOCAL_STAT_FILE
    for legacy_intv in $LEGACY_INTV
    do
      LEGACY_STAT_FILE="$DIR/$bench-perf_legacy_$legacy_intv-ad$AD.txt"
      echo "legacy_$legacy_intv" > $LEGACY_STAT_FILE
    done
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-th$thread-orig-runs-log.txt"
      echo "PThread - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-th$thread-naive-runs-log.txt"
      echo "Naive TL - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-th$thread-tl-periodic-runs-log.txt"
      echo "Periodic TL - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-th$thread-coredet-tl-runs-log.txt"
      echo "CoreDet TL - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-th$thread-coredet-local-runs-log.txt"
      echo "CoreDet Local - Thread $thread, $RUNS runs" > $BENCH_LOG
      for legacy_intv in $LEGACY_INTV
      do
        BENCH_LOG="$DIR/$bench-th$thread-legacy_$legacy_intv-runs-log.txt"
        echo "Legacy_$legacy_intv TL - Thread $thread, $RUNS runs" > $BENCH_LOG
      done
    done
  done

  #run original 
  echo "Building original program: " | tee -a $DEBUG_FILE
  make -f Makefile.orig clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  make -f Makefile.orig >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  echo "Running original program: " | tee -a $DEBUG_FILE
  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
    echo -ne "Orig" >> $PER_THREAD_STAT_FILE
  done
  for bench in $*
  do
    ORIG_STAT_FILE="$DIR/$bench-perf_orig-ad$AD.txt"
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-th$thread-orig-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
      orig_time=$(get_time $bench $thread 0)
      echo -ne "\t$orig_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$orig_time" >> $ORIG_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${orig_time}ms" | tee -a $DEBUG_FILE
    done
  done

  #run naive
  echo "Building naive program: " | tee -a $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  echo "Running naive program: " | tee -a $DEBUG_FILE
  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
    echo "" >> $PER_THREAD_STAT_FILE
    echo -ne "Naive" >> $PER_THREAD_STAT_FILE
  done
  for bench in $*
  do
    NAIVE_STAT_FILE="$DIR/$bench-perf_naive-ad$AD.txt"
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-th$thread-naive-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
      naive_time=$(get_time $bench $thread 1)
      echo -ne "\t$naive_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$naive_time" >> $NAIVE_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${naive_time}ms" | tee -a $DEBUG_FILE
    done
  done

  #run periodic
  echo "Building periodic opt program: " | tee -a $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  echo "Running periodic opt program: " | tee -a $DEBUG_FILE
  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
    echo "" >> $PER_THREAD_STAT_FILE
    echo -ne "Periodic" >> $PER_THREAD_STAT_FILE
  done
  for bench in $*
  do
    PERIODIC_STAT_FILE="$DIR/$bench-perf_periodic-ad$AD.txt"
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-th$thread-tl-periodic-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
      opt_time_periodic=$(get_time $bench $thread 1)
      echo -ne "\t$opt_time_periodic" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$opt_time_periodic" >> $PERIODIC_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${opt_time_periodic}ms" | tee -a $DEBUG_FILE
    done
  done

  #run coredet tl
  echo "Building coredet tl program: " | tee -a $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=6 make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  echo "Running coredet tl program: " | tee -a $DEBUG_FILE
  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
    echo "" >> $PER_THREAD_STAT_FILE
    echo -ne "CoreDet-TL" >> $PER_THREAD_STAT_FILE
  done
  for bench in $*
  do
    COREDET_TL_STAT_FILE="$DIR/$bench-perf_coredet_tl-ad$AD.txt"
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-th$thread-coredet-tl-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
      cdtl_time=$(get_time $bench $thread 1)
      echo -ne "\t$cdtl_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$cdtl_time" >> $COREDET_TL_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${cdtl_time}ms" | tee -a $DEBUG_FILE
    done
  done

  #run coredet local
  echo "Building coredet local program: " | tee -a $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=7 make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  echo "Running coredet local program: " | tee -a $DEBUG_FILE
  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
    echo "" >> $PER_THREAD_STAT_FILE
    echo -ne "CoreDet-Local" >> $PER_THREAD_STAT_FILE
  done
  for bench in $*
  do
    COREDET_LOCAL_STAT_FILE="$DIR/$bench-perf_coredet_local-ad$AD.txt"
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-th$thread-coredet-local-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
      cdlocal_time=$(get_time $bench $thread 1)
      echo -ne "\t$cdlocal_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$cdlocal_time" >> $COREDET_LOCAL_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${cdlocal_time}ms" | tee -a $DEBUG_FILE
    done
  done

  #run legacy
  for legacy_intv in $LEGACY_INTV
  do
    echo "Building legacy program with interval $legacy_intv: " | tee -a $DEBUG_FILE
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$legacy_intv CMMT_INTV=$CI INST_LEVEL=5 make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running legacy program with interval $legacy_intv: " | tee -a $DEBUG_FILE
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
      echo "" >> $PER_THREAD_STAT_FILE
      echo -ne "Legacy_$legacy_intv" >> $PER_THREAD_STAT_FILE
    done
    for bench in $*
    do
      LEGACY_STAT_FILE="$DIR/$bench-perf_legacy_$legacy_intv-ad$AD.txt"
      for thread in $THREADS
      do
        BENCH_LOG="$DIR/$bench-th$thread-legacy_$legacy_intv-runs-log.txt"
        PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
        legacy_time=$(get_time $bench $thread 1)
        echo -ne "\t$legacy_time" >> $PER_THREAD_STAT_FILE
        echo -e "$thread\t$legacy_time" >> $LEGACY_STAT_FILE
        echo "Bench: $bench - Thread $thread - ${legacy_time}ms" | tee -a $DEBUG_FILE
      done
    done
  done

  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/phoenix-perf_stats-th$thread-ad$AD.txt"
    echo "" >> $PER_THREAD_STAT_FILE
    final_thread=$thread
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
