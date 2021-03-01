#!/bin/bash
CI=1000
PI=5000
RUNS=10
AD=0
DIR=predictive_stats
CLOCK=0

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_lc() {
  rm -f out
  THREADS=$2

  case "$1" in
    water-ns)
      cd water-nsquared > /dev/null
      ./WATER-NSQUARED < input.$THREADS > ../out
      cd - > /dev/null
    ;;
    water-sp)
      cd water-spatial > /dev/null
      ./WATER-SPATIAL < input.$THREADS > ../out
      cd - > /dev/null
    ;;
    ocean-cp) 
      cd ocean/contiguous_partitions > /dev/null
      ./OCEAN -n130 -p $THREADS -e1e-07 -r20000 -t28800 > ../../out
      cd - > /dev/null
    ;;
    ocean-ncp) 
      cd ocean/non_contiguous_partitions > /dev/null
      ./OCEAN -n130 -p $THREADS -e1e-07 -r20000 -t28800 > ../../out
      cd - > /dev/null
    ;;
    barnes)
      cd barnes > /dev/null
      ./BARNES < input.$THREADS > ../out
      cd - > /dev/null
    ;;
    volrend)
      cd volrend > /dev/null
      ./VOLREND $THREADS inputs/head > ../out
      cd - > /dev/null
    ;;
    fmm)
      cd fmm > /dev/null
      ./FMM < inputs/input.16384.$THREADS > ../out
      cd - > /dev/null
    ;;
    raytrace)
      cd raytrace > /dev/null
      ./RAYTRACE -p $THREADS -m72 inputs/car.env > ../out
      cd - > /dev/null
    ;;
    radiosity)
      cd radiosity > /dev/null
      ./RADIOSITY -p $THREADS -batch -room > ../out
      cd - > /dev/null
    ;;
  esac
}

