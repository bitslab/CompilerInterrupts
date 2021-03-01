#!/bin/bash

# This file runs with the experimental Logical Pass version that uses different kinds of configurable instrumentations
FULL_STAT_FILE="full_stats.csv"
LOG_FILE="out.log"
ERROR_FILE="error.log"
NUMBER_OF_RUNS=2

rm -f $FULL_STAT_FILE $STAT_FILE $LOG_FILE $ERROR_FILE out
echo "Running benchmark for BARNES"

run_orig() {
ORIG_STAT_FILE="barnes_orig_stats.csv"
rm -f $ORIG_STAT_FILE
# Run original
echo "Running Original Program" | tee -a $LOG_FILE $ERROR_FILE 
make clean > /dev/null
make > /dev/null 2>>$ERROR_FILE
max=64
threads=1
echo "ORIG" >> $ORIG_STAT_FILE
DIVISOR=`expr $NUMBER_OF_RUNS \* 1000`
while [ $threads -lt $max ];
do
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $NUMBER_OF_RUNS`
  do
    ./BARNES < input.$threads > out 2>/dev/null
    time_in_us=`cat out | grep "COMPUTETIME   =" | cut -d '=' -f 2 | tr -d '[:space:]'`
    echo $time_in_us | tr -d '\n' >> sum
    cat out >> $LOG_FILE
    if [ $j -lt $NUMBER_OF_RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$DIVISOR" >> sum
  time_in_us=`cat sum | bc`
  echo "$threads,$time_in_us" >> $ORIG_STAT_FILE
  echo "$threads --> $time_in_us ms"
  threads=`expr $threads \* 2`
done

echo ""
}

run_opt() {
PREFIX="barnes_bb_all_"
case "$1" in
  0)
    STAT_FILE=$PREFIX"push_only.csv"
    rm -f $STAT_FILE
    echo "\"NO-LC-MULT-MC\"" > $STAT_FILE
    ;;
  1)
    STAT_FILE=$PREFIX"commit_push_tl_lc.csv"
    rm -f $STAT_FILE
    echo "\"TL-LC-MULT-MC\"" > $STAT_FILE
    ;;
  2)
    STAT_FILE=$PREFIX"commit_push_stack_lc.csv"
    rm -f $STAT_FILE
    echo "\"PASSED-LC-MULT-MC\"" > $STAT_FILE
    ;;
  3)
    STAT_FILE=$PREFIX"singleMLC_push_only.csv"
    rm -f $STAT_FILE
    echo "\"NO-LC-SINGLE-MC\"" > $STAT_FILE
    ;;
  4)
    STAT_FILE=$PREFIX"singleMLC_commit_push_tl_lc.csv"
    rm -f $STAT_FILE
    echo "\"TL-LC-SINGLE-MC\"" > $STAT_FILE
    ;;
  5)
    STAT_FILE=$PREFIX"singleMLC_commit_push_stack_lc.csv"
    rm -f $STAT_FILE
    echo "\"PASSED-LC-SINGLE-MC\"" > $STAT_FILE
    ;;
esac
# Run optimistic
DIVISOR=`expr $NUMBER_OF_RUNS \* 1000`
echo "Optimistically Instrumented Program Runtime in level $1"
make clean -f Makefile.single.lc > /dev/null
ALLOWED_DEVIATION=0 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=$1 make -f Makefile.single.lc > /dev/null 2>>$ERROR_FILE
max=64
threads=1
while [ $threads -lt $max ];
do
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $NUMBER_OF_RUNS`
  do
    ./BARNES < input.$threads > out
    time_in_us=`cat out | grep "COMPUTETIME   =" | cut -d '=' -f 2 | tr -d '[:space:]'`
    echo $time_in_us | tr -d '\n' >> sum
    cat out >> $LOG_FILE
    if [ $j -lt $NUMBER_OF_RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$DIVISOR" >> sum
  time_in_us=`cat sum | bc`
  echo "$threads,$time_in_us" >> $STAT_FILE
  echo "$threads --> $time_in_us ms"
  threads=`expr $threads \* 2`
done

echo ""
}

run_orig
run_opt 0
run_opt 1
run_opt 2
run_opt 3
run_opt 4
run_opt 5
rm -f out
