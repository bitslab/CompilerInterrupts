#!/bin/bash
CI=1000
PI=1000000
RUNS=10
AD=100
DIR=splash2_stats
pinning=0
THREADS="1 2 4 8 16 32 64"
THREADS="1"
PASSED_LC=1

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_time() {
  rm -f out
  threads=$2
  BENCH_LOG="$DIR/$1-th$threads-runs-log.txt"
  suffix_conf=$3
  if [ $suffix_conf -eq 0 ]; then
    suffix="orig"
  else
    suffix="lc"
  fi
  if [ $pinning -eq 1 ]; then
    prefix="timeout 5m taskset 0x00000001 "
  else
    prefix="timeout 5m "
  fi

  DIVISOR=`expr $RUNS \* 1000`
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $RUNS`
  do
    case "$1" in
      water-nsquared)
        cd water-nsquared > /dev/null
        $prefix ./water-nsquared-$suffix < input.$threads > ../out
        cd - > /dev/null
      ;;
      water-spatial)
        cd water-spatial > /dev/null
        $prefix ./water-spatial-$suffix < input.$threads > ../out
        cd - > /dev/null
      ;;
      ocean-cp) 
        cd ocean/contiguous_partitions > /dev/null
        $prefix ./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > ../../out
        cd - > /dev/null
      ;;
      ocean-ncp) 
        cd ocean/non_contiguous_partitions > /dev/null
        $prefix ./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > ../../out
        cd - > /dev/null
      ;;
      barnes)
        cd barnes > /dev/null
        $prefix ./barnes-$suffix < input.$threads > ../out
        cd - > /dev/null
      ;;
      volrend)
        cd volrend > /dev/null
        $prefix ./volrend-$suffix $threads inputs/head > ../out
        cd - > /dev/null
      ;;
      fmm)
        cd fmm > /dev/null
        $prefix ./fmm-$suffix < inputs/input.65535.$threads > ../out
        cd - > /dev/null
      ;;
      raytrace)
        cd raytrace > /dev/null
        $prefix ./raytrace-$suffix -p $threads -m72 inputs/balls4.env > ../out
        cd - > /dev/null
      ;;
      radiosity)
        cd radiosity > /dev/null
        $prefix ./radiosity-$suffix -p $threads -batch -largeroom > ../out
        cd - > /dev/null
      ;;
    esac
    time_in_us=`cat out | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    echo $time_in_us | tr -d '\n' >> sum
    echo $time_in_us >> $BENCH_LOG
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
    if [ $PASSED_LC -eq 1 ]; then
      echo -e "benchmark\torig_clock\tnaive_ci\topt_ci_periodic\topt_ci_eager\tpassed_naive_ci\t passed_periodic_ci" > $PER_THREAD_STAT_FILE
    else
      echo -e "benchmark\torig_clock\tnaive_ci\topt_ci_periodic\topt_ci_eager" > $PER_THREAD_STAT_FILE
    fi
  done

  for bench in $*
  do
    ORIG_STAT_FILE="$DIR/$bench-perf_orig-ad$AD.txt"
    PERIODIC_STAT_FILE="$DIR/$bench-perf_periodic-ad$AD.txt"
    EAGER_STAT_FILE="$DIR/$bench-perf_eager-ad$AD.txt"
    NAIVE_STAT_FILE="$DIR/$bench-perf_naive-ad$AD.txt"
    echo "************* $bench ***************" | tee -a $LOG_FILE $DEBUG_FILE 
    echo "pthread" > $ORIG_STAT_FILE
    echo "periodic" > $PERIODIC_STAT_FILE
    echo "eager" > $EAGER_STAT_FILE
    echo "naive" > $NAIVE_STAT_FILE
    if [ "$bench" != "raytrace" ] || [ "$bench" != "fmm" ] || [ "$bench" != "radiosity" ]; then
      if [ $PASSED_LC -eq 1 ]; then
        PASSED_NAIVE_STAT_FILE="$DIR/$bench-perf_passed_naive-ad$AD.txt"
        PASSED_PERIODIC_STAT_FILE="$DIR/$bench-perf_passed_periodic-ad$AD.txt"
        echo "periodic-passed" > $PASSED_PERIODIC_STAT_FILE
        echo "naive-passed" > $PASSED_NAIVE_STAT_FILE
      fi
    fi

    for thread in $THREADS
    do
      BENCH_LOG="$DIR/$1-th$threads-runs-log.txt"
      echo "Runs:$RUNS" > $BENCH_LOG
    done

    #run original 
    echo "Building original program: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench 
    echo "Running original program: " >> $DEBUG_FILE
    for thread in $THREADS
    do
      echo "PThread" >> $BENCH_LOG
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
      orig_time=$(get_time $bench $thread 0)
      echo -ne "$bench" >> $PER_THREAD_STAT_FILE
      echo -ne "\t$orig_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$orig_time" >> $ORIG_STAT_FILE
    done

    #run naive
    echo "Building naive program: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -f Makefile.lc $bench 
    echo "Running naive program: " >> $DEBUG_FILE
    for thread in $THREADS
    do
      echo "Naive" >> $BENCH_LOG
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
      naive_time=$(get_time $bench $thread 1)
      echo -ne "\t$naive_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$naive_time" >> $NAIVE_STAT_FILE
    done

    #run periodic
    echo "Building periodic opt program: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench
    echo "Running periodic opt program: " >> $DEBUG_FILE
    for thread in $THREADS
    do
      echo "Periodic" >> $BENCH_LOG
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
      opt_time_periodic=$(get_time $bench $thread 1)
      echo -ne "\t$opt_time_periodic" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$opt_time_periodic" >> $PERIODIC_STAT_FILE
    done

    #run eager
    echo "Building eager opt program: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=0 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench
    echo "Running eager program: " >> $DEBUG_FILE
    for thread in $THREADS
    do
      echo "Eager" >> $BENCH_LOG
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
      opt_time_eager=$(get_time $bench $thread 1)
      echo -ne "\t$opt_time_eager" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$opt_time_eager" >> $EAGER_STAT_FILE
    done

    if [ "$bench" != "raytrace" ] || [ "$bench" != "fmm" ] || [ "$bench" != "radiosity" ]; then
      if [ $PASSED_LC -eq 1 ]; then
        #run naive passed LC
        echo "Building naive program: " >> $DEBUG_FILE
        BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
        BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE CONFIG=3 ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -f Makefile.lc $bench 
        echo "Running passed naive program: " >> $DEBUG_FILE
        for thread in $THREADS
        do
          echo "Naive" >> $BENCH_LOG
          PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
          passed_naive_time=$(get_time $bench $thread 1)
          echo -ne "\t$passed_naive_time" >> $PER_THREAD_STAT_FILE
          echo -e "$thread\t$passed_naive_time" >> $PASSED_NAIVE_STAT_FILE
        done

        #run periodic passed LC
        echo "Building passed periodic opt program: " >> $DEBUG_FILE
        BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
        BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE CONFIG=3 ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench
        echo "Running periodic opt program: " >> $DEBUG_FILE
        for thread in $THREADS
        do
          echo "Periodic" >> $BENCH_LOG
          PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
          passed_opt_time_periodic=$(get_time $bench $thread 1)
          echo -ne "\t$passed_opt_time_periodic" >> $PER_THREAD_STAT_FILE
          echo -e "$thread\t$passed_opt_time_periodic" >> $PASSED_PERIODIC_STAT_FILE
        done
      fi
    fi

    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD.txt"
      echo "" >> $PER_THREAD_STAT_FILE
      final_thread=$thread
    done

    #Print
    echo "Statistics for $final_thread thread(s)"
    echo "Original Time: $orig_time ms" | tee -a $LOG_FILE
    echo "Naive Time: $naive_time ms" | tee -a $LOG_FILE
    echo "Optimized Periodic Time: $opt_time_periodic ms" | tee -a $LOG_FILE
    echo "Passed Naive Time: $passed_naive_time ms" | tee -a $LOG_FILE
    echo "Passed Optimized Periodic Time: $passed_opt_time_periodic ms" | tee -a $LOG_FILE

    slowdown_opt_periodic=`echo "scale = 3; ($opt_time_periodic / $orig_time)" | bc -l`
    slowdown_opt_eager=`echo "scale = 3; ($opt_time_eager / $orig_time)" | bc -l`
    slowdown_naive=`echo "scale = 3; ($naive_time / $orig_time)" | bc -l`
    slowdown_naive_opt_periodic=`echo "scale = 3; ($naive_time / $opt_time_periodic)" | bc -l`
    slowdown_naive_opt_eager=`echo "scale = 3; ($naive_time / $opt_time_eager)" | bc -l`
    slowdown_passed_opt_periodic=`echo "scale = 3; ($passed_opt_time_periodic / $orig_time)" | bc -l`
    slowdown_passed_naive=`echo "scale = 3; ($passed_naive_time / $orig_time)" | bc -l`
    echo "Slowdown of naive instrumentation over opt periodic instrumentation: ${slowdown_naive_opt_periodic}x" | tee -a $LOG_FILE
    echo "Slowdown of naive instrumentation over opt eager instrumentation: ${slowdown_naive_opt_eager}x" | tee -a $LOG_FILE
    echo "Slowdown of optimal periodic instrumentation over original program: ${slowdown_opt_periodic}x" | tee -a $LOG_FILE
    echo "Slowdown of optimal eager instrumentation over original program: ${slowdown_opt_eager}x" | tee -a $LOG_FILE
    echo "Slowdown of passed optimal periodic instrumentation over original program: ${slowdown_passed_opt_periodic}x" | tee -a $LOG_FILE
    echo "Slowdown of passed naive instrumentation over original program: ${slowdown_passed_naive}x" | tee -a $LOG_FILE
  done
}

#1 - benchmark name (optional)
run_accuracy_test() {
  if [ $# -eq 0 ]; then
    accuracy_test water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
  else
    accuracy_test $@ 
  fi
}

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
#CLOCK=1; perf_test raytrace radiosity barnes ocean-cp ocean-ncp volrend fmm water-nsquared water-spatial
#CLOCK=0; perf_test water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
  else
    perf_test $@
#CLOCK=0; perf_test $@
  fi
}

echo "Note: Script has performance tests for both instantaneous & predictive clocks."
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: $THREADS, PINNED?: $pinning, Output Directory: $DIR"
mkdir -p $DIR;

if [ $# -eq 0 ]; then
  #run_accuracy_test
  run_perf_test
else
  #run_accuracy_test $@
  run_perf_test $@
fi

rm -f out sum
