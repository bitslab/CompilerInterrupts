#!/bin/bash
CI=1000
PI="${PI:-5000}"
RUNS="${RUNS:-1}"
AD=100
CUR_PATH=`pwd`
BENCH_NAME="phoenix"
SUB_DIR="${SUB_DIR:-"benchmarks"}"
DIR=$CUR_PATH/phoenix_stats/$SUB_DIR
THREADS="${THREADS:-"1 32"}"
PERF_LOG_FILE="$DIR/${BENCH_NAME}_perf_log.txt"
ACC_LOG_FILE="$DIR/${BENCH_NAME}_acc_log.txt"
DEBUG_FILE="$DIR/${BENCH_NAME}_perf_debug.txt"
BUILD_ERROR_FILE="$DIR/${BENCH_NAME}_perf_test_build_error.txt"
BUILD_DEBUG_FILE="$DIR/${BENCH_NAME}_perf_test_build_log.txt"
OUT_FILE="out"
CYCLE="${CYCLE:-5000}"
RPC="${RPC:-0}" # currently not in use

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
    *)
      echo "Wrong CI Type $2 for $1"
      exit
    ;;
  esac
  if [ $2 -eq 8 ]; then
    intv=5000
  else
    tune_file="./${ci_type}-tuning-th1-${CYCLE}.txt"
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

run_program() {
  program=$1
  th=$2
  case "$program" in
    histogram)
      command="MR_NUMTHREADS=$th timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp > $OUT_FILE 2>&1"
    ;;
    kmeans)
      command="MR_NUMTHREADS=$th timeout 5m ./tests/$program/$program -d 100 -c 10 -p 500000 -s 50 > $OUT_FILE 2>&1"
    ;;
    pca) 
      command="MR_NUMTHREADS=$th timeout 5m ./tests/$program/$program -r 1000 -c 1000 -s 1000 > $OUT_FILE 2>&1"
    ;;
    matrix_multiply) 
      command="MR_NUMTHREADS=$th timeout 5m ./tests/$program/$program 900 600 1 > $OUT_FILE 2>&1"
    ;;
    string_match)
      command="MR_NUMTHREADS=$th timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_100MB.txt > $OUT_FILE 2>&1"
    ;;
    linear_regression)
      command="MR_NUMTHREADS=$th timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_500MB.txt > $OUT_FILE 2>&1"
    ;;
    word_count)
      command="MR_NUMTHREADS=$th timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/word_50MB.txt > $OUT_FILE 2>&1"
    ;;
    reverse_index)
      command="MR_NUMTHREADS=$th timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/www.stanford.edu/dept/news/ > $OUT_FILE 2>&1"
    ;;
  esac
  echo -e "Command for $program running $th threads:-\n$command" >> $DEBUG_FILE
  echo $command
}

