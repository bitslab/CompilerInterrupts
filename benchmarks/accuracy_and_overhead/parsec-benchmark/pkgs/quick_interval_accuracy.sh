#!/bin/bash
CI=1000
PI="${PI:-5000}"
AD=100
CUR_PATH=`pwd`
THREAD="${THREAD:-1}"
SUB_DIR="${SUB_DIR:-""}"
SUB_DIR=${SUB_DIR}_th${THREAD}
DIR=$CUR_PATH/parsec_stats/$SUB_DIR
WRITE_DIR=/local_home/nilanjana/temp/$SUB_DIR
CLOCK=1 #0 - predictive, 1 - instantaneous
CYCLE="${CYCLE:-5000}"

LOG_FILE="$DIR/perf_logs-$AD.txt"
DEBUG_FILE="$DIR/perf_debug-$AD.txt"
BUILD_ERROR_FILE="$DIR/perf_test_build_error-$AD.txt"
BUILD_DEBUG_FILE="$DIR/perf_test_build_log-$AD.txt"

dry_run() {
  case "$1" in
    blackscholes)
      cd blackscholes/src > /dev/null
      ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > /dev/null 2>&1
      echo "./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    fluidanimate)
      cd fluidanimate/src > /dev/null
      ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > /dev/null 2>&1
      echo "./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    swaptions)
      cd swaptions/src > /dev/null
      ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > /dev/null 2>&1
      echo "./swaptions$suffix -ns 128 -sm 100000 -nt $threads > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    canneal)
      cd canneal/src > /dev/null
      ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > /dev/null 2>&1
      echo "./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    dedup)
      cd dedup/src > /dev/null
      ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > /dev/null 2>&1
      echo "./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    streamcluster)
      cd streamcluster/src > /dev/null
      ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > /dev/null 2>&1 
      echo "./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
  esac
  cd - > /dev/null
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
emit_interval_stats() {
  threads=$THREAD
  suffix="_ci"
  OUT_DIR="/local_home/nilanjana/temp/interval_stats/"
  OUT_FILE="$WRITE_DIR/tmp"
  OUT_STAT_FILE="$WRITE_DIR/${file_prefix}_$1_lc_ic_vs_tsc"
  rm -f $OUT_DIR/*
  rm -f $OUT_FILE
  dry_run $1

  echo "Exporting $1 interval statistics to $OUT_FILE"

  case "$1" in
    blackscholes)
      cd blackscholes/src > /dev/null
      ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE
      echo "./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    fluidanimate)
      cd fluidanimate/src > /dev/null
      ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE
      echo "./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    swaptions)
      cd swaptions/src > /dev/null
      ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > $OUT_FILE
      echo "./swaptions$suffix -ns 128 -sm 100000 -nt $threads > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    canneal)
      cd canneal/src > /dev/null
      ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > $OUT_FILE
      echo "./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    dedup)
      cd dedup/src > /dev/null
      ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE
      echo "./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    streamcluster)
      cd streamcluster/src > /dev/null
      ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > $OUT_FILE
      echo "./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
  esac

  cd $OUT_DIR
  ls
  for file in interval_stats_thread*.txt
  do
    thr_no=`echo $file | grep -o '[0-9]\+'`
    new_name=$OUT_STAT_FILE"_thread"$thr_no".txt"
    mv $file $new_name
    echo "Generated $new_name"
  done
  cd -
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

  for bench in $*
  do
    BENCH_DIR=""
    case "$bench" in
    "canneal" | "dedup" | "streamcluster")
      BENCH_DIR="kernels/"
      ;;
    *)
      BENCH_DIR="apps/"
      ;;
    esac

    cd $BENCH_DIR

    # open this
#if [ 0 -eq 1 ]; then

    PI=5000
    AD=100

    if [ 0 -eq 1 ]; then
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$NAIVE PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
      file_prefix="naive-pi${PI}_ecc${AD}"
      emit_interval_stats $bench
    fi

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$NAIVE_TL PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
    file_prefix="naive-tl-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    if [ 0 -eq 1 ]; then
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$OPT PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
      file_prefix="opt-pi${PI}_ecc${AD}"
      emit_interval_stats $bench
    fi

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$OPT_TL PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
    file_prefix="opt-tl-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    if [ 0 -eq 1 ]; then
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$CD PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
      file_prefix="cd-pi${PI}_ecc${AD}"
      emit_interval_stats $bench
    fi

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$CD_TL PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
    file_prefix="cd-tl-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    PI=100
    AD=1

    if [ 0 -eq 1 ]; then
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEGACY PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
      file_prefix="legacy-pi${PI}_ecc${AD}"
      emit_interval_stats $bench
    fi

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEGACY_TL PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
    file_prefix="legacy-tl-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    # remove this
#fi

    PI=1000
    AD=0

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEGACY_ACC PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
    file_prefix="legacy-acc-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    PI=5000
    AD=0

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$OPT_ACC PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
    file_prefix="opt-acc-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$NAIVE_ACC PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
    file_prefix="naive-acc-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEGACY_ACC PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
    file_prefix="legacy-acc-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    cd ../ > /dev/null
  done
}

process_file() {

  return
  infile="$WRITE_DIR/${file_prefix}_$1_lc_ic_vs_tsc.txt"
  old_records=`awk 'END {print NR-1}' $infile`
  sed -i '/[^0-9 ]/d' $infile
  awk 'NF==4' $infile > tmp
  mv tmp $infile
  new_records=`awk 'END {print NR-1}' $infile`
  echo "$1: #old_records: $old_records, #new_records: $new_records" | tee -a $DEBUG_FILE
}

convert() {
  return
  config=$1
  b=$2

  #key_pos: 2 for IR inst count, 3 for time stamp, 4 for retired inst count
  if [ $config -eq 1 ]; then
    key_pos=2
    suffix="_ic"
  elif [ $config -eq 2 ]; then
    key_pos=3
    suffix="_ret_ic"
  elif [ $config -eq 3 ]; then
    key_pos=4
    suffix="_tsc"
  fi

  infile="$WRITE_DIR/${file_prefix}_${b}_lc_ic_vs_tsc.txt"
  outfile="$WRITE_DIR/${file_prefix}_cdf-${b}${suffix}.txt"
  echo "Converting $infile to cdf format in $outfile" | tee -a $DEBUG_FILE

  total_records=`cat $infile | awk 'END {print NR-1}'`
  echo "#records for $b: $total_records" | tee -a $DEBUG_FILE
  cat $infile | tail --lines=+2 | sort -n -k $key_pos | awk -v records=$total_records -v key=$key_pos '{print NR/records, $key}' > $outfile
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

ci_interval_test() {
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
    BENCH_DIR=""
    case "$bench" in
    "canneal" | "dedup" | "streamcluster")
      BENCH_DIR="kernels/"
      ;;
    *)
      BENCH_DIR="apps/"
      ;;
    esac

    PI=$(read_tune_param $bench $CI_SETTING $THREAD)
    cd $BENCH_DIR

    CI=`echo "scale=0; $PI/5" | bc`
    echo "Using interval PI:$PI, CI:$CI, ECC:$AD for $bench" | tee -a $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
    #BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING -DRUNNING_MEDIAN" make -f Makefile.ci ${bench} 
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
    file_prefix="${ci_type}-tuned-th$THREAD"
    emit_interval_stats $bench

    cd ../ > /dev/null
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

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
#perf_test blackscholes fluidanimate swaptions canneal dedup streamcluster 
#settings_list="6 12 13"
#settings_list="9 11 8 2 4 10"
#settings_list="12 13"
#settings_list="8 12 13 2 4 10 6"
#settings_list="8 12 2 4 10 6"
#settings_list="2 4 6 10 8 12 13 17"
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

BENCH="blackscholes fluidanimate swaptions canneal streamcluster dedup"
rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Allowed deviation: $AD, Threads: 1"
echo "Usage: ./experiment_interval_accuracy.sh <nothing / space separated list of parsec benchmarks>"
mkdir -p $DIR
mkdir -p $WRITE_DIR
if [ $# -eq 0 ]; then
  run_perf_test
else
  run_perf_test $@
fi

rm -f $OUT_FILE $SUM_FILE
echo "Copy test-suite/process_data.sh to $WRITE_DIR (for each thread count). Edit process_data.sh to change the set of benchmarks tested, & the CI configurations used. Run ./process_data <threads>. Copy *.s100 to plot directory."
