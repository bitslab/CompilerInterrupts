#!/bin/bash
CI=1000
PI="${PI:-5000}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
DIR=$CUR_PATH/splash2_stats/$SUB_DIR
WRITE_DIR=/AD-home/cmonta9/temp/$SUB_DIR
CLOCK=1 #0 - predictive, 1 - instantaneous

LOG_FILE="$DIR/perf_logs-$AD.txt"
DEBUG_FILE="$DIR/perf_debug-$AD.txt"
BUILD_ERROR_FILE="$DIR/perf_test_build_error-$AD.txt"
BUILD_DEBUG_FILE="$DIR/perf_test_build_log-$AD.txt"

dry_run() {
  case "$1" in
    blackscholes)
      cd blackscholes/src > /dev/null
      $prefix ./blackscholes$suffix $threads ../inputs/in_10M.txt prices.txt > /dev/null 2>&1
      echo "$prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    fluidanimate)
      cd fluidanimate/src > /dev/null
      $prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > /dev/null 2>&1
      echo "$prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    swaptions)
      cd swaptions/src > /dev/null
      $prefix ./swaptions$suffix -ns 128 -sm 200000 -nt $threads > /dev/null 2>&1
      echo "$prefix ./swaptions$suffix -ns 128 -sm 200000 -nt $threads > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    canneal)
      cd canneal/src > /dev/null
      $prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > /dev/null 2>&1
      echo "$prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    dedup)
      cd dedup/src > /dev/null
      $prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > /dev/null 2>&1
      echo "$prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    streamcluster)
      cd streamcluster/src > /dev/null
      $prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > /dev/null 2>&1 
      echo "$prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
  esac
  cd - > /dev/null
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
emit_interval_stats() {
  threads=1
  suffix="_ci"
  prefix="timeout 5m taskset 0x00000001 "
  OUT_FILE="$WRITE_DIR/$1_lc_ic_vs_tsc.txt"
  dry_run $1

  echo "Exporting $1 interval statistics to $OUT_FILE"

  case "$1" in
    blackscholes)
      cd blackscholes/src > /dev/null
      $prefix ./blackscholes$suffix $threads ../inputs/in_10M.txt prices.txt > $OUT_FILE
      sleep 0.5
      echo "$prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    fluidanimate)
      cd fluidanimate/src > /dev/null
      $prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE
      sleep 0.5
      echo "$prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    swaptions)
      cd swaptions/src > /dev/null
      $prefix ./swaptions$suffix -ns 128 -sm 200000 -nt $threads > $OUT_FILE
      sleep 0.5
      echo "$prefix ./swaptions$suffix -ns 128 -sm 200000 -nt $threads > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    canneal)
      cd canneal/src > /dev/null
      $prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > $OUT_FILE
      sleep 0.5
      echo "$prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    dedup)
      cd dedup/src > /dev/null
      $prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE
      sleep 0.5
      echo "$prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    streamcluster)
      cd streamcluster/src > /dev/null
      $prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > $OUT_FILE
      sleep 0.5
      echo "$prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
  esac
}

perf_test() {
  echo "=================================== INTERVAL ACCURACY TEST ==========================================="
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
    #1. Build original program with Periodic CI
    echo "Building original program with Periodic CI that prints interval statistics: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.ci ${bench} 
    emit_interval_stats $bench
    cd ../ > /dev/null
    process_file $bench
    convert 3 $bench
  done
}

process_file() {

  infile="$WRITE_DIR/$1_lc_ic_vs_tsc.txt"
  old_records=`awk 'END {print NR-1}' $infile`
  sed -i '/[^0-9 ]/d' $infile
  awk 'NF==4' $infile > tmp
  mv tmp $infile
  new_records=`awk 'END {print NR-1}' $infile`
  echo "$1: #old_records: $old_records, #new_records: $new_records"
}

convert() {
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

  infile="$WRITE_DIR/${b}_lc_ic_vs_tsc.txt"
  outfile="$WRITE_DIR/cdf-${b}${suffix}.txt"
  echo "Converting $infile to cdf format in $outfile"

  total_records=`cat $infile | awk 'END {print NR-1}'`
  echo "#records for $b: $total_records"
  cat $infile | tail --lines=+2 | sort -n -k $key_pos | awk -v records=$total_records -v key=$key_pos '{print NR/records, $key}' > $outfile
}

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test blackscholes fluidanimate swaptions canneal dedup streamcluster 
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
