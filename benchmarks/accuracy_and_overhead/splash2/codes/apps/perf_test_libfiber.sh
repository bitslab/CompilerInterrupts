#!/bin/bash
CI=1000
PI=5000
RUNS=10
AD=0
DIR=libfiber_benchmark
CLOCK=1 #0 - predictive, 1 - instantaneous
THREADS="1 2 4 8 16 32"

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_lc() {
  rm -f out
  threads=$2
  suffix_conf=$3
  declare suffix
  if [ $suffix_conf -eq 0 ]; then
    suffix="orig"
  else
    suffix="lc"
  fi

  case "$1" in
    water-ns)
      cd water-nsquared > /dev/null
      ./water-nsquared-$suffix < input.$threads > ../out
      cd - > /dev/null
    ;;
    water-sp)
      cd water-spatial > /dev/null
      ./water-spatial-$suffix < input.$threads > ../out
      cd - > /dev/null
    ;;
    ocean-cp) 
      cd ocean/contiguous_partitions > /dev/null
      ./ocean-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > ../../out
      cd - > /dev/null
    ;;
    ocean-ncp) 
      cd ocean/non_contiguous_partitions > /dev/null
      ./ocean-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > ../../out
      cd - > /dev/null
    ;;
    barnes)
      cd barnes > /dev/null
      ./barnes-$suffix < input.$threads > ../out
      cd - > /dev/null
    ;;
    volrend)
      cd volrend > /dev/null
      ./volrend-$suffix $threads inputs/head > ../out
      cd - > /dev/null
    ;;
    fmm)
      cd fmm > /dev/null
      ./fmm-$suffix < inputs/input.65535.$threads > ../out
      cd - > /dev/null
    ;;
    raytrace)
      cd raytrace > /dev/null
      ./raytrace-$suffix -p $threads -m72 inputs/balls4.env > ../out
      cd - > /dev/null
    ;;
    radiosity)
      cd radiosity > /dev/null
      ./radiosity-$suffix -p $threads -batch -largeroom > ../out
      cd - > /dev/null
    ;;
  esac
}

