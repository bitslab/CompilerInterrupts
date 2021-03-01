#!/bin/bash

STAT_FILE="stats.csv"
LOG_FILE="out.log"
ERROR_FILE="error.log"

rm -f $STAT_FILE $LOG_FILE $ERROR_FILE out


# Run original
echo "Running Original Program" | tee -a $LOG_FILE $ERROR_FILE > /dev/null
make clean > /dev/null
make > /dev/null 2>>$ERROR_FILE
./VOLREND 32 inputs/head > out
time_in_us=`cat out | grep "COMPUTETIME (after initialization) = " | cut -d '=' -f 2 | tr -d '[:space:]'`
orig_time=$time_in_us
cat out >> $LOG_FILE
echo "Original,"$time_in_us >> $STAT_FILE
echo "Original Program Runtime: "$time_in_us" usec"
echo ""


# Run full instrumentation
echo "Running Instrumented Program with every basic block instrumentation" | tee -a $LOG_FILE $ERROR_FILE > /dev/null
make clean -f Makefile.single.lc > /dev/null
INST_LEVEL=3 make -f Makefile.single.lc > /dev/null 2>>$ERROR_FILE
./VOLREND 32 inputs/head > out
time_in_us=`cat out | grep "COMPUTETIME (after initialization) = " | cut -d '=' -f 2 | tr -d '[:space:]'`
full_inst_time=$time_in_us
lc=`cat out | grep "Logical Clock:" | cut -d: -f 2`
total_inst=$lc
cat out >> $LOG_FILE
echo "Full,"$time_in_us","$lc >> $STAT_FILE
echo "Every-instruction Instrumented Program Runtime: "$time_in_us" usec, $lc instructions"
echo ""


run_opt() {
  PI=$1
  CI=$2
  AD=$3
  # Run optimised instrumentation with different push & commit intervals
  echo "Running Instrumented Program with optimized instrumentation (PI=$PI CI=$CI)" | tee -a $LOG_FILE $ERROR_FILE > /dev/null

  # Running in optimised debug instrumentation level
  make clean -f Makefile.single.lc > /dev/null
  ALLOWED_DEVIATION=$AD PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=2 make -f Makefile.single.lc > /dev/null 2>>$ERROR_FILE
  ./VOLREND 32 inputs/head > out
  debug_lc=`cat out | grep "Logical Clock:" | cut -d: -f 2`
  commits=`grep "Number of Commit Operations:" out | cut -d: -f2`
  push=`grep "Number of Push Operations:" out | cut -d: -f2`

  # Running in optimised instrumentation level
  make clean -f Makefile.single.lc > /dev/null
  ALLOWED_DEVIATION=$AD PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.single.lc > /dev/null 2>>$ERROR_FILE
  ./VOLREND 32 inputs/head > out
  time_in_us=`cat out | grep "COMPUTETIME (after initialization) = " | cut -d '=' -f 2 | tr -d '[:space:]'`
  lc=`cat out | grep "Logical Clock:" | cut -d: -f 2`

  #if [ $lc -ne $debug_lc ]; then
  #  echo "debug level logical clock ($debug_lc) does not match logical clock ($lc) for instrumented program. aborting."
  #  exit
  #fi

  cat out >> $LOG_FILE
  #echo "P"$PI"C"$CI","$time_in_us","$lc >> $STAT_FILE
  echo "P"$PI"C"$CI","$time_in_us","$lc","$commits","$push >> $STAT_FILE
  echo "Optimistically Instrumented Program Runtime (PI=$PI, CI=$CI, AD=$AD): "$time_in_us" usec, $lc instructions"

  if [ $lc -gt $total_inst ]; then
    err=`echo "scale = 3; (($lc - $total_inst) * 100 / $total_inst)" | bc -l`
    echo "Error in instruction count: $err % (more)"
  else
    err=`echo "scale = 3; (($total_inst - $lc) * 100 / $total_inst)" | bc -l`
    echo "Error in instruction count: $err % (less)"
  fi

  if [ $time_in_us -gt $orig_time ]; then
    err=`echo "scale = 3; ($time_in_us / $orig_time)" | bc -l`
    echo "Slowdown wrt Original time: ${err}x (opt time: $time_in_us, original time: $orig_time)"
  else
    err=`echo "scale = 3; ($orig_time / $time_in_us)" | bc -l`
    echo "Speedup wrt Original time: ${err}x (opt time: $time_in_us, original time: $orig_time)"
  fi

  if [ $time_in_us -lt $full_inst_time ]; then
    err=`echo "scale = 3; ($full_inst_time / $time_in_us)" | bc -l`
    echo "Speedup wrt full instrumentation time: ${err}x (opt time: $time_in_us, full instrumentation time: $full_inst_time)"
  else
    err=`echo "scale = 3; ($time_in_us / $full_inst_time)" | bc -l`
    echo "Slowdown wrt full instrumentation time: ${err}x (opt time: $time_in_us, full instrumentation time: $full_inst_time -->  must be error)"
  fi

  echo "#commits: "$commits", #push: "$push

  echo ""
}

#run_opt 100 10
#run_opt 100 20
#run_opt 500 50
#run_opt 500 100
#run_opt 1000 100
#run_opt 1000 200
#run_opt 1000 500
#run_opt 5000 100
#run_opt 5000 250
#run_opt 5000 500
#run_opt 5000 1000
#run_opt 5000 2500

#run_opt 1000 1000 0
#run_opt 2000 1000 0
#run_opt 3000 1000 0
#run_opt 4000 1000 0
run_opt 5000 500 0
run_opt 5000 1000 0
run_opt 5000 5000 0
#run_opt 6000 1000 0
#run_opt 7000 1000 0
#run_opt 8000 1000 0
#run_opt 9000 1000 0
#run_opt 10000 1000 0

#run_opt 5000 1000 0
#run_opt 5000 1000 50
#run_opt 5000 1000 100
#run_opt 5000 1000 200
#run_opt 10000 1000 500

rm -f out
