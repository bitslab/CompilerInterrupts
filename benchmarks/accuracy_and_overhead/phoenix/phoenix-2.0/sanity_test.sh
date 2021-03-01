#!/bin/bash
CI=1000
PI="${PI:-5000}"
CI=1000
RUNS="${RUNS:-1}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-"sanity_test"}"
DIR=$CUR_PATH/phoenix_stats/$SUB_DIR
THREADS="${THREADS:-"1 32"}"
LOG_FILE="$DIR/perf_log.txt"
DEBUG_FILE="$DIR/perf_debug-ad$AD.txt"
BUILD_ERROR_FILE="$DIR/perf_test_build_error-ad$AD.txt"
BUILD_DEBUG_FILE="$DIR/perf_test_build_log-ad$AD.txt"
OUT_FILE="out"
CYCLE="${CYCLE:-5000}"

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
    tune_file="./${ci_type}-tuning-${CYCLE}.txt"
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

run_phoenix_output() {
  thread=1
  rm -f $OUTPUT_FILE
  for bench in "$@"
  do
    echo "Running (for time) $bench with $thread thread(s)" | tee -a $OUTPUT_FILE $LOG_FILE
    command=$(run_program $bench $thread)
    eval $command
    cat $OUT_FILE >> $OUTPUT_FILE
  done
}

run_phoenix_for_time() {
  for bench in "$@"
  do
    for thread in $THREADS
    do
      echo "Running (for time) $bench with $thread thread(s)" | tee -a $DEBUG_FILE
      command=$(run_program $bench $thread)
      eval $command
      time_in_us=`cat $OUT_FILE | grep "$bench runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
      echo "Duration: $time_in_us us" | tee -a $DEBUG_FILE
    done
  done
}

get_time() {
  echo "Running (for time) $1 with $2 thread(s)" >> $DEBUG_FILE
  command=$(run_program $1 $2)
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

  echo "Percentile-wise intervals (in cycles) for $1:"
  cat ./$pc_name
  
  cd - > /dev/null
}

run_phoenix_for_time_n_avg_ic() {
  for bench in "$@"
  do
    for thread in $THREADS
    do
      echo "Running (for time & avg_ic) $bench with $thread thread(s)" | tee -a $DEBUG_FILE
      command=$(run_program $bench $thread)
      eval $command
      time_in_us=`cat $OUT_FILE | grep "$bench runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
      avg_ic=`cat $OUT_FILE | grep "avg_intv_ic"`
      echo "Duration: $time_in_us us" | tee -a $DEBUG_FILE
      echo -e "Average IC:-\n$avg_ic" | tee -a $DEBUG_FILE
    done
  done
}

