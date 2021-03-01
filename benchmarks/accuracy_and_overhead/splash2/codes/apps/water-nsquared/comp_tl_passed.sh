#!/bin/bash

BENCHMARK="water_ns_"
LOG_FILE=$BENCHMARK"out.log"
PI=5000
CI=1000
AD=0
NUMBER_OF_RUNS="${RUNS:-20}"

run_orig() {
  # Running with no instrumentation
  echo "Running original program" | tee -a $LOG_FILE
  THREADS="2 4 8 16 32"
  STAT_FILE=$BENCHMARK"stats_orig.csv"
  rm -f $STAT_FILE
  make clean > /dev/null 2>&1
  make > /dev/null 2>&1
  DIVISOR=`expr $NUMBER_OF_RUNS \* 1000`
  for t in $THREADS
  do
    echo -n "scale=2;(" > sum
    echo "$t Threads" | tee -a $LOG_FILE
    for j in `seq 1 $NUMBER_OF_RUNS`
    do
      ./WATER-NSQUARED < input.$t > out
      time_in_us=`cat out | grep "COMPUTETIME (after initialization) = " | cut -d '=' -f 2 | tr -d '[:space:]'`
      echo "$time_in_us" | tee -a $LOG_FILE
      echo $time_in_us | tr -d '\n' >> sum
      if [ $j -lt $NUMBER_OF_RUNS ]; then
        echo -n "+" >> sum
      fi
    done
    echo ")/$DIVISOR" >> sum
    time_in_us=`cat sum | bc`
    echo "Orig mean time: $time_in_us ms" | tee -a $LOG_FILE
    echo "$t,$time_in_us" >> $STAT_FILE
  done
}

run_naive() {
  # Running in naive instrumentation level
  echo "Running every basic block instrumented program with configuration $1" | tee -a $LOG_FILE
  THREADS="2 4 8 16 32"
  STAT_FILE=$BENCHMARK"stats_$1.csv"
  rm -f $STAT_FILE
  make clean -f Makefile.single.lc > /dev/null 2>&1
  echo "INST_LEVEL=3 CONFIG=$1 make -f Makefile.single.lc" >> $LOG_FILE
  INST_LEVEL=3 CONFIG=$1 make -f Makefile.single.lc > /dev/null 2>&1
  DIVISOR=`expr $NUMBER_OF_RUNS \* 1000`
  for t in $THREADS
  do
    echo -n "scale=2;(" > sum
    echo "$t Threads" | tee -a $LOG_FILE
    for j in `seq 1 $NUMBER_OF_RUNS`
    do
      ./WATER-NSQUARED < input.$t > out
      time_in_us=`cat out | grep "COMPUTETIME (after initialization) = " | cut -d '=' -f 2 | tr -d '[:space:]'`
      echo "$time_in_us" | tee -a $LOG_FILE
      echo $time_in_us | tr -d '\n' >> sum
      if [ $j -lt $NUMBER_OF_RUNS ]; then
        echo -n "+" >> sum
      fi
    done
    echo ")/$DIVISOR" >> sum
    time_in_us=`cat sum | bc`
    echo "Mean time: $time_in_us ms"| tee -a $LOG_FILE
    echo "$t,$time_in_us" >> $STAT_FILE
    naive_time=$time_in_us
  done
}

rm -f $LOG_FILE
run_orig
run_naive 3
run_naive 2
rm -f out
