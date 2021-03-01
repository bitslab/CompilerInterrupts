#!/bin/bash
BENCH="reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count"
DEBUG_FILE="make_log"
ERROR_FILE="make_error"

dry_run() {
  program=$1
  OUT_FILE="$DIR/strace_$bench.txt"
  prefix="strace -o $OUT_FILE"
  case "$1" in
    histogram)
      command="MR_NUMTHREADS=1 timeout 5m $prefix ./tests/$program/$program ../input_datasets/${program}_datafiles/large.bmp > /dev/null 2>&1"
    ;;
    kmeans)
      command="MR_NUMTHREADS=1 timeout 5m $prefix ./tests/$program/$program -d 100 -c 10 -p 500000 -s 50 > /dev/null 2>&1"
    ;;
    pca) 
      command="MR_NUMTHREADS=1 timeout 5m $prefix ./tests/$program/$program -r 1000 -c 1000 -s 1000 > /dev/null 2>&1"
    ;;
    matrix_multiply) 
      command="MR_NUMTHREADS=1 timeout 5m $prefix ./tests/$program/$program 900 600 1 > /dev/null 2>&1"
    ;;
    string_match)
      command="MR_NUMTHREADS=1 timeout 5m $prefix ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_100MB.txt > /dev/null 2>&1"
    ;;
    linear_regression)
      command="MR_NUMTHREADS=1 timeout 5m $prefix ./tests/$program/$program ../input_datasets/${program}_datafiles/key_file_500MB.txt > /dev/null 2>&1"
    ;;
    word_count)
      command="MR_NUMTHREADS=1 timeout 5m $prefix ./tests/$program/$program ../input_datasets/${program}_datafiles/word_50MB.txt > /dev/null 2>&1"
    ;;
    reverse_index)
      command="MR_NUMTHREADS=1 timeout 5m $prefix ./tests/$program/$program ../input_datasets/${program}_datafiles/www.stanford.edu/dept/news/ > /dev/null 2>&1"
    ;;
  esac
  echo "Dry run: "$command
  eval $command
}

orig_test() {
  echo "Building original program: " | tee -a $DEBUG_FILE
  make -f Makefile.orig clean >>$DEBUG_FILE 2>>$ERROR_FILE
  make -f Makefile.orig >>$DEBUG_FILE 2>>$ERROR_FILE
  for bench in $BENCH
  do
    dry_run $bench
  done
}

cur_path=`pwd`
DIR="$cur_path/strace_files"
mkdir -p $DIR
orig_test
