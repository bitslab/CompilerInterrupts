#!/bin/bash
CI=1000
PI=1000000
RUNS=20
AD=100
DIR=phoenix_stats
pinning=0
THREADS="1"
THREADS="1 2 4 8 16 32 64"
PASSED_LC=0

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_time() {
  rm -f out
  threads=$2
  program=$1

  DIVISOR=`expr $RUNS \* 1000`
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $RUNS`
  do
    case "$program" in
      histogram)
        MR_NUMTHREADS=$threads ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp > out 2>&1
      ;;
      kmeans)
        MR_NUMTHREADS=$threads ./tests/$program/$program -d 100 -c 10 -p 500000 -s 50 > out 2>&1
      ;;
      pca) 
        MR_NUMTHREADS=$threads ./tests/$program/$program -r 1000 -c 1000 -s 1000 > out 2>&1
      ;;
      matrix_multiply) 
        MR_NUMTHREADS=$threads ./tests/$program/$program 900 600 1 > out 2>&1
      ;;
      string_match)
        MR_NUMTHREADS=$threads ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_100MB.txt > out 2>&1
      ;;
      linear_regression)
        MR_NUMTHREADS=$threads ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_500MB.txt > out 2>&1
      ;;
      word_count)
        MR_NUMTHREADS=$threads ./tests/$program/$program ../input_datasets/${program}_datafiles/word_50MB.txt > out 2>&1
      ;;
    esac
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
  echo "=================================== PERFORMANCE TEST (BOTH CLOCKS) ==========================================="
  LOG_FILE="$DIR/perf_logs-ad$AD.txt"
  DEBUG_FILE="$DIR/perf_debug-ad$AD.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error-ad$AD.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log-ad$AD.txt"
  #FIBER_CONFIG is set in the Makefile. Unless needed, do not pass a new config from this script

  rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE

  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
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
    EAGER_STAT_FILE="$DIR/$bench-perf_eager-ad$AD.txt"
    NAIVE_STAT_FILE="$DIR/$bench-perf_naive-ad$AD.txt"
    echo "pthread" > $ORIG_STAT_FILE
    echo "periodic" > $PERIODIC_STAT_FILE
    echo "eager" > $EAGER_STAT_FILE
    echo "naive" > $NAIVE_STAT_FILE
    if [ "$bench" != "raytrace" ] || [ "$bench" != "fmm" ] || [ "$bench" != "radiosity" ]; then
      if [ $PASSED_LC -eq 1 ]; then
        PASSED_NAIVE_STAT_FILE="$DIR/$bench-perf_passed_naive-ad$AD.txt"
        PASSED_EAGER_STAT_FILE="$DIR/$bench-perf_passed_eager-ad$AD.txt"
        PASSED_PERIODIC_STAT_FILE="$DIR/$bench-perf_passed_periodic-ad$AD.txt"
        echo "periodic-passed" > $PASSED_PERIODIC_STAT_FILE
        echo "eager-passed" > $PASSED_EAGER_STAT_FILE
        echo "naive-passed" > $PASSED_NAIVE_STAT_FILE
      fi
    fi
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-th$thread-orig-runs-log.txt"
      echo "PThread - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-th$thread-naive-runs-log.txt"
      echo "Naive TL - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-th$thread-tl-periodic-runs-log.txt"
      echo "Periodic TL - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-th$thread-tl-eager-runs-log.txt"
      echo "Eager TL - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-th$thread-passed-naive-runs-log.txt"
      echo "Naive Passed - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-th$thread-passed-periodic-runs-log.txt"
      echo "Periodic Passed - Thread $thread, $RUNS runs" > $BENCH_LOG
      BENCH_LOG="$DIR/$bench-th$thread-passed-eager-runs-log.txt"
      echo "Eager Passed - Thread $thread, $RUNS runs" > $BENCH_LOG
    done
  done

# temp closed
  if [ 0 -eq 1 ]; then
  #run original 
  echo "Building original program: " | tee -a $DEBUG_FILE
  make -f Makefile.orig clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  make -f Makefile.orig >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  echo "Running original program: " | tee -a $DEBUG_FILE
  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
    echo -ne "Orig" >> $PER_THREAD_STAT_FILE
  done
  for bench in $*
  do
    ORIG_STAT_FILE="$DIR/$bench-perf_orig-ad$AD.txt"
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-th$thread-orig-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
      orig_time=$(get_time $bench $thread 0)
      echo -ne "\t$orig_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$orig_time" >> $ORIG_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${orig_time}ms" | tee -a $DEBUG_FILE
    done
  done
  fi

  #run naive
  echo "Building naive program: " | tee -a $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  echo "Running naive program: " | tee -a $DEBUG_FILE
  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
    echo "" >> $PER_THREAD_STAT_FILE
    echo -ne "Naive" >> $PER_THREAD_STAT_FILE
  done
  for bench in $*
  do
    NAIVE_STAT_FILE="$DIR/$bench-perf_naive-ad$AD.txt"
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-th$thread-naive-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
      naive_time=$(get_time $bench $thread 1)
      echo -ne "\t$naive_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$naive_time" >> $NAIVE_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${naive_time}ms" | tee -a $DEBUG_FILE
    done
  done

# temp closed
  if [ 0 -eq 1 ]; then
  #run periodic
  echo "Building periodic opt program: " | tee -a $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  echo "Running periodic opt program: " | tee -a $DEBUG_FILE
  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
    echo "" >> $PER_THREAD_STAT_FILE
    echo -ne "Periodic-TL" >> $PER_THREAD_STAT_FILE
  done
  for bench in $*
  do
    PERIODIC_STAT_FILE="$DIR/$bench-perf_periodic-ad$AD.txt"
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-th$thread-tl-periodic-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
      opt_time_periodic=$(get_time $bench $thread 1)
      echo -ne "\t$opt_time_periodic" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$opt_time_periodic" >> $PERIODIC_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${opt_time_periodic}ms" | tee -a $DEBUG_FILE
    done
  done

  #run eager
  echo "Building eager opt program: " | tee -a $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=0 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  echo "Running eager program: " | tee -a $DEBUG_FILE
  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
    echo "" >> $PER_THREAD_STAT_FILE
    echo -ne "Eager-TL" >> $PER_THREAD_STAT_FILE
  done
  for bench in $*
  do
    EAGER_STAT_FILE="$DIR/$bench-perf_eager-ad$AD.txt"
    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$bench-th$thread-tl-eager-runs-log.txt"
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
      opt_time_eager=$(get_time $bench $thread 1)
      echo -ne "\t$opt_time_eager" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$opt_time_eager" >> $EAGER_STAT_FILE
      echo "Bench: $bench - Thread $thread - ${opt_time_eager}ms" | tee -a $DEBUG_FILE
    done
  done
  fi

  if [ $PASSED_LC -eq 1 ]; then
    #run naive passed LC
    echo "Building naive program: " | tee -a $DEBUG_FILE
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    CONFIG=3 ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running passed naive program: " | tee -a $DEBUG_FILE
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
      echo "" >> $PER_THREAD_STAT_FILE
      echo -ne "Naive-Passed" >> $PER_THREAD_STAT_FILE
    done
    for bench in $*
    do
      PASSED_NAIVE_STAT_FILE="$DIR/$bench-perf_passed_naive-ad$AD.txt"
      for thread in $THREADS
      do
        BENCH_LOG="$DIR/$bench-th$thread-passed-naive-runs-log.txt"
        PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
        passed_naive_time=$(get_time $bench $thread 1)
        echo -ne "\t$passed_naive_time" >> $PER_THREAD_STAT_FILE
        echo -e "$thread\t$passed_naive_time" >> $PASSED_NAIVE_STAT_FILE
        echo "Bench: $bench - Thread $thread - ${passed_naive_time}ms" | tee -a $DEBUG_FILE
      done
    done

    #run periodic passed LC
    echo "Building passed periodic opt program: " | tee -a $DEBUG_FILE
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    CONFIG=3 ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running passed periodic opt program: " | tee -a $DEBUG_FILE
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
      echo "" >> $PER_THREAD_STAT_FILE
      echo -ne "Periodic-Passed" >> $PER_THREAD_STAT_FILE
    done
    for bench in $*
    do
      PASSED_PERIODIC_STAT_FILE="$DIR/$bench-perf_passed_periodic-ad$AD.txt"
      for thread in $THREADS
      do
        BENCH_LOG="$DIR/$bench-th$thread-passed-periodic-runs-log.txt"
        PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
        passed_opt_time_periodic=$(get_time $bench $thread 1)
        echo -ne "\t$passed_opt_time_periodic" >> $PER_THREAD_STAT_FILE
        echo -e "$thread\t$passed_opt_time_periodic" >> $PASSED_PERIODIC_STAT_FILE
        echo "Bench: $bench - Thread $thread - ${passed_opt_time_periodic}ms" | tee -a $DEBUG_FILE
      done
    done

    #run eager passed LC
    echo "Building passed eager opt program: " | tee -a $DEBUG_FILE
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    CONFIG=3 ALLOWED_DEVIATION=$AD CLOCK_TYPE=0 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running passed eager opt program: " | tee -a $DEBUG_FILE
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
      echo "" >> $PER_THREAD_STAT_FILE
      echo -ne "Eager-Passed" >> $PER_THREAD_STAT_FILE
    done
    for bench in $*
    do
      PASSED_EAGER_STAT_FILE="$DIR/$bench-perf_passed_eager-ad$AD.txt"
      for thread in $THREADS
      do
        BENCH_LOG="$DIR/$bench-th$thread-passed-eager-runs-log.txt"
        PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
        passed_opt_time_eager=$(get_time $bench $thread 1)
        echo -ne "\t$passed_opt_time_eager" >> $PER_THREAD_STAT_FILE
        echo -e "$thread\t$passed_opt_time_eager" >> $PASSED_EAGER_STAT_FILE
        echo "Bench: $bench - Thread $thread - ${passed_opt_time_eager}ms" | tee -a $DEBUG_FILE
      done
    done
  fi

  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
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
    perf_test histogram kmeans pca matrix_multiply string_match linear_regression word_count
  else
    perf_test $@
  fi
}

echo "Note: Script has performance tests for both instantaneous & predictive clocks."
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: $THREADS, PINNED?: $pinning, Output Directory: $DIR"
echo "WARNING: Remove Passed Config if you don't need it!"
mkdir -p $DIR;

if [ $# -eq 0 ]; then
  run_perf_test
else
  run_perf_test $@
fi

rm -f out sum
