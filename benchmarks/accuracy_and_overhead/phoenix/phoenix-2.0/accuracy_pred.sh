#!/bin/bash

PI=5000
CI=1000
AD=0
CLOCK=0 # 0 - predictive, 1 - instantaneous
DIR=pred_stats
LOG_FILE="$DIR/accuracy_log.txt"
ERROR_LOG_FILE="$DIR/accuracy_error.txt"
MR_OUT="$DIR/phoenix-acc-mr.txt"
SEQ_OUT="$DIR/phoenix-acc-seq.txt"
PTHREAD_OUT="$DIR/phoenix-acc-pthread.txt"
rm -f $LOG_FILE $ERROR_LOG_FILE $MR_OUT $SEQ_OUT $PTHREAD_OUT

check_accuracy()
{
  program=$1
  program_abbrev=""
  command1=""
  command2=""
  command3=""
  if [ "$program" = "histogram" ]; then
    program_abbrev="hist-$2"
    test_file="$2.bmp"
    echo "*********************************** Running $program with $test_file data **********************************"
    command1="MR_NUMTHREADS=1 ./tests/$program/$program ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command2="./tests/$program/${program}-seq ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command3="MR_NUMTHREADS=1 ./tests/$program/${program}-pthread ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
  elif [ "$program" = "linear_regression" ]; then
    program_abbrev="lr-$2"
    test_file="key_file_$2.txt"
    echo "*********************************** Running $program with $test_file data **********************************"
    command1="MR_NUMTHREADS=1 ./tests/$program/$program ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command2="./tests/$program/${program}-seq ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command3="MR_NUMTHREADS=1 ./tests/$program/${program}-pthread ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
  elif [ "$program" = "string_match" ]; then
    program_abbrev="sm-$2"
    test_file="key_file_$2.txt"
    echo "*********************************** Running $program with $test_file data **********************************"
    command1="MR_NUMTHREADS=1 ./tests/$program/$program ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command2="./tests/$program/${program}-seq ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command3="MR_NUMTHREADS=1 ./tests/$program/${program}-pthread ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
  elif [ "$program" = "matrix_multiply" ]; then
    program_abbrev="mm"
    echo "****************************************** Running $program ************************************************"
    command1="MR_NUMTHREADS=1 ./tests/$program/$program 25 5 1 > tmp 2>&1"
    command2="./tests/$program/${program}-seq 25 5 1 > tmp 2>&1"
    command3="MR_NUMTHREADS=1 ./tests/$program/${program}-pthread 25 5 1 > tmp 2>&1"
  elif [ "$program" = "pca" ]; then
    program_abbrev=$program
    echo "****************************************** Running $program ************************************************"
    command1="MR_NUMTHREADS=1 ./tests/$program/$program -r 25 -c 20 -s 500 > tmp 2>&1"
    command2="./tests/$program/${program}-seq -r 25 -c 20 -s 500 > tmp 2>&1"
    command3="MR_NUMTHREADS=1 ./tests/$program/${program}-pthread -r 25 -c 20 -s 500 > tmp 2>&1"
  elif [ "$program" = "kmeans" ]; then
    program_abbrev="kmeans"
    echo "****************************************** Running $program ************************************************"
    command1="MR_NUMTHREADS=1 ./tests/$program/$program -d 25 -c 3 -p 200 -s 50 > tmp 2>&1"
    command2="./tests/$program/${program}-seq -d 25 -c 3 -p 200 -s 50 > tmp 2>&1"
    command3="MR_NUMTHREADS=1 ./tests/$program/${program}-pthread -d 25 -c 3 -p 200 -s 50 > tmp 2>&1"
  elif [ "$program" = "word_count" ]; then
    program_abbrev="wc-$2"
    test_file="word_$2.txt"
    echo "*********************************** Running $program with $test_file data **********************************"
    command1="MR_NUMTHREADS=1 ./tests/$program/$program ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command2="./tests/$program/${program}-seq ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command3="MR_NUMTHREADS=1 ./tests/$program/${program}-pthread ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
  else 
    echo "$program is not a valid program. Aborting."
    exit
  fi
  echo -ne "$program_abbrev\t" >> $MR_OUT
  echo -ne "$program_abbrev\t" >> $SEQ_OUT
  echo -ne "$program_abbrev\t" >> $PTHREAD_OUT

  rm -f lib/libphoenix.a ./tests/$program/${program} ./tests/$program/${program}-seq ./tests/$program/${program}-pthread
  echo "Building for naive mode of $program" | tee -a $LOG_FILE $ERROR_LOG_FILE > /dev/null
  make clean -C ./src -f Makefile.lc >>$LOG_FILE 2>>$ERROR_LOG_FILE
  make -C ./tests -f Makefile.lc $program-clean >>$LOG_FILE 2>>$ERROR_LOG_FILE 
  ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -C ./src -f Makefile.lc >>$LOG_FILE 2>>$ERROR_LOG_FILE 
  ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -C ./tests -f Makefile.lc $program >>$LOG_FILE 2>>$ERROR_LOG_FILE 
  #echo "command: $command1"
  eval $command1
  #MR_NUMTHREADS=1 ./tests/histogram/histogram ../input_datasets/histogram_datafiles/small.bmp > tmp 2>&1
  orig_mr_count=`grep "Logical Clock" tmp | grep "main" | cut -d ":" -f 2`
  echo -ne "$orig_mr_count\t" >> $MR_OUT

  #echo "command: $command2"
  eval $command2
  #MR_NUMTHREADS=1 ./tests/histogram/histogram-seq ../input_datasets/histogram_datafiles/small.bmp > tmp 2>&1
  orig_seq_count=`grep "Logical Clock" tmp | grep "main" | cut -d ":" -f 2`
  echo -ne "$orig_seq_count\t" >> $SEQ_OUT

  #echo "command: $command3"
  eval $command3
  #MR_NUMTHREADS=1 ./tests/histogram/histogram-pthread ../input_datasets/histogram_datafiles/small.bmp > tmp 2>&1
  orig_pthread_count=`grep "Logical Clock" tmp | grep "main" | cut -d ":" -f 2`
  echo -ne "$orig_pthread_count\t" >> $PTHREAD_OUT
  

  rm -f lib/libphoenix.a ./tests/$program/${program} ./tests/$program/${program}-seq ./tests/$program/${program}-pthread
  echo "Building for opt mode of $program" | tee -a $LOG_FILE $ERROR_LOG_FILE > /dev/null
  make clean -C ./src -f Makefile.lc >>$LOG_FILE 2>>$ERROR_LOG_FILE
  make -C ./tests -f Makefile.lc $program-clean >>$LOG_FILE 2>>$ERROR_LOG_FILE
  ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -C ./src -f Makefile.lc >>$LOG_FILE 2>>$ERROR_LOG_FILE
  ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -C ./tests -f Makefile.lc $program >>$LOG_FILE 2>>$ERROR_LOG_FILE
  #echo "command: $command1"
  eval $command1
  #MR_NUMTHREADS=1 ./tests/histogram/histogram ../input_datasets/histogram_datafiles/small.bmp > tmp 2>&1
  est_mr_count=`grep "Logical Clock" tmp | grep "main" | cut -d ":" -f 2`
  echo -ne "$est_mr_count\t" >> $MR_OUT

  #echo "command: $command2"
  eval $command2
  #MR_NUMTHREADS=1 ./tests/histogram/histogram-seq ../input_datasets/histogram_datafiles/small.bmp > tmp 2>&1
  est_seq_count=`grep "Logical Clock" tmp | grep "main" | cut -d ":" -f 2`
  echo -ne "$est_seq_count\t" >> $SEQ_OUT

  #echo "command: $command3"
  eval $command3
  #MR_NUMTHREADS=1 ./tests/histogram/histogram-pthread ../input_datasets/histogram_datafiles/small.bmp > tmp 2>&1
  est_pthread_count=`grep "Logical Clock" tmp | grep "main" | cut -d ":" -f 2`
  echo -ne "$est_pthread_count\t" >> $PTHREAD_OUT

  err_mr=`echo "scale = 3; (($est_mr_count - $orig_mr_count) * 100 / $orig_mr_count)" | bc -l`
  err_seq=`echo "scale = 3; (($est_seq_count - $orig_seq_count) * 100 / $orig_seq_count)" | bc -l`
  err_pthread=`echo "scale = 3; (($est_pthread_count - $orig_pthread_count) * 100 / $orig_pthread_count)" | bc -l`

  echo -e "$err_mr" >> $MR_OUT
  echo -e "$err_seq" >> $SEQ_OUT
  echo -e "$err_pthread" >> $PTHREAD_OUT

  echo "With Map Reduce, Original count: $orig_mr_count, Estimated count: $est_mr_count, error percentage: $err_mr%"
  echo "With Sequential method, Original count: $orig_seq_count, Estimated count: $est_seq_count, error percentage: $err_seq%"
  echo "With Pthread, Original count: $orig_pthread_count, Estimated count: $est_pthread_count, error percentage: $err_pthread%"
}

