#!/bin/bash
CI=1000
PI="${PI:-5000}"
CI=1000
RUNS="${RUNS:-1}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-"sanity_test"}"
DIR=$CUR_PATH/splash2_stats/$SUB_DIR
THREADS="${THREADS:-"1 32"}"
LOG_FILE="$DIR/perf_log.txt"
DEBUG_FILE="$DIR/perf_debug-ad$AD.txt"
BUILD_ERROR_FILE="$DIR/perf_test_build_error-ad$AD.txt"
BUILD_DEBUG_FILE="$DIR/perf_test_build_log-ad$AD.txt"
TEMP="$DIR/tmp_file"
OUT_FILE="out"
CYCLE=5000
rm -f $TEMP

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
    tune_file="../${ci_type}-tuning-th$3-${CYCLE}.txt"
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

get_time() {
  echo "Running (for time) $1 with $3 thread(s)" >> $DEBUG_FILE
  command=$(run_program $1 $3 $2)
  eval $command
  time_in_us=`cat $OUT_FILE | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
  echo "Duration: $time_in_us us" >> $DEBUG_FILE
  cd - > /dev/null
  echo $time_in_us
}

run_splash2_for_time() {
  for thread in $THREADS
  do
    echo "Running (for time) $1 with $thread thread(s)" | tee -a $DEBUG_FILE
    command=$(run_program $1 $thread $2)
    eval $command
    time_in_us=`cat $OUT_FILE | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    echo "Duration: $time_in_us us" | tee -a $DEBUG_FILE
    cd - > /dev/null
  done
}

run_splash2_for_time_n_avg_ic() {
  for thread in $THREADS
  do
    echo "Running (for time & avg_ic) $1 with $thread thread(s)" | tee -a $DEBUG_FILE
    command=$(run_program $1 $thread $2)
    eval $command;
    time_in_us=`cat $OUT_FILE | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    avg_ic=`cat $OUT_FILE | grep "avg_intv_ic"`
    echo "**************************** Running $1 ******************************" >> $TEMP
    cat $OUT_FILE >> $TEMP
    echo "**************************** Finished Running $1 ******************************" >> $TEMP
    echo "Duration: $time_in_us us" | tee -a $DEBUG_FILE
    echo -e "Average IC:-\n$avg_ic" | tee -a $DEBUG_FILE
    cd - > /dev/null
  done
}

run_splash2_for_time_n_avg_perf_stats() {
  for thread in $THREADS
  do
    echo "Running (for time & avg perf stats) $1 with $thread thread(s)" | tee -a $DEBUG_FILE
    command=$(run_program $1 $thread $2)
    eval $command
    time_in_us=`cat $OUT_FILE | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    samples=`cat $OUT_FILE | grep "samples"`
    echo "Duration: $time_in_us us" | tee -a $DEBUG_FILE
    echo -e "Average Perf Stats:-\n$samples" | tee -a $DEBUG_FILE
    cd - > /dev/null
  done
}

run_splash2_for_intv_stats() {
  echo "Running (for interval stats) $1 with 1 thread" | tee -a $DEBUG_FILE
  command=$(run_program $1 1 $2)
  eval $command
  samples=`cat $OUT_FILE | grep "PushSeq"`
  echo -e "No. of threads that ran should have as many of the following lines:-\n$samples" | tee -a $DEBUG_FILE
  cd - > /dev/null
}

get_accuracy() {
  echo "Running (for interval stats) $1 with 1 thread" | tee -a $DEBUG_FILE
  rm -f /local_home/nilanjana/temp/interval_stats/interval_stats_thread*.txt 
  cdf_name="$1-$3.cdf"
  sample_name="$1-$3.s100"
  pc_name="$1-$3.pc"

  # run command
  command=$(run_program $1 1 $2)
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

  echo "Percentile-wise intervals (in cycles) for $1:"
  cat ./$pc_name
  
  cd - > /dev/null
}

build_splash2_orig() {
  #run original 
  echo "Building original program for $1: " | tee -a $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $1 
  #make -f Makefile.orig clean; make -f Makefile.orig
}

build_splash2_orig_papi() {
  #Build original program with PAPI hardware interrupts
  echo "Building original program for $1 with PAPI hardware interrupts(PI: $PI retired instructions) : " | tee -a $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE EXTRA_FLAGS="-DPAPI -DIC_THRESHOLD=$PI" make -f Makefile.orig $1
  #make -f Makefile.orig $1-clean; EXTRA_FLAGS="-DPAPI -DIC_THRESHOLD=5000"  make -f Makefile.orig $1
}

build_splash2_orig_fiber() {
  #Build orig-fiber
  echo "Building orig with fiber program for $1: " | tee -a $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig.libfiber $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig.libfiber $1 
  #make -f Makefile.orig.fiber $1-clean; make -f Makefile.orig.fiber $1
}

build_splash2_ci_naive() {
  #run naive
  echo "Building naive program for $1: " | tee -a $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $1
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=3 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $1
}