#1 - benchmarks (one or more bench names)
accuracy_test() {
  echo "===================================== ACCURACY TEST ============================================"
  STAT_FILE="$DIR/accuracy_stats.csv"
  LOG_FILE="$DIR/accuracy_logs.txt"
  BUILD_DEBUG_FILE="$DIR/acc_test_build_log.txt"
  BUILD_ERROR_FILE="$DIR/acc_test_build_error.txt"

  rm -f $STAT_FILE $LOG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
  echo -e "benchmark\tnaive_clock\topt_clock" >> $STAT_FILE

  for bench in $*
  do
    echo "************* $bench ***************" | tee -a $LOG_FILE 
    echo -ne "$bench\t" >> $STAT_FILE

    #run naive
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -f Makefile.lc $bench 
    #Accuracy tests are run with 1 thread
    get_lc $bench 1 
    naive_lc=`cat out | grep "Logical Clock:" | tail -n 1 | cut -d: -f 2`
    echo -ne "\t$naive_lc" >> $STAT_FILE


    #run opt
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench
    #Accuracy tests are run with 1 thread
    get_lc $bench 1 
    opt_lc=`cat out | grep "Logical Clock:" | tail -n 1 | cut -d: -f 2`
    echo -ne "\t$opt_lc" >> $STAT_FILE

    #Print
    echo "Naive LC: $naive_lc" | tee -a $LOG_FILE
    echo "Optimized LC: $opt_lc" | tee -a $LOG_FILE
    if [ $naive_lc -gt $opt_lc ]; then
      err=`echo "scale = 5; (($naive_lc - $opt_lc) * 100 / $naive_lc)" | bc -l`
      echo "Err (in instrument count): $err% less" | tee -a $LOG_FILE
    else
      err=`echo "scale = 5; (($opt_lc - $naive_lc) * 100 / $naive_lc)" | bc -l`
      echo "Err (in instrument count): $err% more" | tee -a $LOG_FILE
    fi

    echo "" >> $STAT_FILE
  done
  rm -f out
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_time() {
  rm -f out
  THREADS=$2

  DIVISOR=`expr $RUNS \* 1000`
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $RUNS`
  do
    case "$1" in
      water-ns)
        cd water-nsquared > /dev/null
        ./WATER-NSQUARED < input.$THREADS > ../out
        cd - > /dev/null
      ;;
      water-sp)
        cd water-spatial > /dev/null
        ./WATER-SPATIAL < input.$THREADS > ../out
        cd - > /dev/null
      ;;
      ocean-cp) 
        cd ocean/contiguous_partitions > /dev/null
        ./OCEAN -n130 -p $THREADS -e1e-07 -r20000 -t28800 > ../../out
        cd - > /dev/null
      ;;
      ocean-ncp) 
        cd ocean/non_contiguous_partitions > /dev/null
        ./OCEAN -n130 -p $THREADS -e1e-07 -r20000 -t28800 > ../../out
        cd - > /dev/null
      ;;
      barnes)
        cd barnes > /dev/null
        ./BARNES < input.$THREADS > ../out
        cd - > /dev/null
      ;;
      volrend)
        cd volrend > /dev/null
        ./VOLREND $THREADS inputs/head > ../out
        cd - > /dev/null
      ;;
      fmm)
        cd fmm > /dev/null
        ./FMM < inputs/input.16384.$THREADS > ../out
        cd - > /dev/null
      ;;
      raytrace)
        cd raytrace > /dev/null
        ./RAYTRACE -p $THREADS -m72 inputs/car.env > ../out 2>/dev/null
        cd - > /dev/null
      ;;
      radiosity)
        cd radiosity > /dev/null
        ./RADIOSITY -p $THREADS -batch -room > ../out
        cd - > /dev/null
      ;;
    esac
    time_in_us=`cat out | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    echo $time_in_us | tr -d '\n' >> sum
    echo "$time_in_us ms" >> $DEBUG_FILE
    if [ $j -lt $RUNS ]; then
      echo -n "+" >> sum
    fi
  done
  echo ")/$DIVISOR" >> sum
  time_in_ms=`cat sum | bc`
  echo "Average: $time_in_ms ms" >> $DEBUG_FILE
  echo $time_in_ms
}

perf_test() {
  echo "=================================== PERFORMANCE TEST ==========================================="
  STAT_FILE="$DIR/perf_stats-$AD.csv"
  LOG_FILE="$DIR/perf_logs-$AD.txt"
  DEBUG_FILE="$DIR/perf_debug-$AD.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log.txt"
  THREADS=1;

  rm -f $STAT_FILE $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
  echo -e "benchmark\torig_clock\tnaive_clock\topt_clock" >> $STAT_FILE

  for bench in $*
  do
    echo "************* $bench ***************" | tee -a $LOG_FILE $DEBUG_FILE 
    echo -ne "$bench\t" >> $STAT_FILE

    #run original 
    echo "Running original program: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench 
    orig_time=$(get_time $bench $THREADS)
    echo -ne "\t$orig_time" >> $STAT_FILE

    #run naive
    echo "Running naive program: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -f Makefile.lc $bench 
    naive_time=$(get_time $bench $THREADS)
    echo -ne "\t$naive_time" >> $STAT_FILE

    #run opt
    echo "Running opt program: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench
    opt_time=$(get_time $bench $THREADS)
    echo -ne "\t$opt_time" >> $STAT_FILE

    #Print
    echo "Original Time: $orig_time ms" | tee -a $LOG_FILE
    echo "Naive Time: $naive_time ms" | tee -a $LOG_FILE
    echo "Optimized Time: $opt_time ms" | tee -a $LOG_FILE
    speedup_naive=`echo "scale = 3; (($naive_time - $opt_time) * 100 / $orig_time)" | bc -l`
    slowdown_opt=`echo "scale = 3; (($opt_time - $orig_time) * 100 / $orig_time)" | bc -l`
    slowdown_naive=`echo "scale = 3; (($naive_time - $orig_time) * 100 / $orig_time)" | bc -l`
    echo "Speedup of optimal instrumentation over naive instrumentation: $speedup_naive%" | tee -a $LOG_FILE
    echo "Slowdown of optimal instrumentation over original program: $slowdown_opt%" | tee -a $LOG_FILE
    echo "Slowdown of naive instrumentation over original program: $slowdown_naive%" | tee -a $LOG_FILE

    echo "" >> $STAT_FILE
  done
}

#1 - benchmark name (optional)
run_accuracy_test() {
  if [ $# -eq 0 ]; then
    accuracy_test water-ns water-sp ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
  else
    accuracy_test $@ 
  fi
}

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test water-ns water-sp ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
  else
    perf_test $@
  fi
}

echo "Note: Script has both accuracy tests & performance tests. Change the mode in the next few lines if any one of them is required only. "
echo "Note: Number of threads for running performance tests need to be configured inside the file" 
mkdir -p $DIR
if [ $# -eq 0 ]; then
  run_accuracy_test
  run_perf_test
else
  run_accuracy_test $@
  run_perf_test $@
fi

rm -f out sum
