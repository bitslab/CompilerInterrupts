#!/bin/bash
CI=1000
PI="${PI:-5000}"
RUNS="${RUNS:-1}"
AD=100
CUR_PATH=`pwd`
BENCH_NAME="parsec"
SUB_DIR="${SUB_DIR:-"benchmarks"}"
DIR=$CUR_PATH/parsec_stats/$SUB_DIR
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
      echo "Wrong CI Type"
      exit
    ;;
  esac
  if [ $2 -eq 8 ]; then
    intv=5000
  else
    tune_file="../${ci_type}-tuning-th1-${CYCLE}.txt"
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
  threads=$2
  suffix_conf=$3
  prefix="timeout 5m taskset 0x00000001 "

  declare suffix
  if [ $suffix_conf -eq 0 ]; then
    suffix="_llvm"
  else
    suffix="_ci"
  fi

  case "$1" in
    blackscholes)
      command="cd blackscholes/src; $prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE; sleep 0.5"
    ;;
    fluidanimate)
      command="cd fluidanimate/src; $prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE; sleep 0.5"
    ;;
    swaptions)
      command="cd swaptions/src; $prefix ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > $OUT_FILE 2>&1; sleep 0.5" 
    ;;
    canneal)
      command="cd canneal/src; $prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > $OUT_FILE; sleep 0.5"
    ;;
    dedup)
      command="cd dedup/src; $prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE; sleep 0.5" 
    ;;
    streamcluster)
      command="cd streamcluster/src; $prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > $OUT_FILE; sleep 0.5" 
    ;;
  esac

  echo -e "Command for $1 running $th threads:-\n$command" >> $DEBUG_FILE
  echo $command
}

get_time() {
  echo "Running (for time) $1 with $3 thread(s)" >> $DEBUG_FILE
  command=$(run_program $1 $3 $2)
  eval $command > /dev/null; cd - > /dev/null #dry run
  eval $command
  time_in_us=`cat $OUT_FILE | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
  echo "Duration: $time_in_us us" >> $DEBUG_FILE
  cd - > /dev/null
  echo $time_in_us
}

get_accuracy() {
  echo "Running (for interval stats) $1 with 1 thread" | tee -a $DEBUG_FILE
  rm -f /local_home/nilanjana/temp/interval_stats/interval_stats_thread*.txt 
  cdf_name="$1-$3.cdf"
  sample_name="$1-$3.s100"
  pc_name="$1-$3.pc"

  # run command
  command=$(run_program $1 1 $2)
  eval $command > /dev/null; cd - > /dev/null #dry run
  eval $command
  cd -
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

build_parsec_orig() {
  #run original 
  echo "Building original program for $1: " | tee -a $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.llvm $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.llvm $1 
  #make -f Makefile.orig clean; make -f Makefile.orig
}

build_parsec_ci_opt() {
  #run periodic
  CI_SETTING=2
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building $1 with CI_SETTING:$CI_SETTING (opt), PI:$PI, CI:$CI, RPC: $RPC, AD:$AD" | tee -a $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI FIBER_CONFIG=$RPC CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING PROFILE_FLAGS="-DAVG_STATS" make -f Makefile.ci $1 
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $1
}

build_parsec_ci_opt_cycles() {
  #run periodic
  CI_SETTING=12
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building $1 with CI_SETTING:$CI_SETTING (opt-int), PI:$PI, CI:$CI, RPC: $RPC, AD:$AD" | tee -a $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI FIBER_CONFIG=$RPC CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING PROFILE_FLAGS="-DAVG_STATS" make -f Makefile.ci $1 
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $1
}

build_parsec_ci_opt_intv_accuracy() {
  #build periodic with interval stats
  CI_SETTING=2
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo -e "\nAccuracy benchmark for $1 with CI_SETTING:$CI_SETTING (opt), PI:$PI, CI:$CI, RPC: $RPC, AD:$AD" | tee -a $DEBUG_FILE $ACC_LOG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI FIBER_CONFIG=$RPC CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci $1
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $1
}

build_parsec_ci_opt_cycles_intv_accuracy() {
  #build periodic with interval stats
  CI_SETTING=12
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo -e "\nAccuracy benchmark for $1 with CI_SETTING:$CI_SETTING (opt-int), PI:$PI, CI:$CI, RPC: $RPC, AD:$AD" | tee -a $DEBUG_FILE $ACC_LOG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI FIBER_CONFIG=$RPC CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci $1
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $1
}

# log to check output & see if the transformations led to erroneous program flow
test_parsec_output() {
  echo "************************* OUTPUT CHECKS *****************************" >> $DEBUG_FILE
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
    BENCH_DIR=""
    case "$bench" in
    "canneal" | "dedup" | "streamcluster")
      BENCH_DIR="kernels"
      ;;
    *)
      BENCH_DIR="apps"
      ;;
    esac

    # For Orig
    cd $BENCH_DIR > /dev/null

    echo "Running (for time) $bench with $thread thread(s)" | tee -a $OUTPUT_ORIG_FILE
    build_parsec_orig $bench > /dev/null
    command=$(run_program $bench $thread 0)
    eval $command
    cat $OUT_FILE | tee -a $OUTPUT_ORIG_FILE $ALL_ORIG_OUT > /dev/null

    cd - > /dev/null
    cd ../ > /dev/null

    # For CI
    cd $BENCH_DIR > /dev/null

    echo "Running (for time) $bench with $thread thread(s)" | tee -a $OUTPUT_CI_FILE
    build_parsec_ci_opt $bench > /dev/null
    command=$(run_program $bench $thread 1)
    eval $command
    cat $OUT_FILE | tee -a $OUTPUT_CI_FILE $ALL_CI_OUT > /dev/null

    cd - > /dev/null
    cd ../ > /dev/null

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
    build_parsec_orig $bench
    orig_time=$(get_time $bench 0 1)
    build_parsec_ci_opt $bench
    opt_time=$(get_time $bench 1 1)
    build_parsec_ci_opt_cycles $bench
    opt_cycles_time=$(get_time $bench 1 1)

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
    cd .. > /dev/null
  done
}

check_intv_opt() {
  for bench in "$@"
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
    build_parsec_ci_opt_intv_accuracy $bench
    get_accuracy $bench 1 "ci"
    build_parsec_ci_opt_cycles_intv_accuracy $bench
    get_accuracy $bench 1 "ci-cycles"
    cd .. > /dev/null
  done
}

take_bench() {
  check_intv_opt $@
  check_perf_opt $@
  test_parsec_output $@
}

mkdir -p $DIR
rm -f $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE $ACC_LOG_FILE $PERF_LOG_FILE
if [ $# -eq 0 ]; then
  take_bench canneal fluidanimate swaptions dedup streamcluster blackscholes 
else
  take_bench $@
fi