build_splash2_ci_opt() {
  #run periodic
  AD=100
  CI_SETTING=2
  PI=$(read_tune_param $1 $CI_SETTING 1)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building periodic opt program for $1 with PI:$PI, CI:$CI: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $1 
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $1
}

build_splash2_ci_opt_cycles() {
  #run periodic
  AD=100
  CI_SETTING=12
  PI=$(read_tune_param $1 $CI_SETTING 1)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building periodic opt cycles program for $1 with PI:$PI, CI:$CI: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $1 
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc $1
}

build_splash2_ci_opt_perf_cntrs() {
  #Build original program with Periodic CI & perf counting
  echo "Building original program for $1 with Periodic CI (PI: $PI IR instructions): " >> $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DPERF_CNTR" make -f Makefile.lc $1 
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DPERF_CNTR" make -f Makefile.lc $1
}

build_splash2_ci_opt_intv_accuracy() {
  #build periodic with interval stats
  AD=100
  CI_SETTING=2
  PI=$(read_tune_param $1 $CI_SETTING 1)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building periodic opt program for $1 that prints interval statistics with PI:$PI, CI:$CI: " >> $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $1
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $1
}

build_splash2_ci_opt_cycles_intv_accuracy() {
  #build periodic with interval stats
  AD=100
  CI_SETTING=12
  PI=$(read_tune_param $1 $CI_SETTING 1)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building periodic opt cycles program for $1 that prints interval statistics with PI:$PI, CI:$CI: " >> $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $1
  #make -f Makefile.lc $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $1
}

build_splash2_ci_opt_fiber() {
  #run fiber-ci
  echo "Building fiber with CI program for $1: " | tee -a $DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc.libfiber $1-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc.libfiber $1
  #make -f Makefile.lc.fiber $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc.fiber $1
}

test_splash2_perf() {
  thread=1
  OUTPUT_FILE_ORIG="$DIR/perf_orig.txt"
  OUTPUT_FILE_OPT="$DIR/perf_opt.txt"
  OUTPUT_COMP="$DIR/perf_comp.txt"
  OUTPUT_INTV="$DIR/ir_intv.txt"
  declare -A res_orig res_opt

  rm -f $OUTPUT_FILE_ORIG $OUTPUT_FILE_OPT $OUTPUT_COMP $OUTPUT_INTV 

  echo "Orig" | tee -a $OUTPUT_FILE_ORIG $LOG_FILE
  echo "----------------------------------" | tee -a $LOG_FILE
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

    build_splash2_orig $bench > /dev/null
    command=$(run_program $bench $thread 0)
    eval $command
    time_in_us=`cat $OUT_FILE | grep "$bench runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    res_orig[$bench]=$time_in_us
    echo -e "$bench\t$time_in_us" | tee -a $OUTPUT_FILE_ORIG $LOG_FILE

    cd - > /dev/null
    cd ../ > /dev/null
  done
  echo "----------------------------------" | tee -a $LOG_FILE

  echo "Opt" | tee -a $OUTPUT_FILE_OPT $LOG_FILE
  echo "----------------------------------" | tee -a $OUTPUT_INTV $LOG_FILE 
  echo "IR Interval Stats" > $OUTPUT_INTV
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
    cd $BENCH_DIR > /dev/null

    build_splash2_ci_opt $bench > /dev/null
    command=$(run_program $bench $thread 1)
    eval $command
    time_in_us=`cat $OUT_FILE | grep "$bench runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    avg_ic=`cat $OUT_FILE | grep "avg_intv_ic"`
    res_opt[$bench]=$time_in_us
    echo -e "$bench\t$time_in_us" | tee -a $OUTPUT_FILE_OPT $LOG_FILE

    echo $bench >> $OUTPUT_INTV
    echo "----------------------------------" >> $OUTPUT_INTV
    echo $avg_ic >> $OUTPUT_INTV
    echo "----------------------------------" >> $OUTPUT_INTV

    cd - > /dev/null
    cd ../ > /dev/null
  done
  echo "----------------------------------" | tee -a $LOG_FILE

  echo "Comparing orig & opt:-" | tee -a $LOG_FILE
  echo "----------------------------------" | tee -a $LOG_FILE
  echo -e "Benchmark\tSlowdown" | tee -a $LOG_FILE
  for bench in "$@"
  do
    comp=`echo "scale=2;(${res_opt[$bench]}/${res_orig[$bench]})" | bc`
    echo -e "$bench\t$comp" >> $OUTPUT_COMP
    echo "$bench:${comp}x" | tee -a $LOG_FILE
  done
  echo "----------------------------------" | tee -a $LOG_FILE

  cat $OUTPUT_INTV | tee -a $LOG_FILE
}

