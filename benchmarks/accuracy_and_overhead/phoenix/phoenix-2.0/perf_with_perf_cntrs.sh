#!/bin/bash
CI=1000
PI="${PI:-"2000 5000 10000 15000 20000 50000 75000 100000 150000 300000 500000 750000 1000000"}"
RUNS="${RUNS:-5}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
DIR=$CUR_PATH/phoenix_stats/$SUB_DIR
CLOCK=1

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
  threads=1
  program=$1

  DIVISOR=`expr $RUNS \* 1000`
  rm -f sum
  dry_run $program

  echo -n "scale=2;(" > sum
  net_avg_ic="scale=2;("
  net_avg_tsc="scale=2;("
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
    cat out | grep "avg_intv_cycles:" > tmp

    # remove lines with avg_intv_cycles=0

    if [ -s "tmp" ]; then
      tsc=`awk -F'[,:]' '{sum1 += ($2 * $4); sum2 += $2} END { if (sum2 > 0) print sum1 / sum2; }' tmp`
    fi
    
    if [ -s "tmp" ]; then
      ic=`awk -F'[,:]' '{sum1 += ($2 * $6); sum2 += $2} END { if (sum2 > 0) print sum1 / sum2; }' tmp`
    fi

    if [ ! -z "$time_in_us" ]; then
      echo $time_in_us | tr -d '\n' >> sum
      echo "$time_in_us us" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        echo -n "+" >> sum
      fi
    fi

    if [ ! -z "$ic" ]; then
      net_avg_ic=$net_avg_ic"$ic"
      echo "$ic IR instructions" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        net_avg_ic=$net_avg_ic"+"
      fi
    fi

    if [ ! -z "$tsc" ]; then
      net_avg_tsc=$net_avg_tsc"$tsc"
      echo "$tsc cycles" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        net_avg_tsc=$net_avg_tsc"+"
      fi
    fi
  done

  echo ")/$DIVISOR" >> sum
  time_in_ms=`cat sum | bc`

  if [ ! -z "$time_in_us" ]; then
    echo -n "$time_in_ms"
    echo "Average duration: $time_in_ms ms" >> $DEBUG_FILE
  else
    echo "Average duration: $time_in_ms ms" >> $DEBUG_FILE
    echo "$time_in_ms"
  fi

  if [ ! -z "$tsc" ]; then
    net_avg_tsc=`echo "$net_avg_tsc)/$RUNS" | bc`
    echo -n ",$net_avg_tsc"
    echo "Average cycles: $net_avg_tsc" >> $DEBUG_FILE
  fi

  if [ ! -z "$ic" ]; then
    net_avg_ic=`echo "$net_avg_ic)/$RUNS" | bc`
    echo ",$net_avg_ic"
    echo "Average instruction count: $net_avg_ic" >> $DEBUG_FILE
  fi
}

