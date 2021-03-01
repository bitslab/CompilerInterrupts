#!/bin/bash
CI=1000
PI="${PI:-5000}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
DIR=$CUR_PATH/splash2_stats/$SUB_DIR
WRITE_DIR=/local_home/nilanjana/temp/$SUB_DIR
CLOCK=1 #0 - predictive, 1 - instantaneous

LOG_FILE="$DIR/perf_logs-$AD.txt"
DEBUG_FILE="$DIR/perf_debug-$AD.txt"
BUILD_ERROR_FILE="$DIR/perf_test_build_error-$AD.txt"
BUILD_DEBUG_FILE="$DIR/perf_test_build_log-$AD.txt"

dry_run() {
  case "$1" in
    water-nsquared)
      cd water-nsquared > /dev/null
      command="$prefix ./water-nsquared-$suffix < input.1 > /dev/null 2>&1"
    ;;
    water-spatial)
      cd water-spatial > /dev/null
      command="$prefix ./water-spatial-$suffix < input.1 > /dev/null 2>&1"
    ;;
    ocean-cp) 
      cd ocean/contiguous_partitions > /dev/null
      command="$prefix ./ocean-cp-$suffix -n1026 -p 1 -e1e-07 -r2000 -t28800 > /dev/null 2>&1"
    ;;
    ocean-ncp) 
      cd ocean/non_contiguous_partitions > /dev/null
      command="$prefix ./ocean-ncp-$suffix -n258 -p 1 -e1e-07 -r2000 -t28800 > /dev/null 2>&1"
    ;;
    barnes)
      cd barnes > /dev/null
      command="$prefix ./barnes-$suffix < input.1 > /dev/null 2>&1"
    ;;
    volrend)
      cd volrend > /dev/null
      command="$prefix ./volrend-$suffix 1 inputs/head > /dev/null 2>&1"
    ;;
    fmm)
      cd fmm > /dev/null
      command="$prefix ./fmm-$suffix < inputs/input.65535.1 > /dev/null 2>&1"
    ;;
    raytrace)
      cd raytrace > /dev/null
      command="$prefix ./raytrace-$suffix -p 1 -m72 inputs/balls4.env > /dev/null 2>&1"
    ;;
    radiosity)
      cd radiosity > /dev/null
      command="$prefix ./radiosity-$suffix -p 1 -batch -largeroom > /dev/null 2>&1"
    ;;
    radix)
      cd radix > /dev/null
      command="$prefix ./radix-$suffix -p1 -n134217728 -r1024 -m524288 > /dev/null 2>&1"
    ;;
    fft)
      cd fft > /dev/null
      command="$prefix ./fft-$suffix -m24 -p1 -n1048576 -l4 > /dev/null 2>&1"
    ;;
    lu-c)
      cd lu/contiguous_blocks > /dev/null
      command="$prefix ./lu-c-$suffix -n4096 -p1 -b16 > /dev/null 2>&1"
    ;;
    lu-nc)
      cd lu/non_contiguous_blocks > /dev/null
      command="$prefix ./lu-nc-$suffix -n2048 -p1 -b16 > /dev/null 2>&1"
    ;;
    cholesky)
      cd cholesky > /dev/null
      command="$prefix ./cholesky-$suffix -p1 -B32 -C1024 inputs/tk29.O > /dev/null 2>&1"
    ;;
  esac
  echo $command >> $DEBUG_FILE
  eval $command
  cd - > /dev/null
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
emit_interval_stats() {
  threads=1
  suffix="lc"
  prefix="timeout 5m taskset 0x00000001 "
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
      command="$prefix ./water-nsquared-$suffix < input.$threads > $OUT_FILE"
    ;;
    water-spatial)
      cd water-spatial > /dev/null
      command="$prefix ./water-spatial-$suffix < input.$threads > $OUT_FILE"
    ;;
    ocean-cp) 
      cd ocean/contiguous_partitions > /dev/null
      command="$prefix ./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > $OUT_FILE"
    ;;
    ocean-ncp) 
      cd ocean/non_contiguous_partitions > /dev/null
      command="$prefix ./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > $OUT_FILE"
    ;;
    barnes)
      cd barnes > /dev/null
      command="$prefix ./barnes-$suffix < input.$threads > $OUT_FILE"
    ;;
    volrend)
      cd volrend > /dev/null
      command="$prefix ./volrend-$suffix $threads inputs/head > $OUT_FILE"
    ;;
    fmm)
      cd fmm > /dev/null
      command="$prefix ./fmm-$suffix < inputs/input.65535.$threads > $OUT_FILE"
    ;;
    raytrace)
      cd raytrace > /dev/null
      command="$prefix ./raytrace-$suffix -p $threads -m72 inputs/balls4.env > $OUT_FILE"
    ;;
    radiosity)
      cd radiosity > /dev/null
      command="$prefix ./radiosity-$suffix -p $threads -batch -largeroom > $OUT_FILE"
    ;;
    radix)
      cd radix > /dev/null
      command="$prefix ./radix-$suffix -p$threads -n134217728 -r1024 -m524288 > $OUT_FILE"
    ;;
    fft)
      cd fft > /dev/null
      command="$prefix ./fft-$suffix -m24 -p$threads -n1048576 -l4 > $OUT_FILE"
    ;;
    lu-c)
      cd lu/contiguous_blocks > /dev/null
      command="$prefix ./lu-c-$suffix -n4096 -p$threads -b16 > $OUT_FILE"
    ;;
    lu-nc)
      cd lu/non_contiguous_blocks > /dev/null
      command="$prefix ./lu-nc-$suffix -n2048 -p$threads -b16 > $OUT_FILE"
    ;;
    cholesky)
      cd cholesky > /dev/null
      command="$prefix ./cholesky-$suffix -p$threads -B32 -C1024 inputs/tk29.O > $OUT_FILE"
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
  done
  ls
  cd -
}

