#!/bin/bash
CI=1000
PI="${PI:-5000}"
AD=100
CUR_PATH=`pwd`
THREAD="${THREAD:-1}"
SUB_DIR="${SUB_DIR:-""}"
SUB_DIR=${SUB_DIR}_th${THREAD}
DIR=$CUR_PATH/splash2_stats/$SUB_DIR
WRITE_DIR=/local_home/nilanjana/temp/$SUB_DIR
CLOCK=1 #0 - predictive, 1 - instantaneous
CYCLE="${CYCLE:-5000}"

LOG_FILE="$DIR/perf_logs.txt"
DEBUG_FILE="$DIR/perf_debug.txt"
BUILD_ERROR_FILE="$DIR/perf_test_build_error.txt"
BUILD_DEBUG_FILE="$DIR/perf_test_build_log.txt"

dry_run() {
  case "$1" in
    water-nsquared)
      cd water-nsquared > /dev/null
      command="./water-nsquared-$suffix < input.1 > /dev/null 2>&1"
    ;;
    water-spatial)
      cd water-spatial > /dev/null
      command="./water-spatial-$suffix < input.1 > /dev/null 2>&1"
    ;;
    ocean-cp) 
      cd ocean/contiguous_partitions > /dev/null
      command="./ocean-cp-$suffix -n1026 -p 1 -e1e-07 -r2000 -t28800 > /dev/null 2>&1"
    ;;
    ocean-ncp) 
      cd ocean/non_contiguous_partitions > /dev/null
      command="./ocean-ncp-$suffix -n258 -p 1 -e1e-07 -r2000 -t28800 > /dev/null 2>&1"
    ;;
    barnes)
      cd barnes > /dev/null
      command="./barnes-$suffix < input.1 > /dev/null 2>&1"
    ;;
    volrend)
      cd volrend > /dev/null
      command="./volrend-$suffix 1 inputs/head > /dev/null 2>&1"
    ;;
    fmm)
      cd fmm > /dev/null
      command="./fmm-$suffix < inputs/input.65535.1 > /dev/null 2>&1"
    ;;
    raytrace)
      cd raytrace > /dev/null
      command="./raytrace-$suffix -p 1 -m72 inputs/balls4.env > /dev/null 2>&1"
    ;;
    radiosity)
      cd radiosity > /dev/null
      command="./radiosity-$suffix -p 1 -batch -largeroom > /dev/null 2>&1"
    ;;
    radix)
      cd radix > /dev/null
      command="./radix-$suffix -p1 -n134217728 -r1024 -m524288 > /dev/null 2>&1"
    ;;
    fft)
      cd fft > /dev/null
      command="./fft-$suffix -m24 -p1 -n1048576 -l4 > /dev/null 2>&1"
    ;;
    lu-c)
      cd lu/contiguous_blocks > /dev/null
      command="./lu-c-$suffix -n4096 -p1 -b16 > /dev/null 2>&1"
    ;;
    lu-nc)
      cd lu/non_contiguous_blocks > /dev/null
      command="./lu-nc-$suffix -n2048 -p1 -b16 > /dev/null 2>&1"
    ;;
    cholesky)
      cd cholesky > /dev/null
      command="./cholesky-$suffix -p1 -B32 -C1024 inputs/tk29.O > /dev/null 2>&1"
    ;;
  esac
  echo $command >> $DEBUG_FILE
  eval $command
  cd - > /dev/null
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
emit_interval_stats() {
  threads=$THREAD
  suffix="lc"
  OUT_DIR="/local_home/nilanjana/temp/interval_stats/"
  OUT_FILE="$WRITE_DIR/tmp"
  OUT_STAT_FILE="$WRITE_DIR/${file_prefix}_$1_lc_ic_vs_tsc"
  rm -f $OUT_DIR/*
  rm -f $OUT_FILE
  dry_run $1

  echo "Exporting $1 interval statistics to $OUT_FILE"

  case "$1" in
    water-nsquared)
      cd water-nsquared > /dev/null
      command="./water-nsquared-$suffix < input.$threads > $OUT_FILE"
    ;;
    water-spatial)
      cd water-spatial > /dev/null
      command="./water-spatial-$suffix < input.$threads > $OUT_FILE"
    ;;
    ocean-cp) 
      cd ocean/contiguous_partitions > /dev/null
      command="./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > $OUT_FILE"
    ;;
    ocean-ncp) 
      cd ocean/non_contiguous_partitions > /dev/null
      command="./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > $OUT_FILE"
    ;;
    barnes)
      cd barnes > /dev/null
      command="./barnes-$suffix < input.$threads > $OUT_FILE"
    ;;
    volrend)
      cd volrend > /dev/null
      command="./volrend-$suffix $threads inputs/head > $OUT_FILE"
    ;;
    fmm)
      cd fmm > /dev/null
      command="./fmm-$suffix < inputs/input.65535.$threads > $OUT_FILE"
    ;;
    raytrace)
      cd raytrace > /dev/null
      command="./raytrace-$suffix -p $threads -m72 inputs/balls4.env > $OUT_FILE"
    ;;
    radiosity)
      cd radiosity > /dev/null
      command="./radiosity-$suffix -p $threads -batch -largeroom > $OUT_FILE"
    ;;
    radix)
      cd radix > /dev/null
      command="./radix-$suffix -p$threads -n134217728 -r1024 -m524288 > $OUT_FILE"
    ;;
    fft)
      cd fft > /dev/null
      command="./fft-$suffix -m24 -p$threads -n1048576 -l4 > $OUT_FILE"
    ;;
    lu-c)
      cd lu/contiguous_blocks > /dev/null
      command="./lu-c-$suffix -n4096 -p$threads -b16 > $OUT_FILE"
    ;;
    lu-nc)
      cd lu/non_contiguous_blocks > /dev/null
      command="./lu-nc-$suffix -n2048 -p$threads -b16 > $OUT_FILE"
    ;;
    cholesky)
      cd cholesky > /dev/null
      command="./cholesky-$suffix -p$threads -B32 -C1024 inputs/tk29.O > $OUT_FILE"
    ;;
  esac
  echo $command >> $DEBUG_FILE
  eval $command
  cd - > /dev/null

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
    "radix" | "fft" | "lu-c" | "lu-nc" | "cholesky")
      BENCH_DIR="kernels"
      ;;
    *)
      BENCH_DIR="apps"
      ;;
    esac

    cd $BENCH_DIR
    
    # Open this
#if [ 0 -eq 1 ]; then
    PI=5000
    AD=100

    if [ 0 -eq 1 ]; then
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$NAIVE EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
      file_prefix="naive-pi${PI}_ecc${AD}"
      emit_interval_stats $bench
    fi

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$NAIVE_TL EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
    file_prefix="naive-tl-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    if [ 0 -eq 1 ]; then
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$OPT EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
      file_prefix="opt-pi${PI}_ecc${AD}"
      emit_interval_stats $bench
    fi

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$OPT_TL EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
    file_prefix="opt-tl-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    if [ 0 -eq 1 ]; then
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$CD EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
      file_prefix="cd-pi${PI}_ecc${AD}"
      emit_interval_stats $bench
    fi

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$CD_TL EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
    file_prefix="cd-tl-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    PI=100
    AD=1

    if [ 0 -eq 1 ]; then
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEGACY EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
      file_prefix="legacy-pi${PI}_ecc${AD}"
      emit_interval_stats $bench
    fi

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEGACY_TL EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
    file_prefix="legacy-tl-pi${PI}_ecc${AD}"
    emit_interval_stats $bench
    
    # remove this
#fi

    PI=1000
    AD=0

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEGACY_ACC EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
    file_prefix="legacy-acc-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    PI=5000
    AD=0

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$OPT_ACC EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
    file_prefix="opt-acc-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$NAIVE_ACC EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
    file_prefix="naive-acc-pi${PI}_ecc${AD}"
    emit_interval_stats $bench

    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=$LEGACY_ACC EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
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
      echo "Wrong CI Type $2"
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
  echo "=================================== ACCURACY TEST ==========================================="
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
      echo "Wrong CI Type $CI_SETTING"
      exit
    ;;
  esac

  for bench in $*
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

    PI=$(read_tune_param $bench $CI_SETTING $THREAD)
    cd $BENCH_DIR
    
    CI=`echo "scale=0; $PI/5" | bc`
    echo "Using interval PI:$PI, CI:$CI, ECC:$AD for $bench" | tee -a $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc ${bench}-clean
#BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING -DRUNNING_MEDIAN" make -f Makefile.lc ${bench} 
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$CI_SETTING EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc ${bench} 
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
#settings_list="2 4 6 10 8 12 13 17"
#settings_list="6 12 13"
#settings_list="9 11 8 2 4 10"
#settings_list="12 13"
#settings_list="13 2 4 10 6 8 12"
  settings_list="2 12"
  if [ $# -eq 0 ]; then
    for setting in $settings_list
    do
      CI_SETTING=$setting
      ci_interval_test $BENCH
    done
  else
#perf_test $@
    for setting in $settings_list
    do
      CI_SETTING=$setting
      ci_interval_test $@
    done
  fi
}


BENCH="water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity radix fft lu-c lu-nc cholesky"
rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Allowed deviation: $AD, Threads: 1"
echo "Usage: ./experiment_interval_accuracy.sh <nothing / space separated list of splash2 benchmarks>"
mkdir -p $DIR
mkdir -p $WRITE_DIR
if [ $# -eq 0 ]; then
  run_perf_test
else
  run_perf_test $@
fi

rm -f $OUT_FILE $SUM_FILE

echo "Copy test-suite/process_data.sh to $WRITE_DIR (for each thread count). Edit process_data.sh to change the set of benchmarks tested, & the CI configurations used. Run ./process_data <threads>. Copy *.s100 to plot directory."
