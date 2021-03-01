#!/bin/bash

PI=5000
CI=1000
AD=0
CLOCK=0 # 0 - predictive, 1 - instantaneous
THREADS=64
NUMBER_OF_RUNS=25
DIR=stats
LOG_FILE="$DIR/log-$AD.txt"
CMD_LOG_FILE="$DIR/command_log-$AD.txt"
STAT_LOG_FILE="$DIR/stat_log-$AD.txt"
MR_OUT="$DIR/phoenix-mr-$AD.txt"
SEQ_OUT="$DIR/phoenix-seq-$AD.txt"
PTHREAD_OUT="$DIR/phoenix-pthread-$AD.txt"
rm -f $LOG_FILE $STAT_LOG_FILE $CMD_LOG_FILE $MR_OUT $SEQ_OUT $PTHREAD_OUT
echo -e "Program\tUninstrumented\tOptimized\tNaive" > $MR_OUT
echo -e "Program\tUninstrumented\tOptimized\tNaive" > $SEQ_OUT
echo -e "Program\tUninstrumented\tOptimized\tNaive" > $PTHREAD_OUT

run_test()
{
  program=$1
  program_abbrev=""
  command1=""
  command2=""
  command3=""
  if [ "$program" = "histogram" ]; then
    program_abbrev="hist-$2"
    test_file="$2.bmp"
    echo "*********************************** Running $program with $test_file data **********************************" | tee -a $STAT_LOG_FILE $LOG_FILE $CMD_LOG_FILE
    command1="MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command2="./tests/$program/${program}-seq ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command3="MR_NUMTHREADS=$THREADS ./tests/$program/${program}-pthread ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
  elif [ "$program" = "linear_regression" ]; then
    program_abbrev="lr-$2"
    test_file="key_file_$2.txt"
    echo "*********************************** Running $program with $test_file data **********************************" | tee -a $STAT_LOG_FILE $LOG_FILE $CMD_LOG_FILE
    command1="MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command2="./tests/$program/${program}-seq ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command3="MR_NUMTHREADS=$THREADS ./tests/$program/${program}-pthread ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
  elif [ "$program" = "string_match" ]; then
    program_abbrev="sm-$2"
    test_file="key_file_$2.txt"
    echo "*********************************** Running $program with $test_file data **********************************" | tee -a $STAT_LOG_FILE $LOG_FILE $CMD_LOG_FILE
    command1="MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command2="./tests/$program/${program}-seq ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command3="MR_NUMTHREADS=$THREADS ./tests/$program/${program}-pthread ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
  elif [ "$program" = "matrix_multiply" ]; then
    program_abbrev="mm"
    echo "****************************************** Running $program ************************************************" | tee -a $STAT_LOG_FILE $LOG_FILE $CMD_LOG_FILE
    command1="MR_NUMTHREADS=$THREADS ./tests/$program/$program 25 5 1 > tmp 2>&1"
    command2="./tests/$program/${program}-seq 25 5 1 > tmp 2>&1"
    command3="MR_NUMTHREADS=$THREADS ./tests/$program/${program}-pthread 25 5 1 > tmp 2>&1"
  elif [ "$program" = "pca" ]; then
    program_abbrev=$program
    echo "****************************************** Running $program ************************************************" | tee -a $STAT_LOG_FILE $LOG_FILE $CMD_LOG_FILE
    command1="MR_NUMTHREADS=$THREADS ./tests/$program/$program -r 25 -c 20 -s 500 > tmp 2>&1"
    command2="./tests/$program/${program}-seq -r 25 -c 20 -s 500 > tmp 2>&1"
    command3="MR_NUMTHREADS=$THREADS ./tests/$program/${program}-pthread -r 25 -c 20 -s 500 > tmp 2>&1"
  elif [ "$program" = "kmeans" ]; then
    program_abbrev="kmeans"
    echo "****************************************** Running $program ************************************************" | tee -a $STAT_LOG_FILE $LOG_FILE $CMD_LOG_FILE
    command1="MR_NUMTHREADS=$THREADS ./tests/$program/$program -d 25 -c 3 -p 200 -s 50 > tmp 2>&1"
    command2="./tests/$program/${program}-seq -d 25 -c 3 -p 200 -s 50 > tmp 2>&1"
    command3="MR_NUMTHREADS=$THREADS ./tests/$program/${program}-pthread -d 25 -c 3 -p 200 -s 50 > tmp 2>&1"
  elif [ "$program" = "word_count" ]; then
    program_abbrev="wc-$2"
    test_file="word_$2.txt"
    echo "****************************************** Running $program with $test_file ************************************************" | tee -a $STAT_LOG_FILE $LOG_FILE $CMD_LOG_FILE
    command1="MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command2="./tests/$program/${program}-seq ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
    command3="MR_NUMTHREADS=$THREADS ./tests/$program/${program}-pthread ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1"
  else "$program is not a valid program. Aborting."
    exit
  fi
  echo -ne "$program_abbrev\t1\t" >> $MR_OUT
  echo -ne "$program_abbrev\t1\t" >> $SEQ_OUT
  echo -ne "$program_abbrev\t1\t" >> $PTHREAD_OUT
  echo "Original Instrumentation:" | tee -a $STAT_LOG_FILE
  echo "Building for original mode of $program" | tee -a $CMD_LOG_FILE $LOG_FILE > /dev/null
  rm -f lib/libphoenix.a ./tests/$program/${program} ./tests/$program/${program}-seq ./tests/$program/${program}-pthread
  make clean -C src -f Makefile.orig >> $CMD_LOG_FILE 2>>$LOG_FILE
  make -C tests -f Makefile.orig $program-clean >> $CMD_LOG_FILE 2>>$LOG_FILE
  make -C src -f Makefile.orig >> $CMD_LOG_FILE 2>>$LOG_FILE
  make -C tests -f Makefile.orig $program >> $CMD_LOG_FILE 2>>$LOG_FILE

  #echo "With Map Reduce:-" | tee -a $STAT_LOG_FILE
  #echo "command: $command1"
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $NUMBER_OF_RUNS`
  do
    eval $command1
    #MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1
    #grep "$program runtime:" tmp
    mr_orig_runtime=`grep "$program runtime:" tmp | cut -d: -f 2 | cut -d' ' -f 2`
    echo $mr_orig_runtime | tr -d '\n' >> sum
    if [ $j -lt $NUMBER_OF_RUNS ]; then
      echo -n "+" >> sum
    fi
  done 
  echo ")/$NUMBER_OF_RUNS" >> sum
  mr_orig_runtime=`cat sum | bc`
  echo "Mean of MR original runtime: "$mr_orig_runtime | tee -a $STAT_LOG_FILE

  #echo "With Sequential:-" | tee -a $STAT_LOG_FILE
  #echo "command: $command2"
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $NUMBER_OF_RUNS`
  do
    eval $command2
    #./tests/$program/$program-seq ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1
    #grep "$program runtime:" tmp
    seq_orig_runtime=`grep "$program runtime:" tmp | cut -d: -f 2 | cut -d' ' -f 2`
    echo $seq_orig_runtime | tr -d '\n' >> sum
    if [ $j -lt $NUMBER_OF_RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$NUMBER_OF_RUNS" >> sum
  seq_orig_runtime=`cat sum | bc`
  echo "Mean of Sequential original runtime: "$seq_orig_runtime | tee -a $STAT_LOG_FILE

  #echo "With PThreads:-" | tee -a $STAT_LOG_FILE
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $NUMBER_OF_RUNS`
  do
    eval $command3
    #MR_NUMTHREADS=$THREADS ./tests/$program/$program-pthread ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1
    #grep "$program runtime:" tmp
    pthread_orig_runtime=`grep "$program runtime:" tmp | cut -d: -f 2 | cut -d' ' -f 2`
    echo $pthread_orig_runtime | tr -d '\n' >> sum
    if [ $j -lt $NUMBER_OF_RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$NUMBER_OF_RUNS" >> sum
  pthread_orig_runtime=`cat sum | bc`
  echo "Mean of Pthread original runtime: "$pthread_orig_runtime | tee -a $STAT_LOG_FILE

  echo ""
  echo "Naive Instrumentation:" | tee -a $STAT_LOG_FILE
  echo "Building for naive mode of $program" | tee -a $CMD_LOG_FILE $LOG_FILE > /dev/null
  rm -f lib/libphoenix.a ./tests/$program/${program} ./tests/$program/${program}-seq ./tests/$program/${program}-pthread
  make clean -C src -f Makefile.lc >> $CMD_LOG_FILE 2>>$LOG_FILE
  make -C tests -f Makefile.lc $program-clean >> $CMD_LOG_FILE 2>>$LOG_FILE
  ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -C src -f Makefile.lc >> $CMD_LOG_FILE 2>>$LOG_FILE
  ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -C tests -f Makefile.lc $program >> $CMD_LOG_FILE 2>>$LOG_FILE

  #echo "With Map Reduce:-" | tee -a $STAT_LOG_FILE
  #echo "command: $command1"
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $NUMBER_OF_RUNS`
  do
    eval $command1
    #MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1
    #grep "$program runtime:" tmp
    mr_naive_runtime=`grep "$program runtime:" tmp | cut -d: -f 2 | cut -d' ' -f 2`
    echo $mr_naive_runtime | tr -d '\n' >> sum
    if [ $j -lt $NUMBER_OF_RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$NUMBER_OF_RUNS" >> sum
  mr_naive_runtime=`cat sum | bc`
  echo "Mean of MR naive runtime: "$mr_naive_runtime | tee -a $STAT_LOG_FILE

  #echo "With Sequential:-" | tee -a $STAT_LOG_FILE
  #echo "command: $command2"
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $NUMBER_OF_RUNS`
  do
    eval $command2
    #./tests/$program/$program-seq ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1
    #grep "$program runtime:" tmp
    seq_naive_runtime=`grep "$program runtime:" tmp | cut -d: -f 2 | cut -d' ' -f 2`
    echo $seq_naive_runtime | tr -d '\n' >> sum
    if [ $j -lt $NUMBER_OF_RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$NUMBER_OF_RUNS" >> sum
  seq_naive_runtime=`cat sum | bc`
  echo "Mean of Sequential naive runtime: "$seq_naive_runtime | tee -a $STAT_LOG_FILE

  #echo "With PThreads:-" | tee -a $STAT_LOG_FILE
  #echo "command: $command3"
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $NUMBER_OF_RUNS`
  do
    eval $command3
    #MR_NUMTHREADS=$THREADS ./tests/$program/$program-pthread ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1
    #grep "$program runtime:" tmp
    pthread_naive_runtime=`grep "$program runtime:" tmp | cut -d: -f 2 | cut -d' ' -f 2`
    echo $pthread_naive_runtime | tr -d '\n' >> sum
    if [ $j -lt $NUMBER_OF_RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$NUMBER_OF_RUNS" >> sum
  pthread_naive_runtime=`cat sum | bc`
  echo "Mean of Pthread naive runtime: "$pthread_naive_runtime | tee -a $STAT_LOG_FILE


  echo ""
  echo "Optimized Instrumentation:" | tee -a $STAT_LOG_FILE
  echo "Building for opt mode of $program" | tee -a $CMD_LOG_FILE $LOG_FILE > /dev/null
  rm -f lib/libphoenix.a ./tests/$program/${program} ./tests/$program/${program}-seq ./tests/$program/${program}-pthread
  make clean -C src -f Makefile.lc >> $CMD_LOG_FILE 2>>$LOG_FILE
  make -C tests -f Makefile.lc $program-clean >> $CMD_LOG_FILE 2>>$LOG_FILE
  ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -C src -f Makefile.lc >> $CMD_LOG_FILE 2>>$LOG_FILE
  ALLOWED_DEVIATION=$AD CLOCK=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -C tests -f Makefile.lc $program >> $CMD_LOG_FILE 2>>$LOG_FILE

  #echo "With Map Reduce:-" | tee -a $STAT_LOG_FILE
  #echo "command: $command1"
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $NUMBER_OF_RUNS`
  do
    eval $command1
    #MR_NUMTHREADS=$THREADS ./tests/$program/$program ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1
    #grep "$program runtime:" tmp
    mr_opt_runtime=`grep "$program runtime:" tmp | cut -d: -f 2 | cut -d' ' -f 2`
    echo $mr_opt_runtime | tr -d '\n' >> sum
    if [ $j -lt $NUMBER_OF_RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$NUMBER_OF_RUNS" >> sum
  mr_opt_runtime=`cat sum | bc`
  echo "Mean of MR optimal runtime: "$mr_opt_runtime | tee -a $STAT_LOG_FILE

  #echo "With Sequential:-" | tee -a $STAT_LOG_FILE
  #echo "command: $command2"
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $NUMBER_OF_RUNS`
  do
    eval $command2
    #./tests/$program/$program-seq ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1
    #grep "$program runtime:" tmp
    seq_opt_runtime=`grep "$program runtime:" tmp | cut -d: -f 2 | cut -d' ' -f 2`
    echo $seq_opt_runtime | tr -d '\n' >> sum
    if [ $j -lt $NUMBER_OF_RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$NUMBER_OF_RUNS" >> sum
  seq_opt_runtime=`cat sum | bc`
  echo "Mean of Sequential optimal runtime: "$seq_opt_runtime | tee -a $STAT_LOG_FILE

  #echo "With PThreads:-" | tee -a $STAT_LOG_FILE
  #echo "command: $command3"
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $NUMBER_OF_RUNS`
  do
    eval $command3
    #MR_NUMTHREADS=$THREADS ./tests/$program/$program-pthread ../input_datasets/${program}_datafiles/$test_file > tmp 2>&1
    #grep "$program runtime:" tmp
    pthread_opt_runtime=`grep "$program runtime:" tmp | cut -d: -f 2 | cut -d' ' -f 2`
    echo $pthread_opt_runtime | tr -d '\n' >> sum
    if [ $j -lt $NUMBER_OF_RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$NUMBER_OF_RUNS" >> sum
  pthread_opt_runtime=`cat sum | bc`
  echo "Mean of Pthread optimal runtime: "$pthread_opt_runtime | tee -a $STAT_LOG_FILE

  # Calculation of speedup & slowdown
  echo ""
  echo "Map reduce method runtime:- original $mr_orig_runtime, naive $mr_naive_runtime, opt $mr_opt_runtime" | tee -a $STAT_LOG_FILE
  mr_speedup_naive=`echo "scale = 3; (($mr_naive_runtime - $mr_opt_runtime) * 100 / $mr_orig_runtime)" | bc -l`
  mr_slowdown_orig=`echo "scale = 3; (($mr_opt_runtime - $mr_orig_runtime) * 100 / $mr_orig_runtime)" | bc -l`
  mr_naive_slowdown_orig=`echo "scale = 3; (($mr_naive_runtime - $mr_orig_runtime) * 100 / $mr_orig_runtime)" | bc -l`
  mr_normalized_opt=`echo "scale = 3; ($mr_opt_runtime / $mr_orig_runtime)" | bc -l`
  mr_normalized_naive=`echo "scale = 3; ($mr_naive_runtime / $mr_orig_runtime)" | bc -l`
  echo -e "$mr_normalized_opt\t$mr_normalized_naive" >> $MR_OUT
  echo "Speedup over naive instrumentation: $mr_speedup_naive%" | tee -a $STAT_OUT_FILE $STAT_LOG_FILE
  echo "Slowdown of optimal over original instrumentation: $mr_slowdown_orig%" | tee -a $STAT_OUT_FILE $STAT_LOG_FILE
  echo "Slowdown of naive over original instrumentation: $mr_naive_slowdown_orig%" | tee -a $STAT_OUT_FILE $STAT_LOG_FILE
  echo ""

  echo "Sequential method runtime:- original $seq_orig_runtime, naive $seq_naive_runtime, opt $seq_opt_runtime" | tee -a $STAT_LOG_FILE
  seq_speedup_naive=`echo "scale = 3; (($seq_naive_runtime - $seq_opt_runtime) * 100 / $seq_orig_runtime)" | bc -l`
  seq_slowdown_orig=`echo "scale = 3; (($seq_opt_runtime - $seq_orig_runtime) * 100 / $seq_orig_runtime)" | bc -l`
  seq_naive_slowdown_orig=`echo "scale = 3; (($seq_naive_runtime - $seq_orig_runtime) * 100 / $seq_orig_runtime)" | bc -l`
  seq_normalized_opt=`echo "scale = 3; ($seq_opt_runtime / $seq_orig_runtime)" | bc -l`
  seq_normalized_naive=`echo "scale = 3; ($seq_naive_runtime / $seq_orig_runtime)" | bc -l`
  echo -e "$seq_normalized_opt\t$seq_normalized_naive" >> $SEQ_OUT
  echo "Speedup over naive instrumentation: $seq_speedup_naive%" | tee -a $STAT_OUT_FILE $STAT_LOG_FILE
  echo "Slowdown of optimal over original instrumentation: $seq_slowdown_orig%" | tee -a $STAT_OUT_FILE $STAT_LOG_FILE
  echo "Slowdown of naive over original instrumentation: $seq_naive_slowdown_orig%" | tee -a $STAT_OUT_FILE $STAT_LOG_FILE
  echo ""

  echo "Pthread method runtime:- original $pthread_orig_runtime, naive $pthread_naive_runtime, opt $pthread_opt_runtime" | tee -a $STAT_LOG_FILE
  pthread_speedup_naive=`echo "scale = 3; (($pthread_naive_runtime - $pthread_opt_runtime) * 100 / $pthread_orig_runtime)" | bc -l`
  pthread_slowdown_orig=`echo "scale = 3; (($pthread_opt_runtime - $pthread_orig_runtime) * 100 / $pthread_orig_runtime)" | bc -l`
  pthread_naive_slowdown_orig=`echo "scale = 3; (($pthread_naive_runtime - $pthread_orig_runtime) * 100 / $pthread_orig_runtime)" | bc -l`
  pthread_normalized_opt=`echo "scale = 3; ($pthread_opt_runtime / $pthread_orig_runtime)" | bc -l`
  pthread_normalized_naive=`echo "scale = 3; ($pthread_naive_runtime / $pthread_orig_runtime)" | bc -l`
  echo -e "$pthread_normalized_opt\t$pthread_normalized_naive" >> $PTHREAD_OUT
  echo "Speedup over naive instrumentation: $pthread_speedup_naive%" | tee -a $STAT_OUT_FILE $STAT_LOG_FILE
  echo "Slowdown of optimal over original instrumentation: $pthread_slowdown_orig%" | tee -a $STAT_OUT_FILE $STAT_LOG_FILE
  echo "Slowdown of naive over original instrumentation: $pthread_naive_slowdown_orig%" | tee -a $STAT_OUT_FILE $STAT_LOG_FILE
}

echo "This script must be run in superuser mode!!!"

mkdir -p $DIR

if [ $# -eq 0 ]; then
  run_test kmeans
  run_test pca
  run_test matrix_multiply
  run_test histogram small
  run_test histogram med
  run_test histogram large
  run_test linear_regression 50MB
  run_test linear_regression 100MB
  run_test linear_regression 500MB
  run_test string_match 50MB
  run_test string_match 100MB
  run_test string_match 500MB
  run_test word_count 10MB
  run_test word_count 50MB
  run_test word_count 100MB
else
  run_test $1 $2
fi
