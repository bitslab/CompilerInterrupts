#!/bin/bash
CI=1000
PI="${PI:-5000}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
DIR=$CUR_PATH/phoenix_stats/$SUB_DIR
WRITE_DIR=/local_home/nilanjana/temp/$SUB_DIR
CLOCK=1

dry_run() {
  # Dry run - so that any disk caching does not hamper the process
  case "$1" in
    histogram)
#eo "MR_NUMTHREADS=$threads timeout 5m $prefix ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp" >> $DEBUG_FILE
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp > /dev/null 2>&1"
    ;;
    kmeans)
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program -d 100 -c 10 -p 500000 -s 50 > /dev/null 2>&1"
    ;;
    pca) 
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program -r 1000 -c 1000 -s 1000 > /dev/null 2>&1"
    ;;
    matrix_multiply) 
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program 900 600 1 > /dev/null 2>&1"
    ;;
    string_match)
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_100MB.txt > /dev/null 2>&1"
    ;;
    linear_regression)
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_500MB.txt > /dev/null 2>&1"
    ;;
    word_count)
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/word_50MB.txt > /dev/null 2>&1"
    ;;
    reverse_index)
      command="MR_NUMTHREADS=1 timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/www.stanford.edu/dept/news/ > /dev/null 2>&1"
    ;;
  esac
  echo "Dry run: "$command >> $DEBUG_FILE
  eval $command
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
emit_interval_stats() {
  threads=1
  program=$1
  OUT_FILE="$WRITE_DIR/tmp"
  OUT_DIR="/local_home/nilanjana/temp/interval_stats/"
  OUT_STAT_FILE="$WRITE_DIR/${prefix}_$1_lc_ic_vs_tsc"
  rm -f $OUT_DIR/*
  rm -f $OUT_FILE
  dry_run $program

  case "$program" in
    histogram)
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp > $OUT_FILE 2>&1"
    ;;
    kmeans)
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program -d 100 -c 10 -p 500000 -s 50 > $OUT_FILE 2>&1"
    ;;
    pca) 
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program -r 1000 -c 1000 -s 1000 > $OUT_FILE 2>&1"
    ;;
    matrix_multiply) 
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program 900 600 1 > $OUT_FILE 2>&1"
    ;;
    string_match)
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_100MB.txt > $OUT_FILE 2>&1"
    ;;
    linear_regression)
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_500MB.txt > $OUT_FILE 2>&1"
    ;;
    word_count)
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/word_50MB.txt > $OUT_FILE 2>&1"
    ;;
    reverse_index)
      command="MR_NUMTHREADS=$threads timeout 5m ./tests/$program/$program ../input_datasets/${program}_datafiles/www.stanford.edu/dept/news/ > $OUT_FILE 2>&1"
    ;;
  esac
  echo $command >> $DEBUG_FILE
  eval $command

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

process_file() {
  return
  for infile in $WRITE_DIR/${prefix}_$1_lc_ic_vs_tsc*.txt
  do
#infile="$WRITE_DIR/${prefix}_$1_lc_ic_vs_tsc.txt"
    old_records=`awk 'END {print NR-1}' $infile`
    sed -i '/[^0-9 ]/d' $infile
    awk 'NF==4' $infile > tmp
    mv tmp $infile
    new_records=`awk 'END {print NR-1}' $infile`
    echo "#old_records: $old_records, #new_records: $new_records" | tee -a $DEBUG_FILE
  done
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

  for infile in $WRITE_DIR/${prefix}_$1_lc_ic_vs_tsc*.txt
  do
    #infile="$WRITE_DIR/${prefix}_${b}_lc_ic_vs_tsc.txt"
    outfile="$WRITE_DIR/${prefix}_cdf-${b}${suffix}.txt"
    echo "CDF generated in $outfile" | tee -a $DEBUG_FILE

    total_records=`cat $infile | awk 'END {print NR-1}'`
    cat $infile | tail --lines=+2 | sort -n -k $key_pos | awk -v records=$total_records -v key=$key_pos '{print NR/records, $key}' > $outfile
    echo ""
  done
}

perf_test() {
  echo "=================================== INTERVAL ACCURACY TEST ==========================================="
  LOG_FILE="$DIR/perf_logs-ad$AD.txt"
  DEBUG_FILE="$DIR/perf_debug-ad$AD.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error-ad$AD.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log-ad$AD.txt"
  #FIBER_CONFIG is set in the Makefile. Unless needed, do not pass a new config from this script

  rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE

  #run periodic
  for bench in $*
  do
    echo "Building Periodic CI program that prints interval statistics: " >> $DEBUG_FILE
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running periodic opt program for $bench: " >> $DEBUG_FILE
    prefix="opt$PI"
    emit_interval_stats $bench
    process_file $bench
    convert 3 $bench

    echo "Building Naive CI program that prints interval statistics: " >> $DEBUG_FILE
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running naive program for $bench: " >> $DEBUG_FILE
    prefix="naive$PI"
    emit_interval_stats $bench
    process_file $bench
    convert 3 $bench

    echo "Building CoreDet TL CI program that prints interval statistics: " >> $DEBUG_FILE
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=6 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running coredet tl program for $bench: " >> $DEBUG_FILE
    prefix="coredet_tl"
    emit_interval_stats $bench
    process_file $bench
    convert 3 $bench

    echo "Building CoreDet Local CI program that prints interval statistics: " >> $DEBUG_FILE
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=7 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running coredet tl program for $bench: " >> $DEBUG_FILE
    prefix="coredet_local"
    emit_interval_stats $bench
    process_file $bench
    convert 3 $bench

    LEGACY_PI=100
    echo "Building Legacy CI(every $LEGACY_PI times) program that prints interval statistics: " >> $DEBUG_FILE
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$LEGACY_PI CMMT_INTV=1 INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running legacy program for $bench: " >> $DEBUG_FILE
    prefix="legacy_$LEGACY_PI"
    emit_interval_stats $bench
    process_file $bench
    convert 3 $bench

    LEGACY_PI=1000
    echo "Building Legacy CI(every $LEGACY_PI times) program that prints interval statistics: " >> $DEBUG_FILE
    make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$LEGACY_PI CMMT_INTV=1 INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
    echo "Running legacy program for $bench: " >> $DEBUG_FILE
    prefix="legacy_$LEGACY_PI"
    emit_interval_stats $bench
    process_file $bench
    convert 3 $bench

    # Commented out 
    if [ 1 -eq 0 ]; then
      LEGACY_PI=1
      echo "Building Legacy CI(every $LEGACY_PI times) program that prints interval statistics: " >> $DEBUG_FILE
      make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
      ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$LEGACY_PI CMMT_INTV=1 INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
      echo "Running legacy program for $bench: " >> $DEBUG_FILE
      prefix="legacy_$LEGACY_PI"
      emit_interval_stats $bench
      process_file $bench
      convert 3 $bench

      LEGACY_PI=10
      echo "Building Legacy CI(every $LEGACY_PI times) program that prints interval statistics: " >> $DEBUG_FILE
      make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
      ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$LEGACY_PI CMMT_INTV=1 INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
      echo "Running legacy program for $bench: " >> $DEBUG_FILE
      prefix="legacy_$LEGACY_PI"
      emit_interval_stats $bench
      process_file $bench
      convert 3 $bench

      LEGACY_PI=100
      echo "Building Legacy CI(every $LEGACY_PI times) program that prints interval statistics: " >> $DEBUG_FILE
      make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
      ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$LEGACY_PI CMMT_INTV=1 INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
      echo "Running legacy program for $bench: " >> $DEBUG_FILE
      prefix="legacy_$LEGACY_PI"
      emit_interval_stats $bench
      process_file $bench
      convert 3 $bench

      LEGACY_PI=1000
      echo "Building Legacy CI(every $LEGACY_PI times) program that prints interval statistics: " >> $DEBUG_FILE
      make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
      ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$LEGACY_PI CMMT_INTV=1 INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
      echo "Running legacy program for $bench: " >> $DEBUG_FILE
      prefix="legacy_$LEGACY_PI"
      emit_interval_stats $bench
      process_file $bench
      convert 3 $bench

      LEGACY_PI=10000
      echo "Building Legacy CI(every $LEGACY_PI times) program that prints interval statistics: " >> $DEBUG_FILE
      make -f Makefile.lc clean >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
      ALLOWED_DEVIATION=0 CLOCK_TYPE=1 PUSH_INTV=$LEGACY_PI CMMT_INTV=1 INST_LEVEL=5 EXTRA_FLAGS="-DAVG_STATS -DINTV_SAMPLING" make -f Makefile.lc >$BUILD_DEBUG_FILE 2>$BUILD_ERROR_FILE
      echo "Running legacy program for $bench: " >> $DEBUG_FILE
      prefix="legacy_$LEGACY_PI"
      emit_interval_stats $bench
      process_file $bench
      convert 3 $bench
    fi
  done
}

run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count
  else
    perf_test $@
  fi
}

echo "Note: Script has performance tests for both instantaneous & predictive clocks."
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Allowed deviation: $AD, Output Directory: $WRITE_DIR"
echo "WARNING: Remove Passed Config if you don't need it!"
mkdir -p $DIR;
mkdir -p $WRITE_DIR;

if [ $# -eq 0 ]; then
  run_perf_test
else
  run_perf_test $@
fi
