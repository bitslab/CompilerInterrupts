#!/bin/bash
AD=100
CYCLE=5000
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-"instrumentation_stats"}"
DIR=$CUR_PATH/parsec_stats/$SUB_DIR
OUT_FILE="out"
THREADS="${THREADS:-"1 32"}"
DEBUG_FILE="$DIR/command_log.txt"
RUN_STAT_FILE="$DIR/run_stats"
INSTR_STAT_FILE="$DIR/instr_stats"

get_ci_str() {
  case "$1" in
    2) ci_type="CI";;
    4) ci_type="Naive";;
    6) ci_type="Coredet";;
    8) ci_type="legacy-acc";;
    9) ci_type="opt-acc";;
    10) ci_type="CnB";;
    11) ci_type="naive-acc";;
    12) ci_type="CI-cycles";;
    13) ci_type="Naive-cycles";;
    *)
      echo "Wrong CI Type $1"
      exit
    ;;
  esac
  echo $ci_type
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

run_program() {
  th=$2
  suffix_conf=$3
  prefix="timeout 5m "

  declare suffix
  if [ $suffix_conf -eq 0 ]; then
    suffix="_llvm"
  else
    suffix="_ci"
  fi

  case "$1" in
    blackscholes)
      command="cd blackscholes/src; $prefix ./blackscholes$suffix $th ../inputs/in_64K.txt prices.txt > $OUT_FILE; sleep 0.5"
    ;;
    fluidanimate)
      command="cd fluidanimate/src; $prefix ./fluidanimate$suffix $th 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE; sleep 0.5"
    ;;
    swaptions)
      command="cd swaptions/src; $prefix ./swaptions$suffix -ns 128 -sm 100000 -nt $th > $OUT_FILE 2>&1; sleep 0.5" 
    ;;
    canneal)
      command="cd canneal/src; $prefix ./canneal$suffix $th 15000 2000 ../inputs/200000.nets 6000 > $OUT_FILE; sleep 0.5"
    ;;
    dedup)
      command="cd dedup/src; $prefix ./dedup$suffix -c -p -v -t $th -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE; sleep 0.5" 
    ;;
    streamcluster)
      command="cd streamcluster/src; $prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $th > $OUT_FILE; sleep 0.5" 
    ;;
  esac

  echo -e "Command for $1 running $th threads:-\n$command" >> $DEBUG_FILE
  echo $command
}

run_all() {
  thrds="1 32"
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

    for thrd in $thrds
    do
      cd $BENCH_DIR
      command=$(run_program $bench $thrd 1)
      echo "$command"
      eval $command
      mv $OUT_FILE $DIR/${bench}_output
      cd - > /dev/null
      cd .. > /dev/null
    done
  done
}

check_probes() {
  infile=$1
  outfile=$RUN_STAT_FILE
  bench=$2
  ci_setting=$3
  th=$4
  echo -ne "$bench\t$ci_setting\t$th\t" | tee -a $outfile
  if [ "$bench" != "lu-c" ] && [ "$bench" != "lu-nc" ]; then
    grep Probe $infile \
      | grep -v main \
      | cut -d":" -f2 \
      | awk '{cnt+=$1} END {print cnt}' | tee -a $outfile
  else
    grep Probe $infile \
      | cut -d":" -f2 \
      | awk '{cnt+=$1} END {print cnt}' | tee -a $outfile
  fi
}

run_ci() {
  bench=$1
  ci_setting=$2
  thrd=$3
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
  command=$(run_program $bench $thrd 1)
  echo "$command"
  eval $command
  mv $OUT_FILE $DIR/${bench}_ci${ci_setting}_th${thrd}_output
  #check_probes $DIR/${bench}_ci${ci_setting}_th${thrd}_output $bench $ci_setting $thrd
  cd - > /dev/null
  cd .. > /dev/null
}

build_ci() {
  #run periodic
  AD=100
  BENCH=$1
  CI_SETTING=$2
  THREAD=$3
  BUILD_DEBUG_FILE="${BENCH}_ci${CI_SETTING}_th${THREAD}_make_log"
  BUILD_ERROR_FILE="${BENCH}_ci${CI_SETTING}_th${THREAD}_make_err"
  rm -f $BUILD_DEBUG_FILE $BUILD_ERROR_FILE
  PI=$(read_tune_param $BENCH $CI_SETTING $THREAD)
  CI=`echo "scale=0; $PI/5" | bc`
  echo "Building for CI Type $CI_SETTING program for $BENCH with PI:$PI, CI:$CI for $THREAD thread(s): " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${BENCH}-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.ci $BENCH
  #make -f Makefile.ci $1-clean; ALLOWED_DEVIATION=100 CLOCK_TYPE=1 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS" make -f Makefile.ci $1
}

