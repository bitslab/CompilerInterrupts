#!/bin/bash
CI=1000
PI="${PI:-5000}"
RUNS="${RUNS:-5}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
DIR=$CUR_PATH/splash2_stats/$SUB_DIR
#CLOCK=1 #0 - predictive, 1 - instantaneous
THREADS="${THREADS:-"1 2 4 8 16 32"}"

LOG_FILE="$DIR/perf_logs-$AD.txt"
DEBUG_FILE="$DIR/perf_debug-$AD.txt"
BUILD_ERROR_FILE="$DIR/perf_test_build_error-$AD.txt"
BUILD_DEBUG_FILE="$DIR/perf_test_build_log-$AD.txt"

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
  echo "Dry run: "$command >> $DEBUG_FILE
  eval $command
  cd - > /dev/null
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_time() {
  threads=$2
  suffix_conf=$3
  declare suffix
  if [ $suffix_conf -eq 0 ]; then
    suffix="orig"
  else
    suffix="lc"
  fi
  if [ $4 -eq 1 ]; then
    prefix="timeout 5m taskset 0x00000001 "
  else
    prefix="timeout 5m "
  fi
  OUT_FILE="$DIR/out"
  SUM_FILE="$DIR/sum"

  DIVISOR=`expr $RUNS \* 1000`
  rm -f $OUT_FILE $SUM_FILE
  dry_run $1

  echo -n "scale=2;(" > $SUM_FILE
  for j in `seq 1 $RUNS`
  do
    case "$1" in
      water-nsquared)
        cd water-nsquared > /dev/null
        command="$prefix ./water-nsquared-$suffix < input.$threads > $OUT_FILE; sleep 0.5"
      ;;
      water-spatial)
        cd water-spatial > /dev/null
        command="$prefix ./water-spatial-$suffix < input.$threads > $OUT_FILE; sleep 0.5"
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
    time_in_us=`cat $OUT_FILE | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    if [ ! -z "$time_in_us" ]; then
      echo $time_in_us | tr -d '\n' >> $SUM_FILE
      echo "$time_in_us us" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        echo -n "+" >> $SUM_FILE
      fi
    else
      echo "Run failed. Output: " >> $DEBUG_FILE
      cat $OUT_FILE >> $DEBUG_FILE
      exit
    fi
  done
  echo ")/$DIVISOR" >> $SUM_FILE
  time_in_ms=`cat $SUM_FILE | bc`
  echo "Average: $time_in_ms ms" >> $DEBUG_FILE
  echo $time_in_ms
}

perf_test() {
  echo "=================================== PERFORMANCE TEST ==========================================="
  declare final_thread
#LEGACY_INTV="1 10 100 1000 10000"
  LEGACY_INTV="100 1000"

  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/splash2-perf_stats-th$thread-ad$AD.txt"
#echo -ne "benchmark\torig\tnaive\tperiodic" > $PER_THREAD_STAT_FILE
    echo -ne "benchmark\torig\tnaive\tperiodic\tcoredet_tl\tcoredet_local" > $PER_THREAD_STAT_FILE
    for legacy_intv in $LEGACY_INTV
    do
      echo -ne "\tlegacy_$legacy_intv" >> $PER_THREAD_STAT_FILE
    done
    echo "" >> $PER_THREAD_STAT_FILE
  done

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
    PER_BENCH_ORIG_STAT_FILE="$DIR/$bench-perf_orig-ad$AD.txt"
    PER_BENCH_PERIODIC_STAT_FILE="$DIR/$bench-perf_periodic-ad$AD.txt"
    PER_BENCH_NAIVE_STAT_FILE="$DIR/$bench-perf_naive-ad$AD.txt"
    PER_BENCH_COREDET_TL_STAT_FILE="$DIR/$bench-perf_coredet-tl-ad$AD.txt"
    PER_BENCH_COREDET_LOCAL_STAT_FILE="$DIR/$bench-perf_coredet-local-ad$AD.txt"
    echo "************* $bench ***************" | tee -a $LOG_FILE $DEBUG_FILE 
    echo "Thread, Duration" >> $LOG_FILE
    echo "Pthread" > $PER_BENCH_ORIG_STAT_FILE
    echo "Periodic" > $PER_BENCH_PERIODIC_STAT_FILE
    echo "Naive" > $PER_BENCH_NAIVE_STAT_FILE
    echo "CoreDet_TL" > $PER_BENCH_COREDET_TL_STAT_FILE
    echo "CoreDet_Local" > $PER_BENCH_COREDET_LOCAL_STAT_FILE
    for legacy_intv in $LEGACY_INTV
    do
      PER_BENCH_LEGACY_STAT_FILE="$DIR/$bench-perf_legacy_$legacy_intv-ad$AD.txt"
      echo "Legacy_$legacy_intv" > $PER_BENCH_LEGACY_STAT_FILE
    done

    #1. Build original program with pthread
    echo "Building original pthread program: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench 

    declare orig_time_thr1 periodic_time_thr1 naive_time_thr1 legacy_time_thr1
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/splash2-perf_stats-th$thread-ad$AD.txt"
      orig_time=$(get_time $bench $thread 0 0)
      echo -ne "$bench" >> $PER_THREAD_STAT_FILE
      echo -ne "\t$orig_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$orig_time" >> $PER_BENCH_ORIG_STAT_FILE
      echo -e "$thread, $orig_time (orig)" >> $LOG_FILE
      orig_time_thr1=$orig_time
    done

    #4. Build original program with Naive CI
    echo "Building original program with Naive CI: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $bench
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/splash2-perf_stats-th$thread-ad$AD.txt"
      lc_naive_time=$(get_time $bench $thread 1 0)
      echo -ne "\t$lc_naive_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$lc_naive_time" >> $PER_BENCH_NAIVE_STAT_FILE
      echo -e "$thread, $lc_naive_time (lc-naive)" >> $LOG_FILE
      naive_time_thr1=$lc_naive_time
    done

    #2. Build original program with Periodic CI
    echo "Building original program with Periodic CI: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $bench 
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/splash2-perf_stats-th$thread-ad$AD.txt"
      lc_periodic_time=$(get_time $bench $thread 1 0)
      echo -ne "\t$lc_periodic_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$lc_periodic_time" >> $PER_BENCH_PERIODIC_STAT_FILE
      echo -e "$thread, $lc_periodic_time (lc-periodic)" >> $LOG_FILE
      periodic_time_thr1=$lc_periodic_time
    done

    #4. Build original program with CoreDet TL CI
    echo "Building original program with CoreDet TL CI: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=6 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $bench
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/splash2-perf_stats-th$thread-ad$AD.txt"
      lc_coredet_tl_time=$(get_time $bench $thread 1 0)
      echo -ne "\t$lc_coredet_tl_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$lc_coredet_tl_time" >> $PER_BENCH_COREDET_TL_STAT_FILE
      echo -e "$thread, $lc_coredet_tl_time (lc-coredet-tl)" >> $LOG_FILE
      coredet_tl_time_thr1=$lc_coredet_tl_time
    done

    #4. Build original program with CoreDet Local CI
    echo "Building original program with CoreDet Local CI: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=7 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $bench
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/splash2-perf_stats-th$thread-ad$AD.txt"
      lc_coredet_local_time=$(get_time $bench $thread 1 0)
      echo -ne "\t$lc_coredet_local_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$lc_coredet_local_time" >> $PER_BENCH_COREDET_LOCAL_STAT_FILE
      echo -e "$thread, $lc_coredet_local_time (lc-coredet-local)" >> $LOG_FILE
      coredet_local_time_thr1=$lc_coredet_local_time
    done

    #5. Build original program with Legacy CI
    for legacy_intv in $LEGACY_INTV
    do
      echo "Building original program with Legacy CI with interval $legacy_intv: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$legacy_intv CMMT_INTV=$CI INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $bench
      PER_BENCH_LEGACY_STAT_FILE="$DIR/$bench-perf_legacy_$legacy_intv-ad$AD.txt"
      for thread in $THREADS
      do
          PER_THREAD_STAT_FILE="$DIR/splash2-perf_stats-th$thread-ad$AD.txt"
          lc_legacy_time=$(get_time $bench $thread 1 0)
          echo -ne "\t$lc_legacy_time" >> $PER_THREAD_STAT_FILE
          echo -e "$thread\t$lc_legacy_time" >> $PER_BENCH_LEGACY_STAT_FILE
          echo -e "$thread, $lc_legacy_time (lc-legacy_$legacy_intv)" >> $LOG_FILE
          legacy_time_thr1=$lc_legacy_time
      done
    done

    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/splash2-perf_stats-th$thread-ad$AD.txt"
      echo "" >> $PER_THREAD_STAT_FILE
    done

    #Print
    echo "Statistics for $thread thread:-"
    echo "Original program with pthread duration: $orig_time_thr1 ms" | tee -a $LOG_FILE
    echo "Program with Periodic CI duration: $periodic_time_thr1 ms" | tee -a $LOG_FILE
    echo "Program with Naive CI duration: $naive_time_thr1 ms" | tee -a $LOG_FILE
#echo "Program with Legacy CI duration: $legacy_time_thr1 ms" | tee -a $LOG_FILE
    slowdown_periodic=`echo "scale = 3; ($periodic_time_thr1 / $orig_time_thr1)" | bc -l`
    slowdown_naive=`echo "scale = 3; ($naive_time_thr1 / $orig_time_thr1)" | bc -l`
#slowdown_legacy=`echo "scale = 3; ($legacy_time_thr1 / $orig_time_thr1)" | bc -l`
    echo "Slowdown of Periodic CI over original: ${slowdown_periodic}x" | tee -a $LOG_FILE
    echo "Slowdown of Naive CI over original: ${slowdown_naive}x" | tee -a $LOG_FILE
#echo "Slowdown of Legacy CI over original: ${slowdown_legacy}x" | tee -a $LOG_FILE
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

rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
#echo "Note: Script has both accuracy tests & performance tests. Change the mode in the next few lines if any one of them is required only. "
#echo "Note: Number of threads for running performance tests need to be configured inside the file"
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: $THREADS"
echo "Usage: ./perf_test_libfiber <nothing / space separated list of splash2 benchmarks>"
mkdir -p $DIR
if [ $# -eq 0 ]; then
  run_perf_test
else
  run_perf_test $@
fi

rm -f $OUT_FILE $SUM_FILE
