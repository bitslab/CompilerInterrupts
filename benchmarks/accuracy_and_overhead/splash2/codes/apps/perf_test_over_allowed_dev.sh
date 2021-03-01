#!/bin/bash
CI=1000
PI="5000"
RUNS=5
AD="0 100 200 300 500 700 1000"
DIR=splash2_stats
CLOCK=1 #0 - predictive, 1 - instantaneous
THREAD="1"

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_time() {
  rm -f out
  threads=1
  suffix_conf=$2
  out_file=$3
  declare suffix
  if [ $suffix_conf -eq 0 ]; then
    suffix="orig"
  else
    suffix="lc"
  fi
  prefix="taskset 0x00000001 "

  DIVISOR=$RUNS
  DIVISOR_IN_MS=`expr $RUNS \* 1000`
  rm -f sum_duration sum_avg_intv_cycles sum_avg_intv_dev_cycles sum_avg_intv_ic sum_avg_intv_error_ic sum_avg_intv_dev_ic sum_avg_intv_ret_ic sum_avg_intv_dev_ret_ic
  echo -n "scale=2;(" | tee sum_duration sum_avg_intv_cycles sum_avg_intv_dev_cycles sum_avg_intv_ic sum_avg_intv_error_ic sum_avg_intv_dev_ic sum_avg_intv_ret_ic sum_avg_intv_dev_ret_ic > /dev/null
  for j in `seq 1 $RUNS`
  do
    case "$1" in
      water-nsquared)
        cd water-nsquared > /dev/null
        $prefix ./water-nsquared-$suffix < input.$threads > ../out
        echo "$prefix ./water-nsquared-$suffix < input.$threads > ../out" >> ../$DEBUG_FILE
        cd - > /dev/null
      ;;
      water-spatial)
        cd water-spatial > /dev/null
        $prefix ./water-spatial-$suffix < input.$threads > ../out
        echo "$prefix ./water-spatial-$suffix < input.$threads > ../out" >> ../$DEBUG_FILE
        cd - > /dev/null
      ;;
      ocean-cp) 
        cd ocean/contiguous_partitions > /dev/null
        $prefix ./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > ../../out
        echo "$prefix ./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > ../../out" >> ../../$DEBUG_FILE
        cd - > /dev/null
      ;;
      ocean-ncp) 
        cd ocean/non_contiguous_partitions > /dev/null
        $prefix ./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > ../../out
        echo "$prefix ./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > ../../out" >> ../../$DEBUG_FILE
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
    echo $time_in_us | tr -d '\n' >> sum_duration
    if [ $j -lt $RUNS ]; then
      echo -n "+" >> sum_duration
    fi

    if [ $suffix_conf -eq 1 ]; then
      avg_intv_cycles=`cat out | grep "avg_intv_cycles" | cut -d "," -f 1 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_dev_cycles=`cat out | grep "avg_intv_dev_cycles" | cut -d "," -f 2 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_ic=`cat out | grep "avg_intv_ic" | cut -d "," -f 1 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_dev_ic=`cat out | grep "avg_intv_dev_ic" | cut -d "," -f 2 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_ret_ic=`cat out | grep "avg_intv_ret_ic" | cut -d "," -f 1 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_dev_ret_ic=`cat out | grep "avg_intv_dev_ret_ic" | cut -d "," -f 2 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_error_ic=`echo "$avg_intv_ic-$PI" | bc`
      echo $avg_intv_cycles | tr -d '\n' >> sum_avg_intv_cycles 
      echo $avg_intv_dev_cycles | tr -d '\n' >> sum_avg_intv_dev_cycles 
      echo $avg_intv_ic | tr -d '\n' >> sum_avg_intv_ic 
      echo $avg_intv_error_ic | tr -d '\n' >> sum_avg_intv_error_ic 
      echo $avg_intv_dev_ic | tr -d '\n' >> sum_avg_intv_dev_ic
      echo $avg_intv_ret_ic | tr -d '\n' >> sum_avg_intv_ret_ic 
      echo $avg_intv_dev_ret_ic | tr -d '\n' >> sum_avg_intv_dev_ret_ic
      echo "Duration:$time_in_us us" >> $DEBUG_FILE
      echo -e "Run $j - Intv Cycles: $avg_intv_cycles, Intv Dev Cycles:$avg_intv_dev_cycles, Intv IC:$avg_intv_ic, Intv Error IC:$avg_intv_error_ic, $Intv Dev IC:$avg_intv_dev_ic, Intv Ret Inst: $avg_intv_ret_ic, Intv Dev Ret Inst: $avg_intv_dev_ret_ic" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        echo -n "+" | tee -a sum_avg_intv_cycles sum_avg_intv_dev_cycles sum_avg_intv_ic sum_avg_intv_error_ic sum_avg_intv_dev_ic sum_avg_intv_ret_ic sum_avg_intv_dev_ret_ic > /dev/null
      fi
    fi
  done

  echo ")/$DIVISOR_IN_MS" | tee -a sum_duration > /dev/null
  time_in_ms=`cat sum_duration | bc`

  if [ $suffix_conf -eq 1 ]; then
    echo ")/$DIVISOR" | tee -a sum_avg_intv_cycles sum_avg_intv_dev_cycles sum_avg_intv_ic sum_avg_intv_error_ic sum_avg_intv_dev_ic sum_avg_intv_ret_ic sum_avg_intv_dev_ret_ic > /dev/null
    avg_intv_cycles=`cat sum_avg_intv_cycles | bc`
    avg_intv_dev_cycles=`cat sum_avg_intv_dev_cycles | bc`
    avg_intv_ic=`cat sum_avg_intv_ic | bc`
    avg_intv_error_ic=`cat sum_avg_intv_error_ic | bc`
    avg_intv_dev_ic=`cat sum_avg_intv_dev_ic | bc`
    avg_intv_ret_ic=`cat sum_avg_intv_ret_ic | bc`
    avg_intv_dev_ret_ic=`cat sum_avg_intv_dev_ret_ic | bc`
    echo -ne "$avg_intv_cycles,$avg_intv_dev_cycles,$avg_intv_ic,$avg_intv_error_ic,$avg_intv_dev_ic,$avg_intv_ret_ic,$avg_intv_dev_ret_ic," >> $out_file
    echo -ne "Average of all runs:-\nIntv Cycles: $avg_intv_cycles, Intv Dev Cycles:$avg_intv_dev_cycles,Intv IC:$avg_intv_ic, Int Error IC:$avg_intv_error_ic, Intv Dev IC:$avg_intv_dev_ic, Intv Ret Inst: $avg_intv_ret_ic, Intv Dev Ret Inst: $avg_intv_dev_ret_ic, " >> $DEBUG_FILE
  fi

  echo "$time_in_ms" >> $out_file
  echo -e "Duration:$time_in_ms ms" >> $DEBUG_FILE

  rm -f sum_duration sum_avg_intv_cycles sum_avg_intv_dev_cycles sum_avg_intv_ic sum_avg_intv_error_ic sum_avg_intv_dev_ic sum_avg_intv_ret_ic sum_avg_intv_dev_ret_ic
}