get_time() {
  echo "Running (for time) $1 with $2 thread(s)" >> $DEBUG_FILE
  command=$(run_program $1 $2)
  eval $command #dry run
  eval $command
  time_in_us=`cat $OUT_FILE | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
  echo "Duration: $time_in_us us" >> $DEBUG_FILE
  echo $time_in_us
}

get_accuracy() {
  echo "Running (for interval stats) $1 with 1 thread" | tee -a $DEBUG_FILE
  rm -f /local_home/nilanjana/temp/interval_stats/interval_stats_thread*.txt 
  cdf_name="$1-$2.cdf"
  sample_name="$1-$2.s100"
  pc_name="$1-$2.pc"

  # run command
  command=$(run_program $1 1)
  eval $command #dry run
  eval $command
  cd /local_home/nilanjana/temp/interval_stats > /dev/null
  
  # create sampled cdf
  cat interval_stats_thread*.txt | grep -ve "PushSeq\|Total" |\
  awk '{print $4}' |\
  sort -n |\
  awk 'BEGIN {OFMT="%f"} {lines[i++]=$0} END {for(l in lines){print l/(i-1)," ",lines[l]}}' |\
  sort -n -k 2 \
  > $cdf_name 
  gawk -v lines="$(cat $cdf_name | wc -l)" 'lines<1000 || NR % int(lines/100) == 1 {print} {line=$0} END {print line}' $cdf_name > $sample_name
  echo "Sampled cdf to $sample_name"

  gawk 'BEGIN {split("1 5 10 25 50 75 90 95 99",ptiles," "); p=1} 
  !val[p] && $1+0>=(ptiles[p]+0)/100.0 {val[p]=$2; p++} 
  END { for(i=1;i<=length(ptiles);i++) { if(ptiles[i]) {print ptiles[i], ": ", val[i]}}}' file="$sample_name" $sample_name > ./$pc_name

  echo -e "\n============= $bench ================" | tee -a $ACC_LOG_FILE
  cat ./$pc_name | tee -a $ACC_LOG_FILE
  echo -e "\n" | tee -a $ACC_LOG_FILE
  
  cd - > /dev/null
}

build_phoenix_orig() {
  #run original 
  echo "Building original program: " | tee -a $DEBUG_FILE
  make -f Makefile.orig clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  make -f Makefile.orig >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.orig clean; make -f Makefile.orig
}

build_phoenix_ci_opt() {
  #run periodic
  if [ $# -ne 1 ]; then
    echo "Benchmark name needs to be passed to build_phoenix_ci_opt()"
    exit
  fi
  CI_SETTING=2
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building $1 with CI_SETTING:$CI_SETTING (opt), PI:$PI, CI:$CI, RPC: $RPC, AD:$AD" | tee -a $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI FIBER_CONFIG=$RPC CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.lc clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc
}

build_phoenix_ci_opt_cycles() {
  #run periodic
  if [ $# -ne 1 ]; then
    echo "Benchmark name needs to be passed to build_phoenix_ci_opt_cycles()"
    exit
  fi
  CI_SETTING=12
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building $1 with CI_SETTING:$CI_SETTING (opt-int), PI:$PI, CI:$CI, RPC: $RPC, AD:$AD" | tee -a $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI FIBER_CONFIG=$RPC CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.lc clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc
}

build_phoenix_ci_opt_intv_accuracy() {
  #build periodic with interval stats
  CI_SETTING=2
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo -e "\nAccuracy benchmark for $1 with CI_SETTING:$CI_SETTING (opt), PI:$PI, CI:$CI, RPC: $RPC, AD:$AD" | tee -a $DEBUG_FILE $ACC_LOG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI FIBER_CONFIG=$RPC CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.lc clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc
}

build_phoenix_ci_opt_cycles_intv_accuracy() {
  #build periodic with interval stats
  CI_SETTING=12
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo -e "\nAccuracy benchmark for $1 with CI_SETTING:$CI_SETTING (opt-int), PI:$PI, CI:$CI, RPC: $RPC, AD:$AD" | tee -a $DEBUG_FILE $ACC_LOG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI FIBER_CONFIG=$RPC CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.lc clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc
}

# log to check output & see if the transformations led to erroneous program flow
test_phoenix_output() {
  ALL_ORIG_OUT="$DIR/${BENCH_NAME}_output_orig_all.txt"
  ALL_CI_OUT="$DIR/${BENCH_NAME}_output_opt_all.txt"
  OUTPUT_DIFF="$DIR/${BENCH_NAME}_output_diff.txt"
  thread=1
  rm -f $ALL_ORIG_OUT $ALL_CI_OUT $OUTPUT_DIFF
  for bench in "$@"
  do
    OUTPUT_ORIG_FILE="$DIR/${BENCH_NAME}_output_orig_${bench}.txt"
    OUTPUT_CI_FILE="$DIR/${BENCH_NAME}_output_opt_${bench}.txt"
    rm -f $OUTPUT_ORIG_FILE $OUTPUT_CI_FILE
    build_phoenix_orig
    echo "Running (for time) $bench with $thread thread(s)" | tee -a $OUTPUT_ORIG_FILE
    command=$(run_program $bench $thread)
    eval $command
    cat $OUT_FILE | tee -a $OUTPUT_ORIG_FILE $ALL_ORIG_OUT > /dev/null

    build_phoenix_ci_opt $bench
    echo "Running (for time) $bench with $thread thread(s)" | tee -a $OUTPUT_CI_FILE
    command=$(run_program $bench $thread)
    eval $command
    cat $OUT_FILE | tee -a $OUTPUT_CI_FILE $ALL_CI_OUT > /dev/null
    echo -e "\n\n******************** $bench ********************" >> $OUTPUT_DIFF
    diff --suppress-common-lines -yiEw $OUTPUT_ORIG_FILE $OUTPUT_CI_FILE >> $OUTPUT_DIFF
  done

  echo "Find individual outputs in $DIR/output_orig_<#bench> and $DIR/output_opt_<#bench>. Find overall outputs in $ALL_ORIG_OUT and $ALL_CI_OUT. Diff of all outputs are consolidated in $OUTPUT_DIFF"
#echo "Run \"diff --suppress-common-lines -yiEw $DIR/output_orig.txt $DIR/output_opt.txt\"" | tee -a $LOG_FILE
}

check_perf_opt() {
  echo "************************* PERF BENCHMARKS *****************************" >> $DEBUG_FILE
  for bench in "$@"
  do
    build_phoenix_orig $bench
    orig_time=$(get_time $bench 1)
    build_phoenix_ci_opt $bench
    opt_time=$(get_time $bench 1)
    build_phoenix_ci_opt_cycles $bench
    opt_cycles_time=$(get_time $bench 1)

    slowdown_opt=`echo "scale=2;(($opt_time-$orig_time)*100/$orig_time)" | bc`
    slowdown_opt_cycles=`echo "scale=2;(($opt_cycles_time-$orig_time)*100/$orig_time)" | bc`
    orig_time=`echo "scale=2;($orig_time/1000)" | bc`
    opt_time=`echo "scale=2;($opt_time/1000)" | bc`
    opt_cycles_time=`echo "scale=2;($opt_cycles_time/1000)" | bc`
    echo -e "\n============= $bench ================" | tee -a $PERF_LOG_FILE
    echo "Orig runtime: $orig_time ms" | tee -a $PERF_LOG_FILE
    echo "Opt runtime: $opt_time ms" | tee -a $PERF_LOG_FILE
    echo "Opt-Int runtime: $opt_cycles_time" | tee -a $PERF_LOG_FILE
    echo "Opt overhead: $slowdown_opt %" | tee -a $PERF_LOG_FILE
    echo "Opt-Int overhead: $slowdown_opt_cycles %" | tee -a $PERF_LOG_FILE
  done
}

check_intv_opt() {
  echo "************************* ACC BENCHMARKS *****************************" >> $DEBUG_FILE
  echo "Percentile-wise intervals (in cycles)" | tee -a $ACC_LOG_FILE
  for bench in "$@"
  do
    build_phoenix_ci_opt_intv_accuracy $bench
    get_accuracy $bench "ci"
    build_phoenix_ci_opt_cycles_intv_accuracy $bench
    get_accuracy $bench "ci-cycles"
  done
}

take_bench() {
  check_intv_opt $@ # for interval stats
  check_perf_opt $@
  test_phoenix_output $@
}

mkdir -p $DIR
rm -f $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE $ACC_LOG_FILE $PERF_LOG_FILE
if [ $# -eq 0 ]; then
  take_bench reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
else
  take_bench $@
fi
