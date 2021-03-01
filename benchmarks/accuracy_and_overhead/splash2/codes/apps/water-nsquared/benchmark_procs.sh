#!/bin/bash

ORIG_STAT_FILE="orig_stats.csv"
FULL_STAT_FILE="full_stats.csv"
STAT_FILE="stats.csv"
LOG_FILE="out.log"
ERROR_FILE="error.log"

rm -f $ORIG_STAT_FILE $FULL_STAT_FILE $STAT_FILE $LOG_FILE $ERROR_FILE out
echo "Running benchmark for WATER-NS"

# Run original
echo "Running Original Program" | tee -a $LOG_FILE $ERROR_FILE 
make clean > /dev/null
make > /dev/null 2>>$ERROR_FILE
max=64
threads=1
echo "Original Program" >> $ORIG_STAT_FILE
while [ $threads -lt $max ];
do
  echo "./WATER-NSQUARED < input.$threads > out"
  ./WATER-NSQUARED < input.$threads > out
  time_in_us=`cat out | grep "COMPUTETIME (after initialization) = " | cut -d '=' -f 2 | tr -d '[:space:]'`
  cat out >> $LOG_FILE
  echo "$threads,$time_in_us" >> $ORIG_STAT_FILE
  echo "$threads --> $time_in_us usec"
  threads=`expr $threads \* 2`
done

echo ""

# Run optimistic
echo "Optimistically Instrumented Program Runtime: "$time_in_us" usec"
make clean -f Makefile.single.lc > /dev/null
ALLOWED_DEVIATION=0 PUSH_INTV=5000 CMMT_INTV=1000 INST_LEVEL=1 make -f Makefile.single.lc > /dev/null 2>>$ERROR_FILE
max=64
threads=1
echo "Optimistic" >> $STAT_FILE
while [ $threads -lt $max ];
do
  #if [ $threads -eq 1 ]; then
  #  threads=`expr $threads + 7`
  #else
  #  threads=`expr $threads + 8`
  #fi
  ./WATER-NSQUARED < input.$threads > out
  time_in_us=`cat out | grep "COMPUTETIME (after initialization) = " | cut -d '=' -f 2 | tr -d '[:space:]'`
  cat out >> $LOG_FILE
  echo "$threads,$time_in_us" >> $STAT_FILE
  echo "$threads --> $time_in_us usec"
  threads=`expr $threads \* 2`
done

echo ""

# Run full instrumentation
echo "Running Instrumented Program with every instruction instrumentation" | tee -a $LOG_FILE $ERROR_FILE 
make clean -f Makefile.single.lc > /dev/null
INST_LEVEL=3 make -f Makefile.single.lc > /dev/null 2>>$ERROR_FILE
max=64
threads=1
echo "Full Instrumentation" >> $FULL_STAT_FILE
while [ $threads -lt $max ];
do
  ./WATER-NSQUARED < input.$threads > out
  time_in_us=`cat out | grep "COMPUTETIME (after initialization) = " | cut -d '=' -f 2 | tr -d '[:space:]'`
  cat out >> $LOG_FILE
  echo "$threads,$time_in_us" >> $FULL_STAT_FILE
  echo "$threads --> $time_in_us usec"
  threads=`expr $threads \* 2`
done

echo ""

rm -f out
exit