get_pc() {
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
  case "$1" in
    water-nsquared)
      cd water-nsquared > /dev/null
      $prefix ./water-nsquared-$suffix < input.$threads > ../out
      echo "$prefix ./water-nsquared-$suffix < input.$threads > ../out" >> ../$DEBUG_FILE
      cd - > /dev/null
    ;;
    water-spatial)
      cd water-spatial > /dev/null
      $prefix ./water-spatial-$suffix < input.$threads > ../out
      echo "$prefix ./water-spatial-$suffix < input.$threads > ../out" >> ../$DEBUG_FILE
      cd - > /dev/null
    ;;
    ocean-cp) 
      cd ocean/contiguous_partitions > /dev/null
      $prefix ./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > ../../out
      echo "$prefix ./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > ../../out" >> ../../$DEBUG_FILE
      cd - > /dev/null
    ;;
    ocean-ncp) 
      cd ocean/non_contiguous_partitions > /dev/null
      $prefix ./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > ../../out
      echo "$prefix ./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > ../../out" >> ../../$DEBUG_FILE
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
  pc=`cat out | grep "Number of Push Operations: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
#cat out >> $DEBUG_FILE
  echo "Push count: $pc" >> $DEBUG_FILE
  echo $pc
}

perf_test() {
  echo "=================================== PERFORMANCE TEST ==========================================="
  BUILD_ERROR_FILE="$DIR/perf_test_build_error.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log.txt"
  fiber_working=1

  rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE

  for bench in $*
  do
    PER_BENCH_ORIG_STAT_FILE="$DIR/$bench-acc_vs_perf_orig-cl$CLOCK.txt"
    PER_BENCH_LC_STAT_FILE="$DIR/$bench-acc_vs_perf_lc-cl$CLOCK.txt"
    PER_BENCH_ORIG_FIBER_STAT_FILE="$DIR/$bench-acc_vs_perf_orig_fiber-cl$CLOCK.txt"
    PER_BENCH_LC_FIBER_STAT_FILE="$DIR/$bench-acc_vs_perf_lc_fiber-cl$CLOCK.txt"

    echo "************* $bench ***************" | tee -a $DEBUG_FILE 
    echo "Pthread" > $PER_BENCH_ORIG_STAT_FILE
    echo "Pthread-LC" > $PER_BENCH_LC_STAT_FILE
    echo "LibFiber" > $PER_BENCH_ORIG_FIBER_STAT_FILE
    echo "LibFiber-LC" > $PER_BENCH_LC_FIBER_STAT_FILE
    echo "Duration(in ms)" | tee -a $DEBUG_FILE $PER_BENCH_ORIG_STAT_FILE $PER_BENCH_ORIG_FIBER_STAT_FILE > /dev/null 

    if [ "$bench" = "fmm" ] || [ "$bench" = "barnes" ] || [ "$bench" = "volrend" ] || [ "$bench" = "radiosity" ]; then
      fiber_working=0
    else
      fiber_working=1
    fi

    #1. Build original program with pthread
    echo "Building original pthread program: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench 
    get_time $bench 0 $PER_BENCH_ORIG_STAT_FILE

    if [ $fiber_working -eq 1 ]; then
      #2. Build original program with fiber
      echo "Building original pthread program with fiber: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig.libfiber $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig.libfiber $bench 
      get_time $bench 0 $PER_BENCH_ORIG_FIBER_STAT_FILE
    fi

    echo "Allowed Deviation, Interval(in Cycles), Interval Deviation(in Cycles), Interval(Instruction Count), Interval Error(Instruction Count), Interval Deviation(Instruction Count), Interval(in ret. inst), Interval Deviation(in ret. inst), Duration(in ms)" | tee -a $DEBUG_FILE $PER_BENCH_LC_STAT_FILE $PER_BENCH_LC_FIBER_STAT_FILE > /dev/null
    for ad in $AD
    do
      #3. Build original program with pthread & LC
      echo "Building pthread program with logical clock (Allowed Dev : $ad): " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$ad CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench
      echo -n "$ad," >> $PER_BENCH_LC_STAT_FILE
      echo "Allowed Deviation: $ad" >> $DEBUG_FILE
      get_time $bench 1 $PER_BENCH_LC_STAT_FILE
    done

    if [ $fiber_working -eq 1 ]; then
      for ad in $AD
      do
        #4. Build original program with pthread & LC & fiber
        echo "Building pthread program with logical clock & fiber (Allowed Dev : $ad): " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
        BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc.libfiber $bench-clean
        BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$ad CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc.libfiber $bench
        echo -n "$ad," >> $PER_BENCH_LC_FIBER_STAT_FILE
        echo "Allowed Deviation: $ad" >> $DEBUG_FILE
        get_time $bench 1 $PER_BENCH_LC_FIBER_STAT_FILE
      done
    fi
  done
}

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
  else
    perf_test $@
  fi
}

#echo "Note: Script has both accuracy tests & performance tests. Change the mode in the next few lines if any one of them is required only. "
#echo "Note: Number of threads for running performance tests need to be configured inside the file"
echo "Configured values:-"
echo "Clock type: $CLOCK, Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: $THREAD, Output Directory: $DIR, Threads are pinned to 1 core, or fibers run on single thread"
echo "Usage: ./perf_test_libfiber <nothing / space separated list of splash2 benchmarks>"
mkdir -p $DIR
DEBUG_FILE="$DIR/perf_debug.txt"
if [ $# -eq 0 ]; then
  run_perf_test
else
  run_perf_test $@
fi

rm -f out sum