#1 - benchmarks (one or more bench names)
accuracy_test() {
  echo "===================================== ACCURACY TEST ============================================"
  STAT_FILE="$DIR/accuracy_stats-$AD.csv"
  LOG_FILE="$DIR/accuracy_logs-$AD.txt"
  BUILD_DEBUG_FILE="$DIR/acc_test_build_log-$AD.txt"
  BUILD_ERROR_FILE="$DIR/acc_test_build_error-$AD.txt"

  rm -f $STAT_FILE $LOG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
  echo -e "benchmark\tnaive_clock\topt_clock" >> $STAT_FILE

  for bench in $*
  do
    echo "************* $bench ***************" | tee -a $LOG_FILE 
    echo -ne "$bench\t" >> $STAT_FILE

    #run naive
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -f Makefile.lc $bench 
    #Accuracy tests are run with 1 thread
    get_lc $bench 1 
    naive_lc=`cat out | grep "Logical Clock:" | tail -n 1 | cut -d: -f 2`
    echo -ne "\t$naive_lc" >> $STAT_FILE


    #run opt
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench
    #Accuracy tests are run with 1 thread
    get_lc $bench 1 
    opt_lc=`cat out | grep "Logical Clock:" | tail -n 1 | cut -d: -f 2`
    echo -ne "\t$opt_lc" >> $STAT_FILE

    #Print
    echo "Naive LC: $naive_lc" | tee -a $LOG_FILE
    echo "Optimized LC: $opt_lc" | tee -a $LOG_FILE
    if [ $naive_lc -gt $opt_lc ]; then
      err=`echo "scale = 5; (($naive_lc - $opt_lc) * 100 / $naive_lc)" | bc -l`
      echo "Err (in instrument count): $err% less" | tee -a $LOG_FILE
    else
      err=`echo "scale = 5; (($opt_lc - $naive_lc) * 100 / $naive_lc)" | bc -l`
      echo "Err (in instrument count): $err% more" | tee -a $LOG_FILE
    fi

    echo "" >> $STAT_FILE
  done
  rm -f out
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_time() {
  rm -f out
  threads=$2
  suffix_conf=$3
  declare suffix
  if [ $suffix_conf -eq 0 ]; then
    suffix="orig"
  else
    suffix="lc"
  fi
  if [ $4 -eq 1 ]; then
    prefix="taskset 0x00000001 "
  else
    prefix=""
  fi

  DIVISOR=`expr $RUNS \* 1000`
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $RUNS`
  do
    case "$1" in
      water-ns)
        cd water-nsquared > /dev/null
        $prefix ./water-nsquared-$suffix < input.$threads > ../out
        echo "$prefix ./water-nsquared-$suffix < input.$threads > ../out" >> ../$DEBUG_FILE
        cd - > /dev/null
      ;;
      water-sp)
        cd water-spatial > /dev/null
        $prefix ./water-spatial-$suffix < input.$threads > ../out
        echo "$prefix ./water-spatial-$suffix < input.$threads > ../out" >> ../$DEBUG_FILE
        cd - > /dev/null
      ;;
      ocean-cp) 
        cd ocean/contiguous_partitions > /dev/null
        $prefix ./ocean-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > ../../out
        echo "$prefix ./ocean-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > ../../out" >> ../../$DEBUG_FILE
        cd - > /dev/null
      ;;
      ocean-ncp) 
        cd ocean/non_contiguous_partitions > /dev/null
        $prefix ./ocean-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > ../../out
        echo "$prefix ./ocean-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > ../../out" >> ../../$DEBUG_FILE
        cd - > /dev/null
      ;;
      barnes)
        cd barnes > /dev/null
        $prefix ./barnes-$suffix < input.$threads > ../out
        echo "$prefix ./barnes-$suffix < input.$threads > ../out" >> ../$DEBUG_FILE
        cd - > /dev/null
      ;;
      volrend)
        cd volrend > /dev/null
        $prefix ./volrend-$suffix $threads inputs/head > ../out
        echo "$prefix ./volrend-$suffix $threads inputs/head > ../out" >> ../$DEBUG_FILE
        cd - > /dev/null
      ;;
      fmm)
        cd fmm > /dev/null
        $prefix ./fmm-$suffix < inputs/input.65535.$threads > ../out
        echo "$prefix ./fmm-$suffix < inputs/input.65535.$threads > ../out" >> ../$DEBUG_FILE
        cd - > /dev/null
      ;;
      raytrace)
        cd raytrace > /dev/null
        $prefix ./raytrace-$suffix -p $threads -m72 inputs/balls4.env > ../out
        echo "$prefix ./raytrace-$suffix -p $threads -m72 inputs/balls4.env > ../out" >> ../$DEBUG_FILE
        cd - > /dev/null
      ;;
      radiosity)
        cd radiosity > /dev/null
#$prefix ./radiosity-$suffix -p $threads -batch -largeroom > ../out
        $prefix ./radiosity-$suffix -p $threads -largeroom > ../out
        echo "$prefix ./radiosity-$suffix -p $threads -largeroom > ../out" >> ../$DEBUG_FILE
        cd - > /dev/null
      ;;
    esac
    time_in_us=`cat out | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    echo $time_in_us | tr -d '\n' >> sum
#cat out >> $DEBUG_FILE
    echo "$time_in_us us" >> $DEBUG_FILE
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
  LOG_FILE="$DIR/perf_logs-$AD.txt"
  DEBUG_FILE="$DIR/perf_debug-$AD.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error-$AD.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log-$AD.txt"
  declare final_thread

  rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE

  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.csv"
    echo -e "benchmark\torig\tlc\torig_fiber\tlc_fiber" > $PER_THREAD_STAT_FILE
  done

  for bench in $*
  do
    PER_BENCH_ORIG_STAT_FILE="$DIR/$bench-perf_orig-$AD.txt"
    PER_BENCH_LC_STAT_FILE="$DIR/$bench-perf_lc-$AD.txt"
    PER_BENCH_ORIG_FIBER_STAT_FILE="$DIR/$bench-perf_orig_fiber-$AD.txt"
    PER_BENCH_LC_FIBER_STAT_FILE="$DIR/$bench-perf_lc_fiber-$AD.txt"
    PER_BENCH_LC_ACCURACY_STAT_FILE="$DIR/$bench-accuracy-$AD.txt"
    echo "************* $bench ***************" | tee -a $LOG_FILE $DEBUG_FILE 
    echo "Thread, Duration" >> $LOG_FILE
    echo "Pthread" > $PER_BENCH_ORIG_STAT_FILE
    echo "Pthread-LC" > $PER_BENCH_LC_STAT_FILE
    echo "LibFiber" > $PER_BENCH_ORIG_FIBER_STAT_FILE
    echo "LibFiber-LC" > $PER_BENCH_LC_FIBER_STAT_FILE

    #1. Build original program with pthread
    echo "Building original pthread program: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench 

    declare orig_time_thr1 lc_time_thr1 orig_fiber_time_thr1 lc_fiber_time_thr1
    declare orig_ic lc_ic orig_fiber_ic lc_fiber_ic
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.csv"
      orig_time=$(get_time $bench $thread 0 1)
      echo -ne "$bench" >> $PER_THREAD_STAT_FILE
      echo -ne "\t$orig_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$orig_time" >> $PER_BENCH_ORIG_STAT_FILE
      echo -e "$thread, $orig_time (orig)" >> $LOG_FILE
      if [ $thread -eq 1 ]; then
#orig_ic=$(get_lc $bench $thread 0)
        orig_time_thr1=$orig_time
      fi
    done

    #2. Build original program with pthread & LC
    echo "Building pthread program with logical clock: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench

    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.csv"
      lc_time=$(get_time $bench $thread 1 1)
      echo -ne "\t$lc_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$lc_time" >> $PER_BENCH_LC_STAT_FILE
      echo -e "$thread, $lc_time (lc)" >> $LOG_FILE
      if [ $thread -eq 1 ]; then
#lc_ic=$(get_lc $bench $thread 1)
        lc_time_thr1=$lc_time
      fi
    done

    #3. Build original program with fiber
    echo "Building original program with fiber: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig.libfiber $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig.libfiber $bench 

    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.csv"
      orig_fiber_time=$(get_time $bench $thread 0 0)
      echo -ne "\t$orig_fiber_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$orig_fiber_time" >> $PER_BENCH_ORIG_FIBER_STAT_FILE
      echo -e "$thread, $orig_fiber_time (orig-fiber)" >> $LOG_FILE
      if [ $thread -eq 1 ]; then
#orig_fiber_ic=$(get_lc $bench $thread 0)
        orig_fiber_time_thr1=$orig_fiber_time
      fi
    done

    #4. Build original program with fiber & LC
    F_CONFIG=4 # reset after every yield/push operation
    echo "Building original program with fiber & logical clock with fiber-config $F_CONFIG: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc.libfiber $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 FIBER_CONFIG=$F_CONFIG make -f Makefile.lc.libfiber $bench 
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.csv"
      lc_fiber_time=$(get_time $bench $thread 1 0)
      echo -e "\t$lc_fiber_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$lc_fiber_time" >> $PER_BENCH_LC_FIBER_STAT_FILE
      echo -e "$thread, $lc_fiber_time (lc-fiber)" >> $LOG_FILE
      if [ $thread -eq 1 ]; then
#lc_fiber_ic=$(get_lc $bench $thread 1)
        lc_fiber_time_thr1=$lc_fiber_time
      fi
      final_thread=$thread
    done

    #Print
    echo "Statistics for 1 thread:-"
    echo "Original program with pthread duration: $orig_time_thr1 ms" | tee -a $LOG_FILE
    echo "Program with pthread & logical clock duration: $lc_time_thr1 ms" | tee -a $LOG_FILE
    echo "Original program with libfiber duration: $orig_fiber_time_thr1 ms" | tee -a $LOG_FILE
    echo "Program with logical clock & libfiber duration: $lc_fiber_time_thr1 ms" | tee -a $LOG_FILE
    slowdown_lc=`echo "scale = 3; ($lc_time_thr1 / $orig_time_thr1)" | bc -l`
    slowdown_fiber=`echo "scale = 3; ($orig_fiber_time_thr1 / $orig_time_thr1)" | bc -l`
    slowdown_lc_fiber=`echo "scale = 3; ($lc_fiber_time_thr1 / $orig_time_thr1)" | bc -l`
    echo "Slowdown of logical clock program over original: ${slowdown_lc}x" | tee -a $LOG_FILE
    echo "Slowdown of fiber integrated program over original: ${slowdown_fiber}x" | tee -a $LOG_FILE
    echo "Slowdown of fiber & logical clock integrated program over original: ${slowdown_lc_fiber}x" | tee -a $LOG_FILE
  done
}

#1 - benchmark name (optional)
run_accuracy_test() {
  if [ $# -eq 0 ]; then
    accuracy_test water-ns water-sp ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
  else
    accuracy_test $@ 
  fi
}

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test water-ns water-sp ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
  else
    perf_test $@
  fi
}

#echo "Note: Script has both accuracy tests & performance tests. Change the mode in the next few lines if any one of them is required only. "
#echo "Note: Number of threads for running performance tests need to be configured inside the file"
echo "Configured values:-"
echo "Clock type: $CLOCK, Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: $THREADS"
echo "Usage: ./perf_test_libfiber <nothing / space separated list of splash2 benchmarks>"
mkdir -p $DIR
if [ $# -eq 0 ]; then
  run_perf_test
else
  run_perf_test $@
fi

rm -f out sum
