#!/bin/bash

CLOCK=1
intervals="500 1000 5000 10000 15000 25000 50000"

get_time() {
  rm -f out
  RUNS=20
  THREADS=32

  DIVISOR=`expr $RUNS \* 1000`
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $RUNS`
  do
    case "$1" in
      water-ns)
        cd water-nsquared > /dev/null
        if [ $2 -eq 0 ]; then
          taskset 0x00000001 ./WATER-NSQUARED < input.$THREADS > ../out
        else
          ./WATER-NSQUARED < input.$THREADS > ../out
        fi
        cd - > /dev/null
      ;;
    esac
    time_in_us=`cat out | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    echo $time_in_us | tr -d '\n' >> sum
    echo "$time_in_us us" >> $DEBUG_FILE
    if [ $j -lt $RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$DIVISOR" >> sum
  time_in_ms=`cat sum | bc`
  echo "Average: $time_in_ms ms" >> $DEBUG_FILE
  echo $time_in_ms
}

run_pthread() {
  echo "Building original program with pthread" | tee -a make_error make_log
  make -f Makefile.orig water-ns-clean ; make -f Makefile.orig
  echo "Running original program with pthread" | tee -a make_error make_log
  opt_time=$(get_time water-ns 0)
  echo -e "\"PThreads\"" | tee -a $STAT_FILE
  for int in $intervals
  do
    echo -e "$int\t$opt_time" | tee -a $STAT_FILE
  done
  echo "" >> $STAT_FILE
  echo "" >> $STAT_FILE
  echo "" >> $STAT_FILE
}

run_orig() {
  echo "Building original program with libfiber" | tee -a make_error make_log
  make -f Makefile.orig.libfiber water-ns-clean ; make -f Makefile.orig.libfiber
  echo "Running original program with libfiber" | tee -a make_error make_log
  opt_time=$(get_time water-ns 1)
  echo -e "\"Green threads - no yield\"" | tee -a $STAT_FILE
  for int in $intervals
  do
    echo -e "$int\t$opt_time" | tee -a $STAT_FILE
  done
  echo "" >> $STAT_FILE
  echo "" >> $STAT_FILE
  echo "" >> $STAT_FILE
}

run_opt() {
  echo "Building compiler instrumented program with libfiber & push interval $1" | tee -a make_error make_log
  make -f Makefile.lc.libfiber water-ns-clean ; PUSH_INTV=$1 CLOCK_TYPE=$CLOCK make -f Makefile.lc.libfiber
  echo "Running compiler instrumented program with libfiber & push interval $1" | tee -a make_error make_log
  opt_time=$(get_time water-ns 1)
  echo -e "$1\t$opt_time" | tee -a $STAT_FILE
}

STAT_FILE="instantaneous_stats/fiber_exp_stats.txt"
DEBUG_FILE="make_log"
rm -f make_error make_log $STAT_FILE


echo -e "\"Green Threads - yield at intervals\"" | tee -a $STAT_FILE
for int in $intervals
do
  run_opt $int
done
echo "" >> $STAT_FILE
echo "" >> $STAT_FILE
echo "" >> $STAT_FILE
run_orig
run_pthread