perf_test() {
  echo "=================================== PERFORMANCE TEST ==========================================="
  LOG_FILE="$DIR/perf_logs-ad$AD.txt"
  DEBUG_FILE="$DIR/perf_debug-ad$AD.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error-ad$AD.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log-ad$AD.txt"
  #FIBER_CONFIG is set in the Makefile. Unless needed, do not pass a new config from this script

  rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE

  for bench in $*
  do
    PER_BENCH_ORIG_STAT_FILE="$DIR/$bench-perf_orig-ad$AD-cl$CLOCK.txt"
    PER_BENCH_LC_STAT_FILE="$DIR/$bench-perf_lc-ad$AD-cl$CLOCK.txt"
    PER_BENCH_PAPI_STAT_FILE="$DIR/$bench-perf_papi-ad$AD-cl$CLOCK.txt"
    echo "Runtime" > $PER_BENCH_ORIG_STAT_FILE
    echo -e "TI\tRuntime\tTSC" > $PER_BENCH_PAPI_STAT_FILE
    echo -e "TI\tRuntime\tTSC\tIC" > $PER_BENCH_LC_STAT_FILE
    echo -e "Interval(IR)\tOrig_Runtime\tCI_Runtime\tHI_Runtime\tCI_TSC\tCI_IC\tHI_TSC" > $LOG_FILE
  done

  #1. Build & run original 
  echo "Building original program: " >> $DEBUG_FILE
  make -f Makefile.orig clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  make -f Makefile.orig >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  echo "Running original program: " >> $DEBUG_FILE
  for bench in $*
  do
    PER_BENCH_ORIG_STAT_FILE="$DIR/$bench-perf_orig-ad$AD-cl$CLOCK.txt"
    orig_time=$(get_time $bench)
    echo "$orig_time" >> $PER_BENCH_ORIG_STAT_FILE
    echo "Benchmark $bench:- orig runtime: $orig_time" | tee -a $DEBUG_FILE
  done

  for pi in $PI
  do
    #2. Build original program with Periodic CI
    echo "Building original program with Periodic CI (PI: $pi IR instructions): " >> $DEBUG_FILE
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$pi CMMT_INTV=$CI INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DPERF_CNTR" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    for bench in $*
    do
      PER_BENCH_LC_STAT_FILE="$DIR/$bench-perf_lc-ad$AD-cl$CLOCK.txt"
      lc_stats=$(get_time $bench)
      lc_periodic_time=`echo "$lc_stats" | cut -d ',' -f 1`
      lc_avg_tsc=`echo "$lc_stats" | cut -d ',' -f 2`
      lc_avg_ic=`echo "$lc_stats" | cut -d ',' -f 3`

      echo -ne "Benchmark $bench:- " | tee -a $DEBUG_FILE
      echo -ne "$pi" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE

      if [ ! -z "$lc_periodic_time" ]; then
        echo -ne "\t$lc_periodic_time" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE
      else
        echo -ne "\t?" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE
      fi

      if [ ! -z "$lc_avg_tsc" ]; then
        echo -ne "\t$lc_avg_tsc" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE
      else
        echo -ne "\t?" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE
      fi

      if [ ! -z "$lc_avg_ic" ]; then
        echo -e "\t$lc_avg_ic" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE
      else
        echo -e "\t?" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE
      fi
    done

    #3. Build original program with PAPI hardware interrupts
    echo "Building original program with PAPI hardware interrupts(PI: $pi retired instructions) : " >> $DEBUG_FILE
    make -f Makefile.orig clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    EXTRA_FLAGS="-DPAPI -DIC_THRESHOLD=$pi"  make -f Makefile.orig >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    for bench in $*
    do
      PER_BENCH_PAPI_STAT_FILE="$DIR/$bench-perf_papi-ad$AD-cl$CLOCK.txt"
      papi_stats=$(get_time $bench)
      papi_periodic_time=`echo "$papi_stats" | cut -d ',' -f 1`
      papi_avg_tsc=`echo "$papi_stats" | cut -d ',' -f 2`

      echo -ne "Benchmark $bench:- " | tee -a $DEBUG_FILE
      echo -ne "$pi" | tee -a $PER_BENCH_PAPI_STAT_FILE $DEBUG_FILE
      if [ ! -z "$papi_periodic_time" ]; then
        echo -ne "\t$papi_periodic_time" | tee -a $PER_BENCH_PAPI_STAT_FILE $DEBUG_FILE
      else
        echo -ne "\t?" | tee -a $PER_BENCH_PAPI_STAT_FILE $DEBUG_FILE
      fi

      if [ ! -z "$papi_avg_tsc" ]; then
        echo -e "\t$papi_avg_tsc" | tee -a $PER_BENCH_PAPI_STAT_FILE $DEBUG_FILE
      else
        echo -e "\t?" | tee -a $PER_BENCH_PAPI_STAT_FILE $DEBUG_FILE
      fi
    done
  done
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
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Output Directory: $DIR"
echo "WARNING: Remove Passed Config if you don't need it!"
mkdir -p $DIR;

if [ $# -eq 0 ]; then
  run_perf_test
else
  run_perf_test $@
fi

rm -f out sum
