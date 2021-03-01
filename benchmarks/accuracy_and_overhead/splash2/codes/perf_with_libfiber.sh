#!/bin/bash
CI=1000
PI="${PI:-5000}"
RUNS="${RUNS:-5}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
DIR=$CUR_PATH/splash2_stats/$SUB_DIR
THREADS="${THREADS:-"1 2 4 8 16 32"}"
CYCLE=5000
CLOCK=1 #0 - predictive, 1 - instantaneous

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
  echo $command >> $DEBUG_FILE
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
    prefix="timeout 2m taskset 0x00000001 "
  else
    prefix="timeout 2m "
  fi
  OUT_FILE="$DIR/out"
  SUM_FILE="$DIR/sum"

  DIVISOR=`expr $RUNS \* 1000`
  rm -f $SUM_FILE $SUM_FILE
  #dry_run $1

  echo -n "scale=2;(" > $SUM_FILE
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
    time_in_us=`cat $OUT_FILE | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    if [ ! -z "$time_in_us" ]; then
      echo $time_in_us | tr -d '\n' >> $SUM_FILE
      echo "$time_in_us us" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        echo -n "+" >> $SUM_FILE
      fi
    fi
  done
  echo ")/$DIVISOR" >> $SUM_FILE
  time_in_ms=`cat $SUM_FILE | bc`
  echo "Average: $time_in_ms ms" >> $DEBUG_FILE
  echo $time_in_ms
}

read_tune_param() {
  case "$2" in
    14) ci_type="opt-tl";; # for fiber but same config
    15) ci_type="opt-int";; # for fiber but same config
    *)
      echo "Wrong CI Type"
      exit
    ;;
  esac
  tune_file="../${ci_type}-tuning-${CYCLE}.txt"
  while read line; do
    present=`echo $line | grep $1 | wc -l`
    if [ $present -eq 1 ]; then
      intv=`echo $line | cut -d' ' -f 2`
      break
    fi
  done < $tune_file
  echo $intv
}

perf_test() {
  echo "=================================== PERFORMANCE TEST ==========================================="

  declare final_thread

  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.csv"
#echo -e "benchmark\torig\tlc\torig_fiber\tlc_fiber" > $PER_THREAD_STAT_FILE
    echo -e "benchmark\tPThread\tFiber-CI\tFiber-CI-Cycles\tFiber" > $PER_THREAD_STAT_FILE
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
    PER_BENCH_ORIG_STAT_FILE="$DIR/$bench-perf_orig-$AD.txt"
    PER_BENCH_ORIG_FIBER_STAT_FILE="$DIR/$bench-perf_orig_fiber-$AD.txt"
    PER_BENCH_LC_FIBER_STAT_FILE="$DIR/$bench-perf_lc_fiber-$AD.txt"
    PER_BENCH_LC_CYCLES_FIBER_STAT_FILE="$DIR/$bench-perf_lc_cycles_fiber-$AD.txt"
    PER_BENCH_LC_ACCURACY_STAT_FILE="$DIR/$bench-accuracy-$AD.txt"
    echo "************* $bench ***************" | tee -a $LOG_FILE $DEBUG_FILE 
    echo "Thread, Duration" >> $LOG_FILE
    echo "Pthread" > $PER_BENCH_ORIG_STAT_FILE
    echo "Fiber" > $PER_BENCH_ORIG_FIBER_STAT_FILE
    echo "Fiber-CI" > $PER_BENCH_LC_FIBER_STAT_FILE
    echo "Fiber-CI-Cycles" > $PER_BENCH_LC_CYCLES_FIBER_STAT_FILE

    if [ 1 -eq 1 ]; then
    #1. Build original program with pthread
    echo "Building original pthread program: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench 

    declare orig_time_thr1 orig_fiber_time_thr1 lc_fiber_time_thr1
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.csv"
      suffix="orig"; dry_run $bench
      orig_time=$(get_time $bench $thread 0 1)
      echo -ne "$bench" >> $PER_THREAD_STAT_FILE
      echo -ne "\t$orig_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$orig_time" >> $PER_BENCH_ORIG_STAT_FILE
      echo -e "$thread, $orig_time (orig)" >> $LOG_FILE
      if [ $thread -eq 1 ]; then
        orig_time_thr1=$orig_time
      fi
    done
    fi

    #2. Build original program with fiber & LC
    CI_SETTING=14
    PI=$(read_tune_param $bench $CI_SETTING)
    CI=`echo "scale=0; $PI/5" | bc`
    AD=100
    echo "Building original program with fiber & CI with PI $PI, CI: $CI, CYCLES:$CYCLE, ECC:$AD : " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc.libfiber $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$CI_SETTING CYCLE_INTV=$CYCLE make -f Makefile.lc.libfiber $bench 
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.csv"
      suffix="lc"; dry_run $bench
      lc_fiber_time=$(get_time $bench $thread 1 0)
      echo -ne "\t$lc_fiber_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$lc_fiber_time" >> $PER_BENCH_LC_FIBER_STAT_FILE
      echo -e "$thread, $lc_fiber_time (lc-fiber)" >> $LOG_FILE
      if [ $thread -eq 1 ]; then
        lc_fiber_time_thr1=$lc_fiber_time
      fi
    done

    if [ 1 -eq 1 ]; then
    #2. Build original program with fiber & LC
    CI_SETTING=15
    PI=$(read_tune_param $bench $CI_SETTING)
    CI=`echo "scale=0; $PI/5" | bc`
    AD=100
    echo "Building original program with fiber & CI-Cycles with PI $PI, CI: $CI, CYCLES:$CYCLE, ECC:$AD : " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc.libfiber $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$CI_SETTING CYCLE_INTV=$CYCLE make -f Makefile.lc.libfiber $bench 
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.csv"
      suffix="lc"; dry_run $bench
      lc_cycles_fiber_time=$(get_time $bench $thread 1 0)
      echo -ne "\t$lc_cycles_fiber_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$lc_cycles_fiber_time" >> $PER_BENCH_LC_CYCLES_FIBER_STAT_FILE
      echo -e "$thread, $lc_cycles_fiber_time (lc-cycles-fiber)" >> $LOG_FILE
      if [ $thread -eq 1 ]; then
        lc_fiber_time_thr1=$lc_cycles_fiber_time
      fi
    done
    else
      lc_cycles_fiber_time="?"
      echo -ne "\t$lc_cycles_fiber_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$lc_cycles_fiber_time" >> $PER_BENCH_LC_CYCLES_FIBER_STAT_FILE
      echo -e "$thread, $lc_cycles_fiber_time (lc-cycles-fiber)" >> $LOG_FILE
    fi

    #3. Build original program with fiber

    echo "Building original program with fiber: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig.libfiber $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig.libfiber $bench 

    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-$thread-$AD.csv"

      #*************************** Not running non-terminating programs that have ad-hoc synchronization issues *****************************#
      orig_fiber_time=""
      if [ $thread -ne 1 ]; then
        case "$bench" in
          "cholesky" | "barnes" | "volrend" | "fmm" | "radiosity")
            echo "Orig-Fiber configuration does not terminate for $bench" | tee -a $DEBUG_FILE
            orig_fiber_time="?"
            ;;
          *)
            orig_fiber_time=$(get_time $bench $thread 0 0)
            ;;
        esac
      else
        suffix="orig"; dry_run $bench
        orig_fiber_time=$(get_time $bench $thread 0 0)
      fi

      echo -e "\t$orig_fiber_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$orig_fiber_time" >> $PER_BENCH_ORIG_FIBER_STAT_FILE
      echo -e "$thread, $orig_fiber_time (orig-fiber)" >> $LOG_FILE
      if [ $thread -eq 1 ]; then
        orig_fiber_time_thr1=$orig_fiber_time
      fi
      final_thread=$thread
    done

    #Print
    echo "Statistics for 1 thread:-"
    echo "Original program with pthread duration: $orig_time_thr1 ms" | tee -a $LOG_FILE
    echo "Original program with libfiber duration: $orig_fiber_time_thr1 ms" | tee -a $LOG_FILE
    echo "Program with logical clock & libfiber duration: $lc_fiber_time_thr1 ms" | tee -a $LOG_FILE
    slowdown_fiber=`echo "scale = 3; ($orig_fiber_time_thr1 / $orig_time_thr1)" | bc -l`
    slowdown_lc_fiber=`echo "scale = 3; ($lc_fiber_time_thr1 / $orig_time_thr1)" | bc -l`
    echo "Slowdown of fiber integrated program over original: ${slowdown_fiber}x" | tee -a $LOG_FILE
    echo "Slowdown of fiber & logical clock integrated program over original: ${slowdown_lc_fiber}x" | tee -a $LOG_FILE
    cd ..
  done
}

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test radix fft lu-c lu-nc cholesky water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
    #perf_test cholesky barnes volrend fmm radiosity
  else
    perf_test $@
  fi
}

rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
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

rm -f $OUT_FILE $SUM_FILE
