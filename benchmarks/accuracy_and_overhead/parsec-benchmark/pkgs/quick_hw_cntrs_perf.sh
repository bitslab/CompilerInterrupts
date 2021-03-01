#!/bin/bash
CI=1000
#PI="${PI:-"2000 5000 10000 15000 20000 50000 75000 100000 150000 300000 500000 750000 1000000"}"
PI="${PI:-"5000"}"
RUNS="${RUNS:-1}"
THREAD="${THREAD:-1}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
WRITE_DIR=/local_home/nilanjana/temp/$SUB_DIR
DIR=$CUR_PATH/parsec_stats/$SUB_DIR
CLOCK=1 #0 - predictive, 1 - instantaneous

LOG_FILE="$DIR/perf_logs.txt"
DEBUG_FILE="$DIR/perf_debug.txt"
BUILD_ERROR_FILE="$DIR/perf_test_build_error.txt"
BUILD_DEBUG_FILE="$DIR/perf_test_build_log.txt"

dry_run() {
  case "$1" in
    blackscholes)
      cd blackscholes/src > /dev/null
      $prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > /dev/null 2>&1
      echo "$prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    fluidanimate)
      cd fluidanimate/src > /dev/null
      $prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > /dev/null 2>&1
      echo "$prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    swaptions)
      cd swaptions/src > /dev/null
      $prefix ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > /dev/null 2>&1
      echo "$prefix ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    canneal)
      cd canneal/src > /dev/null
      $prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > /dev/null 2>&1
      echo "$prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    dedup)
      cd dedup/src > /dev/null
      $prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > /dev/null 2>&1
      echo "$prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    streamcluster)
      cd streamcluster/src > /dev/null
      $prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > /dev/null 2>&1 
      echo "$prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
  esac
  cd - > /dev/null
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
emit_interval_stats() {
  threads=$THREAD
  suffix="_llvm"
#prefix="timeout 5m taskset 0x00000001 "
  prefix="timeout 5m "
  OUT_DIR="/local_home/nilanjana/temp/interval_stats/"
  OUT_FILE="$WRITE_DIR/tmp"
  OUT_STAT_FILE="$WRITE_DIR/${file_prefix}_$1_lc_ic_vs_tsc"
  rm -f $OUT_DIR/*
  rm -f $OUT_FILE
  dry_run $1

  case "$1" in
    blackscholes)
      cd blackscholes/src > /dev/null
      $prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE
      sleep 0.5
      echo "$prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    fluidanimate)
      cd fluidanimate/src > /dev/null
      $prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE
      sleep 0.5
      echo "$prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    swaptions)
      cd swaptions/src > /dev/null
      $prefix ./swaptions$suffix -ns 32 -sm 100000 -nt $threads > $OUT_FILE
      sleep 0.5
      echo "$prefix ./swaptions$suffix -ns 32 -sm 100000 -nt $threads > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    canneal)
      cd canneal/src > /dev/null
      $prefix ./canneal$suffix $threads 15000 2000 ../inputs/400000.nets 128 > $OUT_FILE
      sleep 0.5
      echo "$prefix ./canneal$suffix $threads 15000 2000 ../inputs/400000.nets 128 > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    dedup)
      cd dedup/src > /dev/null
      $prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE
      sleep 0.5
      echo "$prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    streamcluster)
      cd streamcluster/src > /dev/null
      $prefix ./streamcluster$suffix 10 20 64 8192 8192 1000 none output.txt $threads > $OUT_FILE
      sleep 0.5
      echo "$prefix ./streamcluster$suffix 10 20 64 8192 8192 1000 none output.txt $threads > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
  esac

  cd $OUT_DIR
  ls
  for file in interval_stats_thread*.txt
  do
    thr_no=`echo $file | grep -o '[0-9]\+'`
    new_name=$OUT_STAT_FILE"_thread"$thr_no".txt"
    mv $file $new_name
    echo "Generated $new_name"
  done
  cd -
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_time() {
  threads=$THREAD
  suffix_conf=$2
  declare suffix
  if [ $suffix_conf -eq 0 ]; then
    suffix="_llvm"
  else
    suffix="_ci"
  fi
  if [ $3 -eq 1 ]; then
    prefix="timeout 5m taskset 0x00000001 "
  else
    prefix="timeout 5m "
  fi
  OUT_FILE="$DIR/out"
  SUM_FILE="$DIR/sum"
  TMP_FILE="$DIR/tmp"
  INTV_STAT_FILE="$DIR/interval_stats"
  rm -f $OUT_FILE $SUM_FILE $INTV_STAT_FILE
  dry_run $1

  DIVISOR=`expr $RUNS \* 1000`
  echo -n "scale=2;(" > $SUM_FILE
  net_avg_ic="scale=2;("
  net_avg_tsc="scale=2;("
  for j in `seq 1 $RUNS`
  do
    case "$1" in
      blackscholes)
        cd blackscholes/src > /dev/null
        $prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE
        sleep 0.5
        echo "$prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      fluidanimate)
        cd fluidanimate/src > /dev/null
        $prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE
        sleep 0.5
        echo "$prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      swaptions)
        cd swaptions/src > /dev/null
        $prefix ./swaptions$suffix -ns 32 -sm 100000 -nt $threads > $OUT_FILE
        sleep 0.5
        echo "$prefix ./swaptions$suffix -ns 32 -sm 100000 -nt $threads > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      canneal)
        cd canneal/src > /dev/null
        $prefix ./canneal$suffix $threads 15000 2000 ../inputs/400000.nets 128 > $OUT_FILE
        sleep 0.5
        echo "$prefix ./canneal$suffix $threads 15000 2000 ../inputs/400000.nets 128 > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      dedup)
        cd dedup/src > /dev/null
        $prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE
        sleep 0.5
        echo "$prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      streamcluster)
        cd streamcluster/src > /dev/null
        $prefix ./streamcluster$suffix 10 20 64 8192 8192 1000 none output.txt $threads > $OUT_FILE
        sleep 0.5
        echo "$prefix ./streamcluster$suffix 10 20 64 8192 8192 1000 none output.txt $threads > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
    esac
    if [ ! -f "$OUT_FILE" ]; then
      echo "$1 run failed. No output file generated." >> $DEBUG_FILE
    fi

    time_in_us=`cat $OUT_FILE | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    cat $OUT_FILE | grep "avg_intv_cycles:" > $TMP_FILE

    if [ -s "$TMP_FILE" ]; then
      tsc=`awk -F'[,:]' '{sum1 += ($2 * $4); sum2 += $2} END { if (sum2 > 0) print sum1 / sum2; }' $TMP_FILE`
    fi
    
    if [ -s "$TMP_FILE" ]; then
      ic=`awk -F'[,:]' '{sum1 += ($2 * $6); sum2 += $2} END { if (sum2 > 0) print sum1 / sum2; }' $TMP_FILE`
    fi

    cat $OUT_FILE >> $LOG_FILE
    if [ ! -z "$time_in_us" ]; then
      echo $time_in_us | tr -d '\n' >> $SUM_FILE
      echo "$time_in_us us" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        echo -n "+" >> $SUM_FILE
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

  echo ")/$DIVISOR" >> $SUM_FILE
  
  #echo "######### start sum content ###########"
  #cat sum
  #echo "######### end sum content ###########"
  
  time_in_ms=`cat $SUM_FILE | bc`

  if [ ! -z "$time_in_us" ]; then
    echo -n "$time_in_ms"
    echo "Average duration: $time_in_ms ms" >> $DEBUG_FILE
  else
    echo "Average: $time_in_ms ms" >> $DEBUG_FILE
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
  thread=$THREAD
  echo "=================================== PERFORMANCE TEST for $THREAD threads ==========================================="

  PER_PI_PERF_STAT_FILE="$DIR/papi-perf-tuned-th$thread"
  PER_PI_ACC_STAT_FILE="$DIR/papi-intv-tuned-th$thread"
  echo "hw-int-tuned" > $PER_PI_PERF_STAT_FILE
  echo -e "Benchmark\tTSC" > $PER_PI_ACC_STAT_FILE
  echo -e "Interval(IR)\tHI_Runtime\tHI_TSC" > $LOG_FILE

  for bench in $*
  do
    BENCH_DIR=""
    case "$bench" in
    "canneal" | "dedup" | "streamcluster")
      BENCH_DIR="kernels"
      ;;
    *)
      BENCH_DIR="apps"
      ;;
    esac

    cd $BENCH_DIR

    echo "********************** $bench ********************" | tee -a $LOG_FILE > /dev/null
    echo "Building original program with PAPI hardware interrupts: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.llvm ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE PAPI_FLAGS="-lpapi -DCI_PASS -DPAPI -DIC_THRESHOLD=$PI" make -f Makefile.llvm ${bench} 
    papi_stats=$(get_time $bench 0 0) #no taskset
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

    cd ../ > /dev/null
  done
}

interval_test() {
  thread=$THREAD
  echo "=================================== INTERVAL TEST for $THREAD threads ==========================================="

  for bench in $*
  do
    BENCH_DIR=""
    case "$bench" in
    "canneal" | "dedup" | "streamcluster")
      BENCH_DIR="kernels"
      ;;
    *)
      BENCH_DIR="apps"
      ;;
    esac

    cd $BENCH_DIR

    ci_type="hw-int"
    echo "********************** $bench ********************" | tee -a $LOG_FILE > /dev/null
    echo "Building original program with PAPI hardware interrupts: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.llvm ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE PAPI_FLAGS="-lpapi -DINTV_SAMPLING -DCI_PASS -DPAPI -DIC_THRESHOLD=$PI" make -f Makefile.llvm ${bench} 
    file_prefix="${ci_type}-tuned-th$THREAD"
    emit_interval_stats $bench

    cd ../ > /dev/null
  done
}

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test blackscholes fluidanimate swaptions canneal streamcluster dedup
  else
    perf_test $@
  fi
}

#1 - benchmark name (optional)
run_intv_acc_test() {
  mkdir -p $WRITE_DIR
  if [ $# -eq 0 ]; then
    interval_test blackscholes fluidanimate swaptions canneal streamcluster dedup
  else
    interval_test $@
  fi
}

rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
#echo "Note: Script has both accuracy tests & performance tests. Change the mode in the next few lines if any one of them is required only. "
#echo "Note: Number of threads for running performance tests need to be configured inside the file"
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: 1"
echo "Usage: ./perf_test_libfiber <nothing / space separated list of splash2 benchmarks>"
mkdir -p $DIR
if [ $# -eq 0 ]; then
  run_perf_test
  #run_intv_acc_test
else
  run_perf_test $@
  #run_intv_acc_test $@
fi

rm -f $OUT_FILE $SUM_FILE