perf_test() {
  echo "=================================== INTERVAL ACCURACY TEST ==========================================="
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

    #1. Build original program with Periodic CI
    echo "Building original program with Periodic CI that prints interval statistics: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $bench 
    file_prefix="opt$PI"
    emit_interval_stats $bench
    process_file $bench
    convert 3 $bench

    #2. Build original program with Naive CI
    echo "Building original program with Naive CI that prints interval statistics: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $bench 
    file_prefix="naive$PI"
    emit_interval_stats $bench
    process_file $bench
    convert 3 $bench

    #3. Build original program with Legacy CI
    LEGACY_PI=100
    echo "Building original program with Legacy CI(Interval: every $LEGACY_PI times) that prints interval statistics: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$LEGACY_PI CMMT_INTV=$CI INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $bench 
    file_prefix="legacy_$LEGACY_PI"
    emit_interval_stats $bench
    process_file $bench
    convert 3 $bench

    #3. Build original program with Legacy CI
    LEGACY_PI=1000
    echo "Building original program with Legacy CI(Interval: every $LEGACY_PI times) that prints interval statistics: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$LEGACY_PI CMMT_INTV=$CI INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $bench 
    file_prefix="legacy_$LEGACY_PI"
    emit_interval_stats $bench
    process_file $bench
    convert 3 $bench

    #2. Build original program with Coredet TL CI
    echo "Building original program with CoreDet TL CI that prints interval statistics: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=6 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $bench 
    file_prefix="coredet_tl"
    emit_interval_stats $bench
    process_file $bench
    convert 3 $bench

    #2. Build original program with Coredet Local CI
    echo "Building original program with CoreDet Local CI that prints interval statistics: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=6 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $bench 
    file_prefix="coredet_local"
    emit_interval_stats $bench
    process_file $bench
    convert 3 $bench

    # commented out
    if [ 1 -eq 0 ]; then
      #3. Build original program with Legacy CI
      LEGACY_PI=1
      echo "Building original program with Legacy CI(Interval: every $LEGACY_PI times) that prints interval statistics: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$LEGACY_PI CMMT_INTV=$CI INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $bench 
      file_prefix="legacy_$LEGACY_PI"
      emit_interval_stats $bench
      process_file $bench
      convert 3 $bench

      #3. Build original program with Legacy CI
      LEGACY_PI=10
      echo "Building original program with Legacy CI(Interval: every $LEGACY_PI times) that prints interval statistics: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$LEGACY_PI CMMT_INTV=$CI INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $bench 
      file_prefix="legacy_$LEGACY_PI"
      emit_interval_stats $bench
      process_file $bench
      convert 3 $bench

      #3. Build original program with Legacy CI
      LEGACY_PI=100
      echo "Building original program with Legacy CI(Interval: every $LEGACY_PI times) that prints interval statistics: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$LEGACY_PI CMMT_INTV=$CI INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $bench 
      file_prefix="legacy_$LEGACY_PI"
      emit_interval_stats $bench
      process_file $bench
      convert 3 $bench

      #3. Build original program with Legacy CI
      LEGACY_PI=1000
      echo "Building original program with Legacy CI(Interval: every $LEGACY_PI times) that prints interval statistics: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$LEGACY_PI CMMT_INTV=$CI INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $bench 
      file_prefix="legacy_$LEGACY_PI"
      emit_interval_stats $bench
      process_file $bench
      convert 3 $bench

      #3. Build original program with Legacy CI
      LEGACY_PI=10000
      echo "Building original program with Legacy CI(Interval: every $LEGACY_PI times) that prints interval statistics: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$LEGACY_PI CMMT_INTV=$CI INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc $bench 
      file_prefix="legacy_$LEGACY_PI"
      emit_interval_stats $bench
      process_file $bench
      convert 3 $bench
    fi

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

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test radix fft lu-c lu-nc cholesky water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
  else
    perf_test $@
  fi
}


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
