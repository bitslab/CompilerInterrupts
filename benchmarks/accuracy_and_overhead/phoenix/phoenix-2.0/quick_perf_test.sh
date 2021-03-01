#!/bin/bash
CI=1000
PI="${PI:-5000}"
RUNS="${RUNS:-5}"
AD=100
CUR_PATH=`pwd`
#THREADS="${THREADS:-"1 2 4 8 16 32"}"
THREADS="${THREADS:-"1 32"}"
SUB_DIR="${SUB_DIR:-""}"
DIR=$CUR_PATH/phoenix_stats/$SUB_DIR
CYCLE="${CYCLE:-5000}"

dry_run() {
  # Dry run - so that any disk caching does not hamper the process
  case "$1" in
    histogram)
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
  threads=$2
  program=$1

  DIVISOR=`expr $RUNS \* 1000`
  rm -f sum
  dry_run $program

  echo -n "scale=2;(" > sum
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
    echo $time_in_us | tr -d '\n' >> sum
    in_ms=`echo "scale=2;($time_in_us/1000)" | bc`
    echo $in_ms >> $BENCH_LOG
    echo "$time_in_us ms" >> $DEBUG_FILE
    if [ $j -lt $RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$DIVISOR" >> sum
  time_in_ms=`cat sum | bc`
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
    EXP_FILE="$DIR/phoenix_orig-th$thread"
    echo "Orig" > $EXP_FILE

    echo "Building original program: " | tee -a $DEBUG_FILE
    make -f Makefile.orig clean >>$BUILD_DEBUG_FILE 2>>$BUILD_ERROR_FILE
    make -f Makefile.orig >>$BUILD_DEBUG_FILE 2>>$BUILD_ERROR_FILE
    for bench in $BENCH
    do
      orig_time=$(get_time $bench $thread 0)
      echo -e "$bench\t$orig_time" >> $EXP_FILE
    done
  done
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
      echo "Evaluating OPT INTERMEDIATE with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    ;;
    13) ci_type="naive-int"
      AD=100
      echo "Evaluating NAIVE INTERMEDIATE with ECC $AD" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    ;;
    17) ci_type="opt-cycles"
      AD=100
      echo "Evaluating OPT CYCLES with ECC $AD" | tee -a $DEBUG_FILE
    ;;
    *)
      echo "Wrong CI Type"
      exit
    ;;
  esac

  for thread in $THREADS
  do
    EXP_FILE="$DIR/phoenix_${ci_type}-tuned-th$thread"
    echo "${ci_type}-tuned" > $EXP_FILE

    for bench in $BENCH
    do
      PI=$(read_tune_param $bench $CI_SETTING $thread)
      CI=`echo "scale=0; $PI/5" | bc`
      echo "Using interval PI:$PI, CI:$CI, ECC:$AD for $bench" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE
      make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
      ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
      opt_time_periodic=$(get_time $bench $thread 1)
      echo -e "$bench\t$opt_time_periodic" >> $EXP_FILE
    done
  done
}

echo "Note: Script has performance tests for both instantaneous & predictive clocks."
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: $THREADS, Output Directory: $DIR"
mkdir -p $DIR;

BUILD_ERROR_FILE="$DIR/perf_test_build_error.txt"
BUILD_DEBUG_FILE="$DIR/perf_test_build_log.txt"
BENCH_LOG="$DIR/orig-runs-log.txt"
LOG_FILE="$DIR/perf_logs.txt"
DEBUG_FILE="$DIR/perf_debug.txt"

BENCH="reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count"
rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE $BENCH_LOG

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
#settings_list="2 4 6 8 10 12 13 17"
settings_list="2 12"
for setting in $settings_list
do
  CI_SETTING=$setting
  ci_perf_test
done

rm -f out sum