build_n_run() {
  threads="1 32"
  ci_settings="2 12 4 6 10"
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
    for ci_setting in $ci_settings
    do
      for thread in $threads
      do
        cd $BENCH_DIR
        echo "Building $bench"
        build_ci $bench $ci_setting $thread
        cd .. > /dev/null

        run_ci $bench $ci_setting $thread
        mv $BENCH_DIR/$BUILD_DEBUG_FILE $BENCH_DIR/$BUILD_ERROR_FILE $DIR
      done
    done
  done
}

build() {
#threads="1 32"
#ci_settings="2 12 4 6 10"
  threads="1"
  ci_settings="2 4"
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
    for ci_setting in $ci_settings
    do
      for thread in $threads
      do
        cd $BENCH_DIR
        echo "Building $bench"
        build_ci $bench $ci_setting $thread
        mv $BUILD_DEBUG_FILE $BUILD_ERROR_FILE $DIR
        cd .. > /dev/null
      done
    done
  done
}

create_instr_stat_file() {
  threads="1"
  ci_settings="2 4"
  benches="blackscholes fluidanimate swaptions canneal streamcluster dedup"
  rm -f $INSTR_STAT_FILE
  for bench in $benches; do
    echo "*************** Application: $bench ***************" | tee -a $INSTR_STAT_FILE
    for ci_setting in $ci_settings; do
      for th in $threads; do
        BUILD_STATS_FILE="$DIR/${bench}_ci${ci_setting}_th${th}_make_err"
        if [ $ci_setting -eq 2 ]; then
          echo "******* CI stats *******" | tee -a $INSTR_STAT_FILE
          grep "total instrumentations" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "total rule1" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "total rule2" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "total rule3" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "total coredet" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "total self loop" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "total generic loop" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "Total optimization of function costs" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
        else
          echo "******* Naive stats *******" | tee -a $INSTR_STAT_FILE
          grep "total instrumentations" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
        fi
      done
    done
  done
  cat $INSTR_STAT_FILE
}

create_stat_file() {
  threads="1 32"
  ci_settings="2 12 4 6 10"
  benches="blackscholes fluidanimate swaptions canneal streamcluster dedup"
  cp $RUN_STAT_FILE $DIR/run_stat_backup
  echo -e "Application\tCI-Type\tThread(s)\t#Probes" > $RUN_STAT_FILE
  for bench in $benches; do
    for ci_setting in $ci_settings; do
      for th in $threads; do
        check_probes $DIR/${bench}_ci${ci_setting}_th${th}_output $bench $ci_setting $th
      done
    done
  done
  cat $RUN_STAT_FILE
}

summarize() {
  threads="1 32"
  ci_settings="2 12 6 10"
  benches="blackscholes fluidanimate swaptions canneal streamcluster dedup"
  naive_setting="4"
  RUN_STAT_FILE_MOD=$DIR"/run_stats_mod"

  echo -e "Application\tCI-Type\tThread(s)\t#Probes\t%Probes" | tee $RUN_STAT_FILE_MOD
  for bench in $benches; do
    for ci_setting in $ci_settings; do
      for th in $threads; do
        baseline=`grep $bench $RUN_STAT_FILE | grep -w $naive_setting | grep -w $th | awk '{print $4}'`
        ci_str=$(get_ci_str $ci_setting)
        grep $bench $RUN_STAT_FILE | grep -w $ci_setting | grep -w $th | awk -v name=$ci_str -v base=$baseline '{printf("%s\t%s\t%d\t%.2f\n", $1, name, $3, $4*100/base);}' \
        | tee -a $RUN_STAT_FILE_MOD
#grep $bench $RUN_STAT_FILE | grep -w $ci_setting | grep -w $th | awk -v base=$baseline '{printf("\t%.2f\n",$4*100/base)}' | tee -a $RUN_STAT_FILE_MOD
      done
    done
  done
}

create_png() {
  benches="blackscholes fluidanimate swaptions canneal streamcluster dedup"
  for bench in $benches
  do
    BENCH_DIR=""
    case "$bench" in
    "canneal" | "dedup" | "streamcluster")
      BENCH_DIR="kernels/$bench"
      ;;
    *)
      BENCH_DIR="apps/$bench"
      ;;
    esac
    cp ../../create_cfg_png.sh $BENCH_DIR
    pushd $BENCH_DIR
    ./create_cfg_png.sh opt_simplified.ll
    popd
  done
}

# only for documenting
OPT_LOCAL=1
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

benches="blackscholes fluidanimate swaptions canneal streamcluster dedup"
#create_stat_file
#summarize
#create_instr_stat_file
#create_png
#exit

mkdir -p $DIR
rm -f $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE $LOG_FILE
if [ $# -eq 0 ]; then
#build $benches
  build_n_run $benches
else
#build $@
  build_n_run $@
fi

#create_instr_stat_file
#create_stat_file
#summarize

