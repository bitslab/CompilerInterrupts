#!/bin/bash
CI=1000
PI="${PI:-5000}"
RUNS="${RUNS:-2}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
DIR=$CUR_PATH/parsec_stats/$SUB_DIR
#CLOCK=1 #0 - predictive, 1 - instantaneous
#THREADS="${THREADS:-"1 2 4 8 16 32"}"
THREADS="${THREADS:-"1 32"}"
CYCLE="${CYCLE:-5000}"

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
get_time() {
  rm -f out
  threads=$2
  suffix_conf=$3
  declare suffix
  if [ $suffix_conf -eq 0 ]; then
    suffix="_llvm"
  else
    suffix="_ci"
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
      blackscholes)
        cd blackscholes/src > /dev/null
        $prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE
        echo "$prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      fluidanimate)
        cd fluidanimate/src > /dev/null
        $prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE
        echo "$prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      swaptions) 
        cd swaptions/src > /dev/null
        $prefix ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > $OUT_FILE
	      echo "$prefix ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      canneal) 
        cd canneal/src > /dev/null
        $prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > $OUT_FILE
	      echo "$prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      dedup)
        cd dedup/src > /dev/null
        $prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE
        echo "$prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      streamcluster)
        cd streamcluster/src > /dev/null
        $prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > $OUT_FILE
        echo "$prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
    esac
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

read_tune_param() {
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
    17) ci_type="opt-cycles";;
    *)
      echo "Wrong CI Type"
      exit
    ;;
  esac
  if [ $2 -eq 8 ]; then
    intv=5000
  else
  tune_file="./${ci_type}-tuning-th$3-${CYCLE}.txt"
    while read line; do
      present=`echo $line | grep $1 | wc -l`
      if [ $present -eq 1 ]; then
        intv=`echo $line | cut -d' ' -f 2`
        break
      fi
    done < $tune_file
  fi
  echo $intv
}

orig_test() {

  for thread in $THREADS
  do
    EXP_FILE="$DIR/parsec_orig-th$thread"
    echo "Orig" > $EXP_FILE
  done

  for bench in $BENCH
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

    echo "Building original program for $bench: " | tee -a $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.llvm ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.llvm ${bench} 

    for thread in $THREADS
    do
      EXP_FILE="$DIR/parsec_orig-th$thread"
      orig_time=$(get_time $bench $thread 0 0)
      echo -e "$bench\t$orig_time" >> $EXP_FILE
    done

    cd ../
  done
}

ci_perf_test() {

  case "$CI_SETTING" in
    2) ci_type="opt-tl"
      AD=100
      echo "Evaluating OPT TL with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE
    ;;
    4) ci_type="naive-tl"
      AD=100
      echo "Evaluating NAIVE TL with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE
    ;;
    6) ci_type="cd-tl"
      AD=100
      echo "Evaluating CD TL with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE
    ;;
    8) ci_type="legacy-acc"
      AD=0
      echo "Evaluating LEGACY ACC with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE
    ;;
    9) ci_type="opt-acc"
      AD=0
      echo "Evaluating OPT ACC with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE
    ;;
    10) ci_type="legacy-tl"
      AD=1
      echo "Evaluating LEGACY TL with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE
    ;;
    11) ci_type="naive-acc"
      AD=0
      echo "Evaluating NAIVE ACC with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE
    ;;
    12) ci_type="opt-int"
      AD=100
      echo "Evaluating OPT INTERMEDIATE with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE
    ;;
    13) ci_type="naive-int"
      AD=100
      echo "Evaluating NAIVE INTERMEDIATE with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE
    ;;
    17) ci_type="opt-cycles"
      AD=100
      echo "Evaluating OPT CYCLES with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE
    ;;
    *)
      echo "Wrong CI Type"
      exit
    ;;
  esac

  for thread in $THREADS
  do
    EXP_FILE="$DIR/parsec_${ci_type}-tuned-th$thread"
    echo "${ci_type}-tuned" > $EXP_FILE
    for bench in $BENCH
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

      PI=$(read_tune_param $bench $CI_SETTING $thread)
      CI=`echo "scale=0; $PI/5" | bc`
      echo "Using interval PI:$PI, CI:$CI, ECC:$AD for $bench" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE

      cd $BENCH_DIR
      
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING PROFILE_FLAGS="-DAVG_STATS" make -f Makefile.ci ${bench}
      lc_periodic_time=$(get_time $bench $thread 1 0)
      echo -e "$bench\t$lc_periodic_time" >> $EXP_FILE

      cd ../ > /dev/null
    done
  done
}

BENCH="blackscholes fluidanimate swaptions canneal streamcluster dedup"
rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
#echo "Note: Script has both accuracy tests & performance tests. Change the mode in the next few lines if any one of them is required only. "
#echo "Note: Number of threads for running performance tests need to be configured inside the file"
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: $THREADS"
echo "Usage: ./perf_test_libfiber <nothing / space separated list of parsec benchmarks>"
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
OPT_CYCLES=17

orig_test
#settings_list="9 11 8 2 4 10 6 12 13"
#settings_list="6 12 13"
#settings_list="9 11 8 2 4 10"
#settings_list="12 13"
#settings_list="8 12 13 2 4 10 6"
#settings_list="2 12"
#settings_list="2 4 6 10 8 12 13 17"
settings_list="2 12"
for setting in $settings_list
do
  CI_SETTING=$setting
  ci_perf_test
done

rm -f $OUT_FILE $SUM_FILE
