#!/bin/bash
CI=1000
PI="5000 10000 20000 50000 75000 100000 150000"
RUNS=5
AD=100
DIR=splash2_stats
THREADS="1"

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_stats() {
  rm -f out
  threads=1
  out_file=$2
  suffix_conf=$3
  if [ $suffix_conf -eq 2 ]; then
    suffix="lc"
  else
    suffix="orig"
  fi
  prefix="timeout 5m taskset 0x00000001 "

  DIVISOR=$RUNS
  DIVISOR_IN_MS=`expr $RUNS \* 1000`
  rm -f sum_duration sum_avg_intv_cycles sum_avg_intv_dev_cycles sum_avg_intv_ic sum_avg_intv_dev_ic sum_avg_intv_ret_ic sum_avg_intv_dev_ret_ic
  echo -n "scale=2;(" | tee sum_duration sum_avg_intv_cycles sum_avg_intv_dev_cycles sum_avg_intv_ic sum_avg_intv_dev_ic sum_avg_intv_ret_ic sum_avg_intv_dev_ret_ic > /dev/null
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
    echo $time_in_us | tr -d '\n' >> sum_duration
    if [ $j -lt $RUNS ]; then
      echo -n "+" >> sum_duration
    fi

    if [ $suffix_conf -eq 2 ]; then

      # For LC
      avg_intv_cycles=`cat out | grep "avg_intv_cycles" | cut -d "," -f 1 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_dev_cycles=`cat out | grep "avg_intv_dev_cycles" | cut -d "," -f 2 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_ic=`cat out | grep "avg_intv_ic" | cut -d "," -f 1 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_dev_ic=`cat out | grep "avg_intv_dev_ic" | cut -d "," -f 2 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_ret_ic=`cat out | grep "avg_intv_ret_ic" | cut -d "," -f 1 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_dev_ret_ic=`cat out | grep "avg_intv_dev_ret_ic" | cut -d "," -f 2 | cut -d ":" -f 2 | tr -d '[:space:]'`
      echo $avg_intv_cycles | tr -d '\n' >> sum_avg_intv_cycles 
      echo $avg_intv_dev_cycles | tr -d '\n' >> sum_avg_intv_dev_cycles 
      echo $avg_intv_ic | tr -d '\n' >> sum_avg_intv_ic 
      echo $avg_intv_dev_ic | tr -d '\n' >> sum_avg_intv_dev_ic
      echo $avg_intv_ret_ic | tr -d '\n' >> sum_avg_intv_ret_ic 
      echo $avg_intv_dev_ret_ic | tr -d '\n' >> sum_avg_intv_dev_ret_ic
      echo -e "Run $j - Duration:$time_in_us us, Intv Cycles: $avg_intv_cycles, Intv Dev Cycles:$avg_intv_dev_cycles, Intv IC:$avg_intv_ic, Intv Dev IC:$avg_intv_dev_ic, Intv Ret Inst: $avg_intv_ret_ic, Intv Dev Ret Inst: $avg_intv_dev_ret_ic" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        echo -n "+" | tee -a sum_avg_intv_cycles sum_avg_intv_dev_cycles sum_avg_intv_ic sum_avg_intv_dev_ic sum_avg_intv_ret_ic sum_avg_intv_dev_ret_ic > /dev/null
      fi

    elif [ $suffix_conf -eq 1 ]; then

      # For PAPI
      avg_intv_cycles=`cat out | grep "avg_intv_cycles" | cut -d "," -f 1 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_dev_cycles=`cat out | grep "avg_intv_dev_cycles" | cut -d "," -f 2 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_ret_ic=`cat out | grep "avg_intv_ret_ic" | cut -d "," -f 1 | cut -d ":" -f 2 | tr -d '[:space:]'`
      avg_intv_dev_ret_ic=`cat out | grep "avg_intv_dev_ret_ic" | cut -d "," -f 2 | cut -d ":" -f 2 | tr -d '[:space:]'`
      echo $avg_intv_cycles | tr -d '\n' >> sum_avg_intv_cycles 
      echo $avg_intv_dev_cycles | tr -d '\n' >> sum_avg_intv_dev_cycles 
      echo $avg_intv_ret_ic | tr -d '\n' >> sum_avg_intv_ret_ic 
      echo $avg_intv_dev_ret_ic | tr -d '\n' >> sum_avg_intv_dev_ret_ic
      echo -e "Run $j - Duration:$time_in_us us, Intv Cycles: $avg_intv_cycles, Intv Dev Cycles:$avg_intv_dev_cycles, Intv Ret Inst: $avg_intv_ret_ic, Intv Dev Ret Inst: $avg_intv_dev_ret_ic" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        echo -n "+" | tee -a sum_avg_intv_cycles sum_avg_intv_dev_cycles sum_avg_intv_ret_ic sum_avg_intv_dev_ret_ic > /dev/null
      fi

    fi
  done
  echo ")/$DIVISOR_IN_MS" >> sum_duration
  time_in_ms=`cat sum_duration | bc`

  if [ $suffix_conf -eq 2 ]; then

    # For LC
    echo ")/$DIVISOR" | tee -a sum_avg_intv_cycles sum_avg_intv_dev_cycles sum_avg_intv_ic sum_avg_intv_error_ic sum_avg_intv_dev_ic sum_avg_intv_ret_ic sum_avg_intv_dev_ret_ic > /dev/null
    avg_intv_cycles=`cat sum_avg_intv_cycles | bc`
    avg_intv_dev_cycles=`cat sum_avg_intv_dev_cycles | bc`
    avg_intv_ic=`cat sum_avg_intv_ic | bc`
    avg_intv_dev_ic=`cat sum_avg_intv_dev_ic | bc`
    avg_intv_ret_ic=`cat sum_avg_intv_ret_ic | bc`
    avg_intv_dev_ret_ic=`cat sum_avg_intv_dev_ret_ic | bc`

    echo -e "$time_in_ms\t$avg_intv_cycles\t$avg_intv_dev_cycles\t$avg_intv_ret_ic\t$avg_intv_dev_ret_ic\t$avg_intv_ic\t$avg_intv_dev_ic\t" >> $out_file
    echo -e "Average of all runs:-\nDuration:$time_in_ms ms, Intv Cycles: $avg_intv_cycles, Intv Dev Cycles:$avg_intv_dev_cycles,Intv IC:$avg_intv_ic, Intv Dev IC:$avg_intv_dev_ic, Intv Ret Inst: $avg_intv_ret_ic, Intv Dev Ret Inst: $avg_intv_dev_ret_ic" >> $DEBUG_FILE

  elif [ $suffix_conf -eq 1 ]; then

    # For PAPI
    echo ")/$DIVISOR" | tee -a sum_avg_intv_cycles sum_avg_intv_dev_cycles sum_avg_intv_ic sum_avg_intv_error_ic sum_avg_intv_dev_ic sum_avg_intv_ret_ic sum_avg_intv_dev_ret_ic > /dev/null
    avg_intv_cycles=`cat sum_avg_intv_cycles | bc`
    avg_intv_dev_cycles=`cat sum_avg_intv_dev_cycles | bc`
    avg_intv_ret_ic=`cat sum_avg_intv_ret_ic | bc`
    avg_intv_dev_ret_ic=`cat sum_avg_intv_dev_ret_ic | bc`
    echo -e "$time_in_ms\t$avg_intv_cycles\t$avg_intv_dev_cycles\t$avg_intv_ret_ic\t$avg_intv_dev_ret_ic\t" >> $out_file
    echo -e "Average of all runs:-\nDuration:$time_in_ms ms, Intv Cycles: $avg_intv_cycles, Intv Dev Cycles:$avg_intv_dev_cycles, Intv Ret Inst: $avg_intv_ret_ic, Intv Dev Ret Inst: $avg_intv_dev_ret_ic" >> $DEBUG_FILE

  else
    
    # For original program
    echo "$time_in_ms" >> $out_file
    echo -e "Average of all runs:-\nDuration:$time_in_ms ms" >> $DEBUG_FILE

  fi

  rm -f sum_duration sum_avg_intv_cycles sum_avg_intv_dev_cycles sum_avg_intv_ic sum_avg_intv_dev_ic sum_avg_intv_ret_ic sum_avg_intv_dev_ret_ic
}

perf_test() {
  echo "=================================== PERFORMANCE TEST (CLOCK-$CLOCK) ==========================================="
  DEBUG_FILE="$DIR/perf_vs_papi_debug-ad$AD-cl$CLOCK.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_vs_papi_build_error-ad$AD-cl$CLOCK.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_vs_papi_build_log-ad$AD-cl$CLOCK.txt"

  rm -f $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE

  for bench in $*
  do
    thread=1
    ORIG_STAT_FILE="$DIR/$bench-perf_orig-ad$AD-cl$CLOCK.txt"
    LC_STAT_FILE="$DIR/$bench-perf_lc-ad$AD-cl$CLOCK.txt"
    PAPI_STAT_FILE="$DIR/$bench-perf_papi-ad$AD-cl$CLOCK.txt"
    echo "************* $bench ***************" | tee -a $DEBUG_FILE 
    echo "Runtime"> $ORIG_STAT_FILE
    echo -e "TI\tRuntime\tAvg_TSC\tDev_TSC\tAvg_Ret_IC\tDev_Ret_IC\tAvg_LC_IC\tDev_LC_IC" > $LC_STAT_FILE
    echo -e "TI\tRuntime\tAvg_TSC\tDev_TSC\tAvg_Ret_IC\tDev_Ret_IC" > $PAPI_STAT_FILE

    #run original 
    echo -e "\n\nBuilding original program: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench 
    get_stats $bench $ORIG_STAT_FILE 0

    #run naive
    echo "Building lc program: " >> $DEBUG_FILE
    for pi in $PI
    do
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE EXTRA_FLAGS="-DINTV_STATS" ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$pi CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench 
      echo "Running lc program with PI $pi: " >> $DEBUG_FILE
      echo -ne "$pi\t" >> $LC_STAT_FILE
      get_stats $bench $LC_STAT_FILE 2
    done

    #run opt
    echo "Building orig program with PAPI: " >> $DEBUG_FILE
    for pi in $PI
    do
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE EXTRA_FLAGS="-DINTV_STATS -DPAPI -DIC_THRESHOLD=$pi" make -f Makefile.orig $bench
      echo "Building orig program with PAPI with PI $pi: " >> $DEBUG_FILE
      echo -ne "$pi\t" >> $PAPI_STAT_FILE
      get_stats $bench $PAPI_STAT_FILE 1
    done
  done
}

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
    CLOCK=1; perf_test water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
#CLOCK=0; perf_test water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
  else
    CLOCK=1; perf_test $@
#CLOCK=0; perf_test $@
  fi
}

echo "Note: Script has performance tests for both instantaneous & predictive clocks."
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: $THREADS, PINNED?: always pinned, Output Directory: $DIR"
mkdir -p $DIR;

if [ $# -eq 0 ]; then
  run_perf_test
else
  run_perf_test $@
fi

rm -f out sum
