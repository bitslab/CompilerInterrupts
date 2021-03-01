#!/bin/bash
CI=1000
PI="${PI:-5000}"
AD=100
CUR_PATH=`pwd`
THREAD="${THREAD:-1}"
SUB_DIR="${SUB_DIR:-""}"
SUB_DIR=${SUB_DIR}_th${THREAD}
DIR=$CUR_PATH/phoenix_stats/$SUB_DIR
WRITE_DIR=/local_home/nilanjana/temp/$SUB_DIR
CLOCK=1
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

get_stats() {
  for bench in $*
  do
    emit_interval_stats $bench
  done
}

perf_test() {
  echo "=================================== INTERVAL ACCURACY TEST ==========================================="

  NAIVE=3
  NAIVE_TL=4
  OPT=1
  OPT_TL=2
  CD=7
  CD_TL=6
  LEGACY=5
  LEGACY_TL=10
  OPT_ACC=9
  LEGACY_ACC=8
  NAIVE_ACC=11

  LOG_FILE="$DIR/perf_logs-ad$AD.txt"
  DEBUG_FILE="$DIR/perf_debug-ad$AD.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error-ad$AD.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log-ad$AD.txt"
  #FIBER_CONFIG is set in the Makefile. Unless needed, do not pass a new config from this script

  rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE

  #run periodic

#if [ 0 -eq 1 ]; then

  PI=5000
  AD=100

  if [ 0 -eq 1 ]; then
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$NAIVE EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    file_prefix="naive-pi${PI}_ecc${AD}"
    get_stats $*
  fi

  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$NAIVE_TL EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
  file_prefix="naive-tl-pi${PI}_ecc${AD}"
  get_stats $*

  if [ 0 -eq 1 ]; then
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$OPT EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
    file_prefix="opt-pi${PI}_ecc${AD}"
    get_stats $*
  fi

  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$OPT_TL EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
  file_prefix="opt-tl-pi${PI}_ecc${AD}"
  get_stats $*

  if [ 0 -eq 1 ]; then
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$CD EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
    file_prefix="cd-pi${PI}_ecc${AD}"
    get_stats $*
  fi

  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$CD_TL EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
  file_prefix="cd-tl-pi${PI}_ecc${AD}"
  get_stats $*

  PI=100
  AD=1

  if [ 0 -eq 1 ]; then
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEGACY EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
    file_prefix="legacy-pi${PI}_ecc${AD}"
    get_stats $*
  fi

  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEGACY_TL EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
  file_prefix="legacy-tl-pi${PI}_ecc${AD}"
  get_stats $*

  # Remove this
#fi

  PI=1000
  AD=0

  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEGACY_ACC EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
  file_prefix="legacy-acc-pi${PI}_ecc${AD}"
  get_stats $*

  PI=5000
  AD=0

  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$OPT_ACC EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
  file_prefix="opt-acc-pi${PI}_ecc${AD}"
  get_stats $*

  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$NAIVE_ACC EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
  file_prefix="naive-acc-pi${PI}_ecc${AD}"
  get_stats $*

  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEGACY_ACC EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
  file_prefix="legacy-acc-pi${PI}_ecc${AD}"
  get_stats $*
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
    tune_file="./${ci_type}-tuning-th${3}-${CYCLE}.txt"
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

ci_interval_test() {

  LOG_FILE="$DIR/perf_logs.txt"
  DEBUG_FILE="$DIR/perf_debug.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log.txt"
  
  echo "=================================== PROFILE ACCURACY TEST ==========================================="

  case "$CI_SETTING" in
    2) ci_type="opt-tl"
      AD=100
      echo "Evaluating OPT TL with ECC $AD" | tee -a $DEBUG_FILE
    ;;
    4) ci_type="naive-tl"
      AD=100
      echo "Evaluating NAIVE TL with ECC $AD" | tee -a $DEBUG_FILE
    ;;
    6) ci_type="cd-tl"
      AD=100
      echo "Evaluating CD TL with ECC $AD" | tee -a $DEBUG_FILE
    ;;
    8) ci_type="legacy-acc"
      AD=0
      echo "Evaluating LEGACY ACC with ECC $AD" | tee -a $DEBUG_FILE
    ;;
    9) ci_type="opt-acc"
      AD=0
      echo "Evaluating OPT ACC with ECC $AD" | tee -a $DEBUG_FILE
    ;;
    10) ci_type="legacy-tl"
      AD=1
      echo "Evaluating LEGACY TL with ECC $AD" | tee -a $DEBUG_FILE
    ;;
    11) ci_type="naive-acc"
      AD=0
      echo "Evaluating NAIVE ACC with ECC $AD" | tee -a $DEBUG_FILE
    ;;
    12) ci_type="opt-int"
      AD=100
      echo "Evaluating OPT INTERMEDIATE with ECC $AD" | tee -a $DEBUG_FILE
    ;;
    13) ci_type="naive-int"
      AD=100
      echo "Evaluating NAIVE INTERMEDIATE with ECC $AD" | tee -a $DEBUG_FILE
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

  for bench in $*
  do
    PI=$(read_tune_param $bench $CI_SETTING $THREAD)
    CI=`echo "scale=0; $PI/5" | bc`
    echo "Using interval PI:$PI, CI:$CI, ECC:$AD for $bench" | tee -a $DEBUG_FILE
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    #ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING -DRUNNING_MEDIAN" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
    file_prefix="${ci_type}-tuned-th$THREAD"
    emit_interval_stats $bench
  done

}

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

run_perf_test() {
  if [ $# -eq 0 ]; then
#perf_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
#settings_list="9 11 8 2 4 10 6 12 13"
#settings_list="6 12 13"
#settings_list="9 11 8 2 4 10"
#settings_list="12 13"
#settings_list="8 12 13 2 4 10 6"
#settings_list="2 12"
#settings_list="2 4 6 8 10 12 13 17"
    settings_list="2 12"
    for setting in $settings_list
    do
      CI_SETTING=$setting
      ci_interval_test $BENCH
    done
  else
#perf_test $@
    ci_interval_test $@
  fi
}

BENCH="reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count"
rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Allowed deviation: $AD, Output Directory: $WRITE_DIR"
echo "WARNING: Remove Passed Config if you don't need it!"
mkdir -p $DIR;
mkdir -p $WRITE_DIR;

if [ $# -eq 0 ]; then
  run_perf_test
else
  run_perf_test $@
fi

echo "Copy test-suite/process_data.sh to $WRITE_DIR (for each thread count). Edit process_data.sh to change the set of benchmarks tested, & the CI configurations used. Run ./process_data <threads>. Copy *.s100 to plot directory."
