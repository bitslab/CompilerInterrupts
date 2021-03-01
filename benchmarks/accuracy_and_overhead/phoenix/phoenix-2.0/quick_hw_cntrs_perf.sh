#!/bin/bash
CI=1000
#PI="${PI:-"2000 5000 10000 15000 20000 50000 75000 100000 150000 300000 500000 750000 1000000"}"
PI="${PI:-"5000"}"
RUNS="${RUNS:-2}"
THREAD="${THREAD:-1}"
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
WRITE_DIR=/local_home/nilanjana/temp/$SUB_DIR
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

emit_interval_stats() {
  threads=$THREAD
  program=$1
  OUT_FILE="$WRITE_DIR/tmp"
  OUT_DIR="/local_home/nilanjana/temp/interval_stats/"
  OUT_STAT_FILE="$WRITE_DIR/${file_prefix}_$1_lc_ic_vs_tsc"
  rm -f $OUT_DIR/*
  rm -f $OUT_FILE
  dry_run $program

  case "$program" in
    histogram)
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp > $OUT_FILE 2>&1"
    ;;
    kmeans)
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program -d 100 -c 10 -p 500000 -s 50 > $OUT_FILE 2>&1"
    ;;
    pca) 
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program -r 1000 -c 1000 -s 1000 > $OUT_FILE 2>&1"
    ;;
    matrix_multiply) 
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program 900 600 1 > $OUT_FILE 2>&1"
    ;;
    string_match)
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_100MB.txt > $OUT_FILE 2>&1"
    ;;
    linear_regression)
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_500MB.txt > $OUT_FILE 2>&1"
    ;;
    word_count)
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/word_50MB.txt > $OUT_FILE 2>&1"
    ;;
    reverse_index)
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/www.stanford.edu/dept/news/ > $OUT_FILE 2>&1"
    ;;
  esac
  echo $command >> $DEBUG_FILE
  eval $command

  cd $OUT_DIR
  for file in interval_stats_thread*.txt
  do
    thr_no=`echo $file | grep -o '[0-9]\+'`
    new_name=$OUT_STAT_FILE"_thread"$thr_no".txt"
    mv $file $new_name
    echo "Generated $new_name"
  done
  ls
  cd -
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_time() {
  rm -f out
  threads=$THREAD
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
    if [ ! -f "$OUT_FILE" ]; then
      echo "$1 run failed. No output file generated." >> $DEBUG_FILE
    else
      cat $OUT_FILE >> $LOG_FILE
    fi

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
  echo "=================================== PERFORMANCE TEST for $THREAD thread(s) ==========================================="

  thread=$THREAD

  LOG_FILE="$DIR/perf_logs.txt"
  DEBUG_FILE="$DIR/perf_debug.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log.txt"
  PER_PI_PERF_STAT_FILE="$DIR/papi-perf-tuned-th$thread"
  PER_PI_ACC_STAT_FILE="$DIR/papi-intv-tuned-th$thread"
  echo "hw-int-tuned" > $PER_PI_PERF_STAT_FILE
  echo -e "Benchmark\tTSC" > $PER_PI_ACC_STAT_FILE
  echo -e "Interval(IR)\tHI_Runtime\tHI_TSC" > $LOG_FILE

  #FIBER_CONFIG is set in the Makefile. Unless needed, do not pass a new config from this script

  rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE

  echo "Building original program with PAPI hardware interrupts(PI: $PI retired instructions) : " >> $DEBUG_FILE
  make -f Makefile.orig clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  EXTRA_FLAGS="-DPAPI -DIC_THRESHOLD=$PI"  make -f Makefile.orig >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  for bench in $*
  do
    echo "********************** $bench ********************" | tee -a $LOG_FILE
    papi_stats=$(get_time $bench)
    papi_periodic_time=`echo "$papi_stats" | cut -d ',' -f 1`
    papi_avg_tsc=`echo "$papi_stats" | cut -d ',' -f 2`

    echo -ne "$bench" | tee -a $PER_PI_PERF_STAT_FILE $PER_PI_ACC_STAT_FILE $DEBUG_FILE
    if [ ! -z "$papi_periodic_time" ]; then
      echo -ne "\t$papi_periodic_time" | tee -a $PER_PI_PERF_STAT_FILE $DEBUG_FILE
    else
      echo -ne "\t?" | tee -a $PER_PI_PERF_STAT_FILE $DEBUG_FILE
    fi

    if [ ! -z "$papi_avg_tsc" ]; then
      echo -ne "\t$papi_avg_tsc" | tee -a $PER_PI_ACC_STAT_FILE $DEBUG_FILE
    else
      echo -ne "\t?" | tee -a $PER_PI_ACC_STAT_FILE $DEBUG_FILE
    fi

    echo "" | tee -a $PER_PI_PERF_STAT_FILE $PER_PI_ACC_STAT_FILE $DEBUG_FILE $LOG_FILE 
  done
}

interval_test() {
  echo "=================================== ACCURACY TEST for $THREAD thread(s) ==========================================="

  thread=$THREAD

  LOG_FILE="$DIR/perf_logs.txt"
  DEBUG_FILE="$DIR/perf_debug.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log.txt"

  rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE

  make -f Makefile.orig clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  EXTRA_FLAGS="-DPAPI -DIC_THRESHOLD=$PI -DINTV_SAMPLING"  make -f Makefile.orig >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ci_type="hw-int"
  for bench in $*
  do
    echo "********************** $bench ********************" | tee -a $LOG_FILE
    file_prefix="${ci_type}-tuned-th$thread"
    emit_interval_stats $bench
  done
}

run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
  else
    perf_test $@
  fi
}

run_intv_acc_test() {
  mkdir -p $WRITE_DIR;
  if [ $# -eq 0 ]; then
    interval_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
  else
    interval_test $@
  fi
}

echo "Note: Script has performance tests for both instantaneous & predictive clocks."
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Output Directory: $DIR"
echo "WARNING: Remove Passed Config if you don't need it!"
mkdir -p $DIR;

if [ $# -eq 0 ]; then
#run_perf_test
  run_intv_acc_test
else
#run_perf_test $@
  run_intv_acc_test $@
fi

rm -f out sum
