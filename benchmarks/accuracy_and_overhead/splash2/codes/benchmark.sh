#!/bin/bash
CI=1000
PI="${PI:-5000}"
RUNS="${RUNS:-1}"
AD=100
CUR_PATH=`pwd`
BENCH_NAME="splash2"
SUB_DIR="${SUB_DIR:-"benchmarks"}"
DIR=$CUR_PATH/splash2_stats/$SUB_DIR
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
      echo "Wrong CI Type $2"
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

# unused functionality
read_rpc_tune_param() {
  case "$2" in
    12) ci_type="opt-int";;
    13) ci_type="naive-int";;
    *)
      echo "Wrong CI Type $2"
      exit
    ;;
  esac
  if [ $2 -eq 8 ]; then
    intv=5000
  else
    tune_file="../${ci_type}-rpc-tuning-th1-${CYCLE}.txt"
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
    suffix="orig"
  else
    suffix="lc"
  fi

  case "$1" in
    water-nsquared)
      command="cd water-nsquared; $prefix ./water-nsquared-$suffix < input.$threads > $OUT_FILE; sleep 0.5"
    ;;
    water-spatial)
      command="cd water-spatial; $prefix ./water-spatial-$suffix < input.$threads > $OUT_FILE; sleep 0.5"
    ;;
    ocean-cp) 
      command="cd ocean/contiguous_partitions; $prefix ./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > $OUT_FILE"
    ;;
    ocean-ncp) 
      command="cd ocean/non_contiguous_partitions; $prefix ./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > $OUT_FILE"
    ;;
    barnes)
      command="cd barnes; $prefix ./barnes-$suffix < input.$threads > $OUT_FILE"
    ;;
    volrend)
      command="cd volrend; $prefix ./volrend-$suffix $threads inputs/head > $OUT_FILE"
    ;;
    fmm)
      command="cd fmm; $prefix ./fmm-$suffix < inputs/input.65535.$threads > $OUT_FILE"
    ;;
    raytrace)
      command="cd raytrace; $prefix ./raytrace-$suffix -p $threads -m72 inputs/balls4.env > $OUT_FILE"
    ;;
    radiosity)
      command="cd radiosity; $prefix ./radiosity-$suffix -p $threads -batch -largeroom > $OUT_FILE"
    ;;
    radix)
      command="cd radix; $prefix ./radix-$suffix -p$threads -n134217728 -r1024 -m524288 > $OUT_FILE"
    ;;
    fft)
      command="cd fft; $prefix ./fft-$suffix -m24 -p$threads -n1048576 -l4 > $OUT_FILE"
    ;;
    lu-c)
      command="cd lu/contiguous_blocks; $prefix ./lu-c-$suffix -n4096 -p$threads -b16 > $OUT_FILE"
    ;;
    lu-nc)
      command="cd lu/non_contiguous_blocks; $prefix ./lu-nc-$suffix -n2048 -p$threads -b16 > $OUT_FILE"
    ;;
    cholesky)
      command="cd cholesky; $prefix ./cholesky-$suffix -p$threads -B32 -C1024 inputs/tk29.O > $OUT_FILE"
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

build_splash2_orig() {
  #run original 
  echo "Building original program for $1: " | tee -a $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $1 
  #make -f Makefile.orig clean; make -f Makefile.orig
}

build_splash2_ci_opt() {
  #run periodic
  CI_SETTING=2
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building $1 with CI_SETTING:$CI_SETTING (opt), PI:$PI, CI:$CI, RPC: $RPC, AD:$AD" | tee -a $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI FIBER_CONFIG=$RPC CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $1 
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $1
}

build_splash2_ci_opt_cycles() {
  #run periodic
  CI_SETTING=12
  PI=$(read_tune_param $1 $CI_SETTING)
  #RPC=$(read_rpc_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building $1 with CI_SETTING:$CI_SETTING (opt-int), PI:$PI, CI:$CI, RPC: $RPC, AD:$AD" | tee -a $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI FIBER_CONFIG=$RPC CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $1 
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $1
}

build_splash2_ci_opt_intv_accuracy() {
  #build periodic with interval stats
  CI_SETTING=2
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo -e "\nAccuracy benchmark for $1 with CI_SETTING:$CI_SETTING (opt), PI:$PI, CI:$CI, RPC: $RPC, AD:$AD" | tee -a $DEBUG_FILE $ACC_LOG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI FIBER_CONFIG=$RPC CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $1
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $1
}

build_splash2_ci_opt_cycles_intv_accuracy() {
  #build periodic with interval stats
  CI_SETTING=12
  PI=$(read_tune_param $1 $CI_SETTING)
  #RPC=$(read_rpc_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo -e "\nAccuracy benchmark for $1 with CI_SETTING:$CI_SETTING (opt-int), PI:$PI, CI:$CI, RPC: $RPC, AD:$AD" | tee -a $DEBUG_FILE $ACC_LOG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI FIBER_CONFIG=$RPC CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $1
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $1
}

# log to check output & see if the transformations led to erroneous program flow
test_splash2_output() {
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
    "radix" | "fft" | "lu-c" | "lu-nc" | "cholesky")
      BENCH_DIR="kernels"
      ;;
    *)
      BENCH_DIR="apps"
      ;;
    esac
    
    # For Orig
    cd $BENCH_DIR > /dev/null

    echo "Running (for time) $bench with $thread thread(s)" | tee -a $OUTPUT_ORIG_FILE
    build_splash2_orig $bench > /dev/null
    command=$(run_program $bench $thread 0)
    eval $command
    cat $OUT_FILE | tee -a $OUTPUT_ORIG_FILE $ALL_ORIG_OUT > /dev/null

    cd - > /dev/null
    cd ../ > /dev/null

    # For CI
    cd $BENCH_DIR > /dev/null

    echo "Running (for time) $bench with $thread thread(s)" | tee -a $OUTPUT_CI_FILE
    build_splash2_ci_opt $bench > /dev/null
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
    "radix" | "fft" | "lu-c" | "lu-nc" | "cholesky")
      BENCH_DIR="kernels"
      ;;
    *)
      BENCH_DIR="apps"
      ;;
    esac
    cd $BENCH_DIR
    build_splash2_orig $bench
    orig_time=$(get_time $bench 0 1)
    build_splash2_ci_opt $bench
    opt_time=$(get_time $bench 1 1)
    build_splash2_ci_opt_cycles $bench
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
  echo "************************* ACC BENCHMARKS *****************************" >> $DEBUG_FILE
  echo "Percentile-wise intervals (in cycles)" | tee -a $ACC_LOG_FILE
  for bench in "$@"
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
    build_splash2_ci_opt_intv_accuracy $bench
    get_accuracy $bench 1 "ci"
    build_splash2_ci_opt_cycles_intv_accuracy $bench
    get_accuracy $bench 1 "ci-cycles"
    cd .. > /dev/null
  done
}

take_bench() {
  check_intv_opt $@
  check_perf_opt $@
  test_splash2_output $@
}

mkdir -p $DIR
rm -f $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE $ACC_LOG_FILE $PERF_LOG_FILE
#cd kernels/; get_accuracy fft 1 "ci-cycles"; cd ../
#exit

if [ $# -eq 0 ]; then
  take_bench water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity radix fft lu-c lu-nc cholesky
else
  take_bench $@
fi
