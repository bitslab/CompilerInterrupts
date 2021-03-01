#!/bin/bash
CI=1000
#PI="${PI:-"2000 5000 10000 15000 20000 50000 75000 100000 150000 300000 500000 750000 1000000"}"
PI="${PI:-"5000"}"
RUNS="${RUNS:-1}"
THREAD="${THREAD:-1}"
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
DIR=$CUR_PATH/splash2_stats/$SUB_DIR
WRITE_DIR=/local_home/nilanjana/temp/$SUB_DIR
CLOCK=1 #0 - predictive, 1 - instantaneous

LOG_FILE="$DIR/perf_logs.txt"
DEBUG_FILE="$DIR/perf_debug.txt"
BUILD_ERROR_FILE="$DIR/perf_test_build_error.txt"
BUILD_DEBUG_FILE="$DIR/perf_test_build_log.txt"

dry_run() {
  case "$1" in
    water-nsquared)
      cd water-nsquared > /dev/null
      command="$prefix ./water-nsquared-$suffix < input.1 > /dev/null 2>&1"
    ;;
    water-spatial)
      cd water-spatial > /dev/null
      command="$prefix ./water-spatial-$suffix < input.1 > /dev/null 2>&1"
    ;;
    ocean-cp) 
      cd ocean/contiguous_partitions > /dev/null
      command="$prefix ./ocean-cp-$suffix -n1026 -p 1 -e1e-07 -r2000 -t28800 > /dev/null 2>&1"
    ;;
    ocean-ncp) 
      cd ocean/non_contiguous_partitions > /dev/null
      command="$prefix ./ocean-ncp-$suffix -n258 -p 1 -e1e-07 -r2000 -t28800 > /dev/null 2>&1"
    ;;
    barnes)
      cd barnes > /dev/null
      command="$prefix ./barnes-$suffix < input.1 > /dev/null 2>&1"
    ;;
    volrend)
      cd volrend > /dev/null
      command="$prefix ./volrend-$suffix 1 inputs/head > /dev/null 2>&1"
    ;;
    fmm)
      cd fmm > /dev/null
      command="$prefix ./fmm-$suffix < inputs/input.65535.1 > /dev/null 2>&1"
    ;;
    raytrace)
      cd raytrace > /dev/null
      command="$prefix ./raytrace-$suffix -p 1 -m72 inputs/balls4.env > /dev/null 2>&1"
    ;;
    radiosity)
      cd radiosity > /dev/null
      command="$prefix ./radiosity-$suffix -p 1 -batch -largeroom > /dev/null 2>&1"
    ;;
    radix)
      cd radix > /dev/null
      command="$prefix ./radix-$suffix -p1 -n134217728 -r1024 -m524288 > /dev/null 2>&1"
    ;;
    fft)
      cd fft > /dev/null
      command="$prefix ./fft-$suffix -m24 -p1 -n1048576 -l4 > /dev/null 2>&1"
    ;;
    lu-c)
      cd lu/contiguous_blocks > /dev/null
      command="$prefix ./lu-c-$suffix -n4096 -p1 -b16 > /dev/null 2>&1"
    ;;
    lu-nc)
      cd lu/non_contiguous_blocks > /dev/null
      command="$prefix ./lu-nc-$suffix -n2048 -p1 -b16 > /dev/null 2>&1"
    ;;
    cholesky)
      cd cholesky > /dev/null
      command="$prefix ./cholesky-$suffix -p1 -B32 -C1024 inputs/tk29.O > /dev/null 2>&1"
    ;;
  esac
  echo $command >> $DEBUG_FILE
  eval $command
  cd - > /dev/null
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_time() {
  threads=$THREAD
  suffix_conf=$2
  declare suffix
  if [ $suffix_conf -eq 0 ]; then
    suffix="orig"
  else
    suffix="lc"
  fi
  if [ $3 -eq 1 ]; then
    prefix="timeout 5m taskset 0x00000001 "
  else
    prefix="timeout 5m "
  fi
  OUT_FILE="$DIR/out"
  SUM_FILE="$DIR/sum"
  TMP_FILE="$DIR/tmp"
  rm -f $OUT_FILE $SUM_FILE
  dry_run $1

  DIVISOR=`expr $RUNS \* 1000`
  echo -n "scale=2;(" > $SUM_FILE
  net_avg_ic="scale=2;("
  net_avg_tsc="scale=2;("
  for j in `seq 1 $RUNS`
  do
    case "$1" in
      water-nsquared)
        cd water-nsquared > /dev/null
        command="$prefix ./water-nsquared-$suffix < input.$threads > $OUT_FILE"
        sleep 0.5
      ;;
      water-spatial)
        cd water-spatial > /dev/null
        command="$prefix ./water-spatial-$suffix < input.$threads > $OUT_FILE"
        sleep 0.5
      ;;
      ocean-cp) 
        cd ocean/contiguous_partitions > /dev/null
        command="$prefix ./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > $OUT_FILE"
      ;;
      ocean-ncp) 
        cd ocean/non_contiguous_partitions > /dev/null
        command="$prefix ./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > $OUT_FILE"
      ;;
      barnes)
        cd barnes > /dev/null
        command="$prefix ./barnes-$suffix < input.$threads > $OUT_FILE"
      ;;
      volrend)
        cd volrend > /dev/null
        command="$prefix ./volrend-$suffix $threads inputs/head > $OUT_FILE"
      ;;
      fmm)
        cd fmm > /dev/null
        command="$prefix ./fmm-$suffix < inputs/input.65535.$threads > $OUT_FILE"
      ;;
      raytrace)
        cd raytrace > /dev/null
        command="$prefix ./raytrace-$suffix -p $threads -m72 inputs/balls4.env > $OUT_FILE"
      ;;
      radiosity)
        cd radiosity > /dev/null
        command="$prefix ./radiosity-$suffix -p $threads -batch -largeroom > $OUT_FILE"
      ;;
      radix)
        cd radix > /dev/null
        command="$prefix ./radix-$suffix -p$threads -n134217728 -r1024 -m524288 > $OUT_FILE"
      ;;
      fft)
        cd fft > /dev/null
        command="$prefix ./fft-$suffix -m24 -p$threads -n1048576 -l4 > $OUT_FILE"
      ;;
      lu-c)
        cd lu/contiguous_blocks > /dev/null
        command="$prefix ./lu-c-$suffix -n4096 -p$threads -b16 > $OUT_FILE"
      ;;
      lu-nc)
        cd lu/non_contiguous_blocks > /dev/null
        command="$prefix ./lu-nc-$suffix -n2048 -p$threads -b16 > $OUT_FILE"
      ;;
      cholesky)
        cd cholesky > /dev/null
        command="$prefix ./cholesky-$suffix -p$threads -B32 -C1024 inputs/tk29.O > $OUT_FILE"
      ;;
    esac
    echo $command >> $DEBUG_FILE
    eval $command
    cd - > /dev/null
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

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
emit_interval_stats() {
  threads=$THREAD
  suffix="orig"
#prefix="timeout 5m taskset 0x00000001 "
  prefix="timeout 5m "
  OUT_DIR="/local_home/nilanjana/temp/interval_stats/"
  OUT_FILE="$WRITE_DIR/tmp"
  OUT_STAT_FILE="$WRITE_DIR/${file_prefix}_$1_lc_ic_vs_tsc"
  rm -f $OUT_DIR/*
  rm -f $OUT_FILE
  dry_run $1

  echo "Exporting $1 interval statistics to $OUT_FILE"

  case "$1" in
    water-nsquared)
      cd water-nsquared > /dev/null
      command="$prefix ./water-nsquared-$suffix < input.$threads > $OUT_FILE"
    ;;
    water-spatial)
      cd water-spatial > /dev/null
      command="$prefix ./water-spatial-$suffix < input.$threads > $OUT_FILE"
    ;;
    ocean-cp) 
      cd ocean/contiguous_partitions > /dev/null
      command="$prefix ./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > $OUT_FILE"
    ;;
    ocean-ncp) 
      cd ocean/non_contiguous_partitions > /dev/null
      command="$prefix ./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > $OUT_FILE"
    ;;
    barnes)
      cd barnes > /dev/null
      command="$prefix ./barnes-$suffix < input.$threads > $OUT_FILE"
    ;;
    volrend)
      cd volrend > /dev/null
      command="$prefix ./volrend-$suffix $threads inputs/head > $OUT_FILE"
    ;;
    fmm)
      cd fmm > /dev/null
      command="$prefix ./fmm-$suffix < inputs/input.65535.$threads > $OUT_FILE"
    ;;
    raytrace)
      cd raytrace > /dev/null
      command="$prefix ./raytrace-$suffix -p $threads -m72 inputs/balls4.env > $OUT_FILE"
    ;;
    radiosity)
      cd radiosity > /dev/null
      command="$prefix ./radiosity-$suffix -p $threads -batch -largeroom > $OUT_FILE"
    ;;
    radix)
      cd radix > /dev/null
      command="$prefix ./radix-$suffix -p$threads -n134217728 -r1024 -m524288 > $OUT_FILE"
    ;;
    fft)
      cd fft > /dev/null
      command="$prefix ./fft-$suffix -m24 -p$threads -n1048576 -l4 > $OUT_FILE"
    ;;
    lu-c)
      cd lu/contiguous_blocks > /dev/null
      command="$prefix ./lu-c-$suffix -n4096 -p$threads -b16 > $OUT_FILE"
    ;;
    lu-nc)
      cd lu/non_contiguous_blocks > /dev/null
      command="$prefix ./lu-nc-$suffix -n2048 -p$threads -b16 > $OUT_FILE"
    ;;
    cholesky)
      cd cholesky > /dev/null
      command="$prefix ./cholesky-$suffix -p$threads -B32 -C1024 inputs/tk29.O > $OUT_FILE"
    ;;
  esac
  echo $command >> $DEBUG_FILE
  eval $command
  cd - > /dev/null

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

perf_test() {
  echo "=================================== PERFORMANCE TEST ==========================================="

  thread=$THREAD

  PER_PI_PERF_STAT_FILE="$DIR/papi-perf-tuned-th$thread"
  PER_PI_ACC_STAT_FILE="$DIR/papi-intv-tuned-th$thread"
  echo "hw-int-tuned" > $PER_PI_PERF_STAT_FILE
  echo -e "Benchmark\tTSC" > $PER_PI_ACC_STAT_FILE
  echo -e "Interval(IR)\tHI_Runtime\tHI_TSC" > $LOG_FILE

  for bench in $*
  do
    BENCH_DIR=""
    case "$bench" in
    "radix" | "fft" | "lu-c" | "lu-nc" | "cholesky")
      BENCH_DIR="kernels"
      ;;
    *)
      BENCH_DIR="apps"
      ;;
    esac

    cd $BENCH_DIR

    echo "********************** $bench ********************" | tee -a $LOG_FILE
    echo "Building original program with PAPI hardware interrupts: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE EXTRA_FLAGS="-DPAPI -DIC_THRESHOLD=$PI" make -f Makefile.orig $bench 
    papi_stats=$(get_time $bench 0 0)
    papi_periodic_time=`echo "$papi_stats" | cut -d ',' -f 1`
    papi_avg_tsc=`echo "$papi_stats" | cut -d ',' -f 2`

    echo -ne "$bench" | tee -a $PER_PI_PERF_STAT_FILE $PER_PI_ACC_STAT_FILE $DEBUG_FILE $LOG_FILE 

    if [ ! -z "$papi_periodic_time" ]; then
      echo -ne "\t$papi_periodic_time" | tee -a $PER_PI_PERF_STAT_FILE $DEBUG_FILE $LOG_FILE 
    else
      echo -ne "\t?" | tee -a $PER_PI_PERF_STAT_FILE $DEBUG_FILE $LOG_FILE 
    fi

    if [ ! -z "$papi_avg_tsc" ]; then
      echo -ne "\t$papi_avg_tsc" | tee -a $PER_PI_ACC_STAT_FILE $DEBUG_FILE $LOG_FILE 
    else
      echo -ne "\t?" | tee -a $PER_PI_ACC_STAT_FILE $DEBUG_FILE $LOG_FILE 
    fi

    echo "" | tee -a $PER_PI_PERF_STAT_FILE $PER_PI_ACC_STAT_FILE $DEBUG_FILE $LOG_FILE 

    cd ../ > /dev/null
  done
}

interval_test() {
  echo "=================================== ACCURACY TEST ==========================================="

  thread=$THREAD

  for bench in $*
  do
    BENCH_DIR=""
    case "$bench" in
    "radix" | "fft" | "lu-c" | "lu-nc" | "cholesky")
      BENCH_DIR="kernels"
      ;;
    *)
      BENCH_DIR="apps"
      ;;
    esac

    cd $BENCH_DIR

    echo "********************** $bench ********************" | tee -a $LOG_FILE
    ci_type="hw-int"
    echo "Building original program with PAPI hardware interrupts: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE EXTRA_FLAGS="-DPAPI -DIC_THRESHOLD=$PI -DINTV_SAMPLING" make -f Makefile.orig $bench 
    file_prefix="${ci_type}-tuned-th1"
    emit_interval_stats $bench

    cd ../ > /dev/null
  done
}

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity radix fft lu-c lu-nc cholesky
  else
    perf_test $@
  fi
}

#1 - benchmark name (optional)
run_intv_acc_test() {
  mkdir -p $WRITE_DIR
  if [ $# -eq 0 ]; then
    interval_test water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity radix fft lu-c lu-nc cholesky
  else
    interval_test $@
  fi
}

rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
#echo "Note: Script has both accuracy tests & performance tests. Change the mode in the next few lines if any one of them is required only. "
#echo "Note: Number of threads for running performance tests need to be configured inside the file"
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Threads: 1"
echo "Usage: ./perf_test_libfiber <nothing / space separated list of splash2 benchmarks>"
mkdir -p $DIR
if [ $# -eq 0 ]; then
  run_perf_test
  run_intv_acc_test
else
  run_perf_test $@
  run_intv_acc_test $@
fi

rm -f $OUT_FILE $SUM_FILE