# log to check output & see if the transformations led to erroneous program flow
test_splash2_output() {
  OUTPUT_FILE="$DIR/output_orig.txt"
  thread=1
  rm -f $OUTPUT_FILE
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
    cd $BENCH_DIR > /dev/null

    echo "Running (for time) $bench with $thread thread(s)" | tee -a $OUTPUT_FILE $LOG_FILE
    build_splash2_orig $bench > /dev/null
    command=$(run_program $bench $thread 0)
    eval $command
    cat $OUT_FILE >> $OUTPUT_FILE

    cd - > /dev/null
    cd ../ > /dev/null
  done

  OUTPUT_FILE="$DIR/output_opt.txt"
  thread=1
  rm -f $OUTPUT_FILE
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
    cd $BENCH_DIR > /dev/null

    echo "Running (for time) $bench with $thread thread(s)" | tee -a $OUTPUT_FILE $LOG_FILE
    build_splash2_ci_opt $bench > /dev/null
    command=$(run_program $bench $thread 1)
    eval $command
    cat $OUT_FILE >> $OUTPUT_FILE

    cd - > /dev/null
    cd ../ > /dev/null
  done

  echo "Run \"diff --suppress-common-lines -yiEw $DIR/output_orig.txt $DIR/output_opt.txt\"" | tee -a $LOG_FILE
}

test_splash2_orig() {
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
    run_splash2_for_time $bench 0
    cd .. > /dev/null
  done
}

test_splash2_orig_papi() {
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
    build_splash2_orig_papi $bench
    run_splash2_for_time_n_avg_perf_stats $bench 0
    cd .. > /dev/null
  done
}

test_splash2_orig_fiber() {
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
    case "$bench" in
    "cholesky" | "barnes" | "volrend" | "fmm" | "radiosity")
      echo "Orig-Fiber configuration does not terminate for $bench" | tee -a $DEBUG_FILE
#continue
      ;;
    esac
    cd $BENCH_DIR
    build_splash2_orig_fiber $bench
    run_splash2_for_time $bench 0
    cd .. > /dev/null
  done
}

test_splash2_naive() {
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
    build_splash2_ci_naive $bench
    run_splash2_for_time_n_avg_ic $bench 1
    cd .. > /dev/null
  done
}

test_splash2_opt() {
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
    build_splash2_ci_opt $bench
    run_splash2_for_time_n_avg_ic $bench 1
    cd .. > /dev/null
  done
}

check_perf_opt() {
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
    echo "Orig run time for $bench: $orig_time ms"
    echo "Opt run time for $bench: $opt_time ms"
    echo "Opt-Cycles run time for $bench: $opt_cycles_time"
    echo "Runtime overhead for opt: $slowdown_opt %"
    echo "Runtime overhead for opt-cycles: $slowdown_opt_cycles %"
    echo ""
    cd .. > /dev/null
  done
}

check_intv_opt() {
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

build_all() {
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
    echo "Building $bench"
    BUILD_DEBUG_FILE="${bench}_make_log"
    BUILD_ERROR_FILE="${bench}_make_err"
    build_splash2_ci_opt_cycles $bench
    #build_splash2_ci_opt $bench
    mv $BUILD_DEBUG_FILE $BUILD_ERROR_FILE $DIR
    cd .. > /dev/null
  done
}

run_all() {
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
    command=$(run_program $bench 1 1)
    echo "$command"
    time eval $command
    mv $OUT_FILE $DIR/${bench}_output
    cd - > /dev/null
    cd .. > /dev/null
  done
}

test_splash2_opt_perf_cntrs() {
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
    build_splash2_ci_opt_perf_cntrs $bench
    run_splash2_for_time_n_avg_perf_stats $bench 1
    cd .. > /dev/null
  done
}

test_splash2_opt_intv_accuracy() {
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
    run_splash2_for_intv_stats $bench 1
    cd .. > /dev/null
  done
}

test_splash2_opt_fiber() {
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
    build_splash2_ci_opt_fiber $bench
    run_splash2_for_time $bench 1
    cd .. > /dev/null
  done
}

sanity_test() {
  build_all $@
  exit
  run_all $@
  check_perf_opt $@
  check_intv_opt $@
  test_splash2_opt $@
  test_splash2_opt_intv_accuracy $@ # for interval stats
  test_splash2_orig $@
  test_splash2_perf $@
  test_splash2_output $@
  test_splash2_naive $@
  test_splash2_orig_papi $@ # for papi
  test_splash2_opt_perf_cntrs $@ # for perf counters
  test_splash2_orig_fiber $@ # for fiber
  test_splash2_orig_fiber $@ # for fiber
  test_splash2_opt_fiber $@ # for fiber
}

mkdir -p $DIR
rm -f $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE $LOG_FILE
if [ $# -eq 0 ]; then
#sanity_test water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity radix fft lu-c lu-nc cholesky
  sanity_test water-nsquared water-spatial ocean-cp ocean-ncp raytrace radix fft lu-c lu-nc radiosity barnes volrend fmm cholesky
else
  sanity_test $@
fi