run_phoenix_for_time_n_avg_perf_stats() {
  for bench in "$@"
  do
    for thread in $THREADS
    do
      echo "Running (for time & avg perf stats) $bench with $thread thread(s)" | tee -a $DEBUG_FILE
      command=$(run_program $bench $thread)
      eval $command
      time_in_us=`cat $OUT_FILE | grep "$bench runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
      samples=`cat $OUT_FILE | grep "samples"`
      echo "Duration: $time_in_us us" | tee -a $DEBUG_FILE
      echo -e "Average Perf Stats:-\n$samples" | tee -a $DEBUG_FILE
    done
  done
}

run_phoenix_for_intv_stats() {
  for bench in "$@"
  do
    echo "Running (for interval stats) $bench with 1 thread" | tee -a $DEBUG_FILE
    command=$(run_program $bench 1)
    eval $command
    samples=`cat $OUT_FILE | grep "PushSeq"`
    echo -e "No. of threads that ran should have as many of the following lines:-\n$samples" | tee -a $DEBUG_FILE
  done
}

build_phoenix_orig() {
  #run original 
  echo "Building original program: " | tee -a $DEBUG_FILE
  make -f Makefile.orig clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  make -f Makefile.orig >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.orig clean; make -f Makefile.orig
}

build_phoenix_orig_papi() {
  #Build original program with PAPI hardware interrupts
  echo "Building original program with PAPI hardware interrupts(PI: $PI retired instructions) : " | tee -a $DEBUG_FILE
  make -f Makefile.orig clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  EXTRA_FLAGS="-DPAPI -DIC_THRESHOLD=$PI"  make -f Makefile.orig >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.orig clean; EXTRA_FLAGS="-DPAPI -DIC_THRESHOLD=5000"  make -f Makefile.orig
}

build_phoenix_orig_fiber() {
  #Build orig-fiber
  echo "Building orig with fiber program: " | tee -a $DEBUG_FILE
  make -f Makefile.orig.fiber clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  make -f Makefile.orig.fiber >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.orig.fiber clean; make -f Makefile.orig.fiber
}

build_phoenix_ci_naive() {
  #run naive
  echo "Building naive program: " | tee -a $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.lc clean; ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=3 make -f Makefile.lc
}

build_phoenix_ci_opt() {
  #run periodic
  AD=100
  CI_SETTING=2
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building periodic opt program with PI:$PI, CI:$CI: " | tee -a $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.lc clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc
}

build_phoenix_ci_opt_cycles() {
  #run periodic
  AD=100
  CI_SETTING=12
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building periodic opt cycles program with PI:$PI, CI:$CI: " | tee -a $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.lc clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc
}

build_phoenix_ci_opt_perf_cntrs() {
  #Build original program with Periodic CI & perf counting
  echo "Building original program with Periodic CI (PI: $PI IR instructions): " >> $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DPERF_CNTR" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.lc clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DPERF_CNTR" make -f Makefile.lc
}

build_phoenix_ci_opt_intv_accuracy() {
  #build periodic with interval stats
  AD=100
  CI_SETTING=2
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building periodic opt program that prints interval statistics with PI:$PI, CI:$CI: " >> $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.lc clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc
}

build_phoenix_ci_opt_cycles_intv_accuracy() {
  #build periodic with interval stats
  AD=100
  CI_SETTING=12
  PI=$(read_tune_param $1 $CI_SETTING)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building periodic opt cycles program that prints interval statistics with PI:$PI, CI:$CI: " >> $DEBUG_FILE
  make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.lc clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc
}

build_phoenix_ci_opt_fiber() {
  #run fiber-ci
  echo "Building fiber with CI program: " | tee -a $DEBUG_FILE
  make -f Makefile.lc.fiber clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc.fiber >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
  #make -f Makefile.lc.fiber clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.lc.fiber
}

# log to check output & see if the transformations led to erroneous program flow
test_phoenix_perf() {
  thread=1
  OUTPUT_FILE_ORIG="$DIR/perf_orig.txt"
  OUTPUT_FILE_OPT="$DIR/perf_opt.txt"
  OUTPUT_COMP="$DIR/perf_comp.txt"
  OUTPUT_INTV="$DIR/ir_intv.txt"

  rm -f $OUTPUT_FILE_ORIG $OUTPUT_FILE_OPT $OUTPUT_COMP $OUTPUT_INTV
  declare -A res_orig res_opt

  build_phoenix_orig
  echo "Orig" | tee -a $OUTPUT_FILE_ORIG $LOG_FILE
  echo "----------------------------------" | tee -a $LOG_FILE
  for bench in "$@"
  do
    command=$(run_program $bench $thread)
    eval $command
    time_in_us=`cat $OUT_FILE | grep "$bench runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    res_orig[$bench]=$time_in_us
    echo -e "$bench\t$time_in_us" | tee -a $OUTPUT_FILE_ORIG $LOG_FILE
  done
  echo "----------------------------------" | tee -a $LOG_FILE

  build_phoenix_ci_opt
  echo "Opt" | tee -a $OUTPUT_FILE_OPT $LOG_FILE
  echo "----------------------------------" | tee -a $OUTPUT_INTV $LOG_FILE
  echo "IR Interval Stats" > $OUTPUT_INTV
  for bench in "$@"
  do
    command=$(run_program $bench $thread)
    eval $command
    time_in_us=`cat $OUT_FILE | grep "$bench runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    avg_ic=`cat $OUT_FILE | grep "avg_intv_ic"`
    res_opt[$bench]=$time_in_us
    echo -e "$bench\t$time_in_us" | tee -a $OUTPUT_FILE_OPT $LOG_FILE

    echo $bench >> $OUTPUT_INTV
    echo "----------------------------------" >> $OUTPUT_INTV
    echo $avg_ic >> $OUTPUT_INTV
    echo "----------------------------------" >> $OUTPUT_INTV
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
test_phoenix_output() {
  OUTPUT_FILE="$DIR/output_orig.txt"
  build_phoenix_orig
#echo "Writing output for original run" > $OUTPUT_FILE
  run_phoenix_output $@

  OUTPUT_FILE="$DIR/output_opt.txt"
  build_phoenix_ci_opt
#echo "Writing output for opt run" >> $OUTPUT_FILE
  run_phoenix_output $@

  echo "Run \"diff --suppress-common-lines -yiEw $DIR/output_orig.txt $DIR/output_opt.txt\"" | tee -a $LOG_FILE
}

test_phoenix_orig() {
  build_phoenix_orig
  run_phoenix_for_time $@
}

test_phoenix_orig_papi() {
  build_phoenix_orig_papi
  run_phoenix_for_time_n_avg_perf_stats $@
}

test_phoenix_orig_fiber() {
  build_phoenix_orig_fiber
  run_phoenix_for_time $@
}

test_phoenix_naive() {
  build_phoenix_ci_naive
  run_phoenix_for_time_n_avg_ic $@
}

test_phoenix_opt() {
  build_phoenix_ci_opt
  run_phoenix_for_time_n_avg_ic $@
}

check_perf_opt() {
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
    echo "Orig run time for $bench: $orig_time ms"
    echo "Opt run time for $bench: $opt_time ms"
    echo "Opt-Cycles run time for $bench: $opt_cycles_time"
    echo "Runtime overhead for opt: $slowdown_opt %"
    echo "Runtime overhead for opt-cycles: $slowdown_opt_cycles %"
    echo ""
  done
}

check_intv_opt() {
  for bench in "$@"
  do
    build_phoenix_ci_opt_intv_accuracy $bench
    get_accuracy $bench "ci"
    build_phoenix_ci_opt_cycles_intv_accuracy $bench
    get_accuracy $bench "ci-cycles"
  done
}

test_phoenix_opt_perf_cntrs() {
  build_phoenix_ci_opt_perf_cntrs
  run_phoenix_for_time_n_avg_perf_stats $@
}

test_phoenix_opt_intv_accuracy() {
  build_phoenix_ci_opt_intv_accuracy
  run_phoenix_for_intv_stats $@
}

test_phoenix_opt_fiber() {
  build_phoenix_ci_opt_fiber
  run_phoenix_for_time $@
}

sanity_test() {
  check_perf_opt $@
  check_intv_opt $@
  exit
  test_phoenix_orig $@
  test_phoenix_perf $@
  test_phoenix_output $@
  test_phoenix_opt $@
  test_phoenix_naive $@
  test_phoenix_opt $@
  test_phoenix_orig_papi $@ # for papi
  test_phoenix_opt_perf_cntrs $@ # for perf counters
  test_phoenix_opt_intv_accuracy $@ # for interval stats
  test_phoenix_orig_fiber $@ # for fiber
  test_phoenix_opt_fiber $@ # for fiber
}

mkdir -p $DIR
rm -f $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE $LOG_FILE
if [ $# -eq 0 ]; then
  sanity_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
else
  sanity_test $@
fi
