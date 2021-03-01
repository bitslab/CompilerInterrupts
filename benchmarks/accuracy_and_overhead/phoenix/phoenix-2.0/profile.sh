#!/bin/bash
CUR_PATH=`pwd`
AD=100
CLOCK=1
THREAD=1
SUB_DIR="${SUB_DIR:-"osdi"}"
SUB_DIR=$SUB_DIR"_profile_th$THREAD"
DIR=$CUR_PATH/phoenix_stats/$SUB_DIR
WRITE_DIR=/local_home/nilanjana/temp/$SUB_DIR

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

profile_test() {

  LOG_FILE="$DIR/perf_logs-ad$AD.txt"
  DEBUG_FILE="$DIR/perf_debug-ad$AD.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error-ad$AD.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log-ad$AD.txt"
  
  echo "=================================== PROFILE ACCURACY TEST ==========================================="

  case "$ACC_SETTING" in
    2) ci_type="opt-tl"
      AD=100
      echo "Evaluating OPT TL with ECC $AD"
    ;;
    4) ci_type="naive-tl"
      AD=100
      echo "Evaluating NAIVE TL with ECC $AD"
    ;;
    6) ci_type="cd-tl"
      AD=100
      echo "Evaluating CD TL with ECC $AD"
    ;;
    8) ci_type="legacy-acc"
      AD=0
      echo "Evaluating LEGACY ACC with ECC $AD"
    ;;
    9) ci_type="opt-acc"
      AD=0
      echo "Evaluating OPT ACC with ECC $AD"
    ;;
    10) ci_type="legacy-tl"
      AD=1
      echo "Evaluating LEGACY TL with ECC $AD"
    ;;
    11) ci_type="naive-acc"
      AD=0
      echo "Evaluating NAIVE ACC with ECC $AD"
    ;;
    12) ci_type="opt-int"
      AD=100
      echo "Evaluating OPT INTERMEDIATE with ECC $AD"
    ;;
    13) ci_type="naive-int"
      AD=100
      echo "Evaluating NAIVE INTERMEDIATE with ECC $AD"
    ;;
    *)
      echo "Wrong CI Type"
      exit
    ;;
  esac

  echo "Profiling for intervals $PI"

#PI="2500 5000 10000 15000 20000 25000"
#PI="250 500 1000 1500 2500"

  for pi in $PI; do 
    CI=`echo "scale=0; $pi/5" | bc`
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$pi CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$ACC_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING -DRUNNING_MEDIAN" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
    file_prefix="${ci_type}-pi${pi}_ecc${AD}"
    get_stats $*
  done

}

app_profile_test() {

  LOG_FILE="$DIR/perf_logs-ad$AD.txt"
  DEBUG_FILE="$DIR/perf_debug-ad$AD.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error-ad$AD.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log-ad$AD.txt"
  
  echo "=================================== PROFILE ACCURACY TEST ==========================================="

  case "$ACC_SETTING" in
    2) ci_type="opt-tl"
      AD=100
      echo "Evaluating OPT TL with ECC $AD"
    ;;
    4) ci_type="naive-tl"
      AD=100
      echo "Evaluating NAIVE TL with ECC $AD"
    ;;
    6) ci_type="cd-tl"
      AD=100
      echo "Evaluating CD TL with ECC $AD"
    ;;
    8) ci_type="legacy-acc"
      AD=0
      echo "Evaluating LEGACY ACC with ECC $AD"
    ;;
    9) ci_type="opt-acc"
      AD=0
      echo "Evaluating OPT ACC with ECC $AD"
    ;;
    10) ci_type="legacy-tl"
      AD=1
      echo "Evaluating LEGACY TL with ECC $AD"
    ;;
    11) ci_type="naive-acc"
      AD=0
      echo "Evaluating NAIVE ACC with ECC $AD"
    ;;
    12) ci_type="opt-int"
      AD=100
      echo "Evaluating OPT INTERMEDIATE with ECC $AD"
    ;;
    13) ci_type="naive-int"
      AD=100
      echo "Evaluating NAIVE INTERMEDIATE with ECC $AD"
    ;;
    *)
      echo "Wrong CI Type"
      exit
    ;;
  esac

  bench=$1
  PI=$2

#PI="2500 5000 10000 15000 20000 25000"

  for pi in $PI; do 
    CI=`echo "scale=0; $pi/5" | bc`
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$pi CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$ACC_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING -DRUNNING_MEDIAN" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE 
    file_prefix="${ci_type}-pi${pi}_ecc${AD}"
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

CYCLE=5000

mkdir -p $DIR;
#rm -rf $WRITE_DIR
mkdir -p $WRITE_DIR;

if [ $# -eq 0 ]; then

  app_list="reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count"
  PI="200 500 1000 2000 5000 10000 15000 20000 25000 30000 35000 40000 45000 50000 75000 100000"
  #PI="2000 5000 10000 15000 20000 25000 30000 35000 40000 45000 50000"
  #PI="15000 25000 35000 50000 75000 100000 125000"
  #PI="500 1000 2000 5000 7500 10000 15000"

  echo "Profiling for $CYCLE cycles, $THREAD threads, app list: $app_list, PI: $PI"

  ACC_SETTING=$OPT_INTERMEDIATE
  profile_test $app_list

  ACC_SETTING=$OPT_TL
  profile_test $app_list

  exit

  if [ 0 -eq 1 ]; then
    ACC_SETTING=$OPT_ACC
    profile_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
    ACC_SETTING=$NAIVE_ACC
    profile_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
  fi
  ACC_SETTING=$LEGACY_ACC
  profile_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
  ACC_SETTING=$OPT_TL
  profile_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
  ACC_SETTING=$NAIVE_TL
  profile_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
  ACC_SETTING=$CD_TL
  profile_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
  ACC_SETTING=$OPT_INTERMEDIATE
  profile_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
  ACC_SETTING=$NAIVE_INTERMEDIATE
  profile_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count

  PI="20 50 100 150 250 500 750 1000 2000 5000 10000"
  #PI="100 250 500 750 1000"
  #PI="20 50 100 150 250 500"
  ACC_SETTING=$LEGACY_TL
  profile_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count

  if [ 1 -eq 0 ]; then
    app_profile_test reverse_index 7000
    app_profile_test histogram 17500
    app_profile_test kmeans 12500
    app_profile_test pca 18500
    app_profile_test matrix_multiply 16500
    app_profile_test linear_regression 12500
    app_profile_test word_count 13000
  fi
  app_profile_test matrix_multiply 17000
else
  PI="2000 5000 10000 15000 20000 25000 30000 35000 40000 45000 50000"
  ACC_SETTING=$OPT_INTERMEDIATE
  profile_test $@
fi

echo "Copy test-suite/process_profile_data.sh to $WRITE_DIR. Edit process_profile_data.sh to change the CI configurations used in profiling. Run script, choose app & the profiled optimal configuration will be exported to current directory."