check_accuracy_all() {
  check_accuracy kmeans
  check_accuracy pca
  check_accuracy matrix_multiply
  check_accuracy histogram small
  check_accuracy histogram med
  check_accuracy histogram large
  check_accuracy linear_regression 50MB
  check_accuracy linear_regression 100MB
  check_accuracy linear_regression 500MB
  check_accuracy string_match 50MB
  check_accuracy string_match 100MB
  check_accuracy string_match 500MB
  check_accuracy word_count 10MB
  check_accuracy word_count 50MB
  check_accuracy word_count 100MB
}

echo "This script must be run in superuser mode!!!"
mkdir -p $DIR

echo -e "Program\tActual-count\tEstimated-count\tPercentage-error" > $MR_OUT
echo -e "Program\tActual-count\tEstimated-count\tPercentage-error" > $SEQ_OUT
echo -e "Program\tActual-count\tEstimated-count\tPercentage-error" > $PTHREAD_OUT

if [ $# -eq 0 ]; then
  echo "Accuracy test for all benchmarks"
  check_accuracy_all
else
  echo "Accuracy test for $1"
  if [ "$1" = "histogram" ]; then
    check_accuracy $1 small
    check_accuracy $1 med
    check_accuracy $1 large
  elif [ "$1" = "linear_regression" ]; then
    check_accuracy $1 50MB
    check_accuracy $1 100MB
    check_accuracy $1 500MB
  elif [ "$1" = "string_match" ]; then
    check_accuracy $1 50MB
    check_accuracy $1 100MB
    check_accuracy $1 500MB
  elif [ "$1" = "word_count" ]; then
    check_accuracy $1 10MB
    check_accuracy $1 50MB
    check_accuracy $1 100MB
  else 
    check_accuracy $1
  fi
fi
