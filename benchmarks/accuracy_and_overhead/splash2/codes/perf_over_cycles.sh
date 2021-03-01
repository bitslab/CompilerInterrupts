#!/bin/bash
RUNS="${RUNS:-5}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-"cycle_exp"}"
DIR=$CUR_PATH/splash2_stats/$SUB_DIR
#CLOCK=1 #0 - predictive, 1 - instantaneous
CYCLE="${CYCLE:-"1000 5000 10000 15000 25000 50000 100000 500000 1000000"}"
BENCH="water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity radix fft lu-c lu-nc cholesky"

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

orig_test() {

  for thread in $THREADS
  do
    EXP_FILE="$DIR/orig-th$thread"
    echo "Orig" > $EXP_FILE
  done

  for bench in $BENCH
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

    echo "Building original program for $bench: " | tee -a $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench 

    for thread in $THREADS
    do
      EXP_FILE="$DIR/orig-th$thread"
      orig_time=$(get_time $bench $thread 0 0)
      echo -e "$bench\t$orig_time" >> $EXP_FILE
    done

    cd ../
  done
}

read_tune_param() {
  cycle=$3
  case "$2" in
    2) ci_type="opt-tl";;
    4) ci_type="naive-tl";;
    6) ci_type="cd-tl";;
    8) ci_type="legacy-acc";;
    9) ci_type="opt-acc";;
    10) ci_type="legacy-tl";;
    11) ci_type="naive-acc";;
    12) ci_type="opt-int";;
    13) ci_type="naive-int";;
    *)
      echo "Wrong CI Type"
      exit
    ;;
  esac

  if [ $2 -eq 8 ]; then
    intv=5000
  else
#tune_file="./${ci_type}-tuning-${CYCLE}.txt"
    tune_file="./${ci_type}-tuning-5000.txt"
    while read line; do
      present=`echo $line | grep $1 | wc -l`
      if [ $present -eq 1 ]; then
        intv5000=`echo $line | cut -d' ' -f 2`
        break
      fi
    done < $tune_file
    intv=`echo "($intv5000*$cycle)/5000" | bc`
    echo "cycle: $cycle, push intv: $intv, push intv for 5000 cycle: $intv5000" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE > /dev/null
  fi
  echo $intv
}

ci_perf_test() {

  case "$CI_SETTING" in
    2) ci_type="opt-tl"
      AD=100
      echo "Evaluating OPT TL with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    ;;
    4) ci_type="naive-tl"
      AD=100
      echo "Evaluating NAIVE TL with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    ;;
    6) ci_type="cd-tl"
      AD=100
      echo "Evaluating CD TL with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    ;;
    8) ci_type="legacy-acc"
      AD=0
      echo "Evaluating LEGACY ACC with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    ;;
    9) ci_type="opt-acc"
      AD=0
      echo "Evaluating OPT ACC with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    ;;
    10) ci_type="legacy-tl"
      AD=1
      echo "Evaluating LEGACY TL with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    ;;
    11) ci_type="naive-acc"
      AD=0
      echo "Evaluating NAIVE ACC with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    ;;
    12) ci_type="opt-int"
      AD=100
      echo "Evaluating OPT INTERMEDIATE with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE
    ;;
    13) ci_type="naive-int"
      AD=100
      echo "Evaluating NAIVE INTERMEDIATE with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE
    ;;
    *)
      echo "Wrong CI Type"
      exit
    ;;
  esac

  thread=1

  for cycles in $CYCLE
  do
    EXP_FILE="$DIR/${ci_type}-tuned-th$thread-cyc$cycles"
    echo "${ci_type}-tuned" > $EXP_FILE

    for bench in $BENCH
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

      PI=$(read_tune_param $bench $CI_SETTING $cycles)
      CI=`echo "scale=0; $PI/5" | bc`
      echo "Using interval PI:$PI, CI:$CI, ECC:$AD for $bench" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE

      cd $BENCH_DIR
      
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$cycles INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $bench 

      lc_periodic_time=$(get_time $bench $thread 1 0)
      echo -e "$bench\t$lc_periodic_time" >> $EXP_FILE

      cd ../ > /dev/null
    done
  done
}

rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
#echo "Note: Script has both accuracy tests & performance tests. Change the mode in the next few lines if any one of them is required only. "
#echo "Note: Number of threads for running performance tests need to be configured inside the file"
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: $THREADS"
echo "Usage: ./perf_test_libfiber <nothing / space separated list of splash2 benchmarks>"
mkdir -p $DIR

OPT_TL=2
NAIVE_TL=4
CD_TL=6
LEGACY_ACC=8
OPT_ACC=9
LEGACY_TL=10
NAIVE_ACC=11
OPT_INTERMEDIATE=12
NAIVE_INTERMEDIATE=13

THREADS="1" # only valid for 1 thread for opt
orig_test
#settings_list="6 12 13"
#settings_list="9 11 8 2 4 10"
#settings_list="12 13"
#settings_list="8 12 13 2 4 10 6"
settings_list="2 12"
for setting in $settings_list
do
  CI_SETTING=$setting
  ci_perf_test
done

rm -f $OUT_FILE $SUM_FILE
