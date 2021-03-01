    #!/bin/bash
CI=1000
PI=5000
RUNS=10
AD=100
DIR=splash2_stats
pinning=0
THREADS="1 2 4 8 16 32"

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_lc() {
  rm -f out
  threads=$2
  suffix_conf=$3
  declare suffix
  if [ $suffix_conf -eq 0 ]; then
    suffix="orig"
  else
    suffix="lc"
  fi

  case "$1" in
    water-nsquared)
      cd water-nsquared > /dev/null
      ./water-nsquared-$suffix < input.$threads > ../out
      cd - > /dev/null
    ;;
    water-spatial)
      cd water-spatial > /dev/null
      ./water-spatial-$suffix < input.$threads > ../out
      cd - > /dev/null
    ;;
    ocean-cp) 
      cd ocean/contiguous_partitions > /dev/null
      ./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > ../../out
      cd - > /dev/null
    ;;
    ocean-ncp) 
      cd ocean/non_contiguous_partitions > /dev/null
      ./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > ../../out
      cd - > /dev/null
    ;;
    barnes)
      cd barnes > /dev/null
      ./barnes-$suffix < input.$threads > ../out
      cd - > /dev/null
    ;;
    volrend)
      cd volrend > /dev/null
      ./volrend-$suffix $threads inputs/head > ../out
      cd - > /dev/null
    ;;
    fmm)
      cd fmm > /dev/null
      ./fmm-$suffix < inputs/input.65535.$threads > ../out
      cd - > /dev/null
    ;;
    raytrace)
      cd raytrace > /dev/null
      ./raytrace-$suffix -p $threads -m72 inputs/balls4.env > ../out
      cd - > /dev/null
    ;;
    radiosity)
      cd radiosity > /dev/null
      ./radiosity-$suffix -p $threads -batch -largeroom > ../out
      cd - > /dev/null
    ;;
  esac
}

#1 - benchmarks (one or more bench names)
accuracy_test() {
  echo "===================================== ACCURACY TEST ============================================"
  STAT_FILE="$DIR/accuracy_stats-ad$AD-cl$CLOCK.csv"
  LOG_FILE="$DIR/accuracy_logs-ad$AD-cl$CLOCK.txt"
  BUILD_DEBUG_FILE="$DIR/acc_test_build_log-ad$AD-cl$CLOCK.txt"
  BUILD_ERROR_FILE="$DIR/acc_test_build_error-ad$AD-cl$CLOCK.txt"

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
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench
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
  threads=$2
  suffix_conf=$3
  if [ $suffix_conf -eq 0 ]; then
    suffix="orig"
  else
    suffix="lc"
  fi
  if [ $pinning -eq 1 ]; then
    prefix="timeout 5m taskset 0x00000001 "
  else
    prefix="timeout 5m "
  fi

  DIVISOR=`expr $RUNS \* 1000`
  rm -f sum
  echo -n "scale=2;(" > sum
  for j in `seq 1 $RUNS`
  do
    case "$1" in
      water-nsquared)
        cd water-nsquared > /dev/null
        $prefix ./water-nsquared-$suffix < input.$threads > ../out
        cd - > /dev/null
      ;;
      water-spatial)
        cd water-spatial > /dev/null
        $prefix ./water-spatial-$suffix < input.$threads > ../out
        cd - > /dev/null
      ;;
      ocean-cp) 
        cd ocean/contiguous_partitions > /dev/null
        $prefix ./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > ../../out
        cd - > /dev/null
      ;;
      ocean-ncp) 
        cd ocean/non_contiguous_partitions > /dev/null
        $prefix ./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > ../../out
        cd - > /dev/null
      ;;
      barnes)
        cd barnes > /dev/null
        $prefix ./barnes-$suffix < input.$threads > ../out
        cd - > /dev/null
      ;;
      volrend)
        cd volrend > /dev/null
        $prefix ./volrend-$suffix $threads inputs/head > ../out
        cd - > /dev/null
      ;;
      fmm)
        cd fmm > /dev/null
        $prefix ./fmm-$suffix < inputs/input.65535.$threads > ../out
        cd - > /dev/null
      ;;
      raytrace)
        cd raytrace > /dev/null
        $prefix ./raytrace-$suffix -p $threads -m72 inputs/balls4.env > ../out
        cd - > /dev/null
      ;;
      radiosity)
        cd radiosity > /dev/null
        $prefix ./radiosity-$suffix -p $threads -batch -largeroom > ../out
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
  echo "=================================== PERFORMANCE TEST (CLOCK-$CLOCK) ==========================================="
  LOG_FILE="$DIR/perf_logs-ad$AD-cl$CLOCK.txt"
  DEBUG_FILE="$DIR/perf_debug-ad$AD-cl$CLOCK.txt"
  BUILD_ERROR_FILE="$DIR/perf_test_build_error-ad$AD-cl$CLOCK.txt"
  BUILD_DEBUG_FILE="$DIR/perf_test_build_log-ad$AD-cl$CLOCK.txt"
  #FIBER_CONFIG is set in the Makefile. Unless needed, do not pass a new config from this script

  rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE

  if [ $pinning -eq 1 ]; then
    suffix="-pinned"
  else
    suffix=""
  fi

  for thread in $THREADS
  do
    PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD-cl$CLOCK$suffix.csv"
    echo -e "benchmark\torig_clock\tnaive_clock\topt_clock\torig_fiber_clock\tnaive_fiber_clock\topt_fiber_clock" > $PER_THREAD_STAT_FILE
  done

  for bench in $*
  do
    ORIG_STAT_FILE="$DIR/$bench-perf_orig-ad$AD-cl$CLOCK$suffix.txt"
    OPT_STAT_FILE="$DIR/$bench-perf_opt-ad$AD-cl$CLOCK$suffix.txt"
    NAIVE_STAT_FILE="$DIR/$bench-perf_naive-ad$AD-cl$CLOCK$suffix.txt"
    ORIG_FIBER_STAT_FILE="$DIR/$bench-perf_orig_fiber-ad$AD-cl$CLOCK$suffix.txt"
    OPT_FIBER_STAT_FILE="$DIR/$bench-perf_opt_fiber-ad$AD-cl$CLOCK$suffix.txt"
    NAIVE_FIBER_STAT_FILE="$DIR/$bench-perf_naive_fiber-ad$AD-cl$CLOCK$suffix.txt"
    echo "************* $bench ***************" | tee -a $LOG_FILE $DEBUG_FILE 
    echo "orig"> $ORIG_STAT_FILE
    echo "opt" > $OPT_STAT_FILE
    echo "naive" > $NAIVE_STAT_FILE
    echo "orig-fiber" > $ORIG_FIBER_STAT_FILE
    echo "opt-fiber" > $OPT_FIBER_STAT_FILE
    echo "naive-fiber" > $NAIVE_FIBER_STAT_FILE

    fiber_working=1
    if [ $CLOCK -eq 1 ]; then
      if [ "$bench" = "fmm" ] || [ "$bench" = "barnes" ] || [ "$bench" = "volrend" ] || [ "$bench" = "radiosity" ]; then
        fiber_working=0
      else
        fiber_working=1
      fi
    else
      fiber_working=0
    fi

    #run original 
    echo "Building original program: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig $bench 
    echo "Running original program: " >> $DEBUG_FILE
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD-cl$CLOCK$suffix.csv"
      orig_time=$(get_time $bench $thread 0)
      echo -ne "$bench" >> $PER_THREAD_STAT_FILE
      echo -ne "\t$orig_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$orig_time" >> $ORIG_STAT_FILE
    done

    #run naive
    echo "Building naive program: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -f Makefile.lc $bench 
    echo "Running naive program: " >> $DEBUG_FILE
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD-cl$CLOCK$suffix.csv"
      naive_time=$(get_time $bench $thread 1)
      echo -ne "\t$naive_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$naive_time" >> $NAIVE_STAT_FILE
    done

    #run opt
    echo "Building opt program: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench
    echo "Running opt program: " >> $DEBUG_FILE
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD-cl$CLOCK$suffix.csv"
      opt_time=$(get_time $bench $thread 1)
      echo -ne "\t$opt_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$opt_time" >> $OPT_STAT_FILE
    done

    if [ $fiber_working -eq 1 ]; then
      #run original program with fiber
      echo "Building original pthread program with fiber: " >> $DEBUG_FILE
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig.libfiber $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.orig.libfiber $bench 
      echo "Running original pthread program with fiber: " >> $DEBUG_FILE
      for thread in $THREADS
      do
        PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD-cl$CLOCK$suffix.csv"
        orig_fiber_time=$(get_time $bench $thread 0)
        echo -ne "\t$orig_fiber_time" >> $PER_THREAD_STAT_FILE
        echo -e "$thread\t$orig_fiber_time" >> $ORIG_FIBER_STAT_FILE
      done
    else
      orig_fiber_time="?"
      for thread in $THREADS
      do
        PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD-cl$CLOCK$suffix.csv"
        echo -ne "\t$orig_fiber_time" >> $PER_THREAD_STAT_FILE
      done
    fi

    #run naive clock program with fiber
    echo "Building naive program with fiber: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc.libfiber $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=0 CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=3 make -f Makefile.lc.libfiber $bench
    echo "Running naive program with fiber: " >> $DEBUG_FILE
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD-cl$CLOCK$suffix.csv"
      naive_fiber_time=$(get_time $bench $thread 1)
      echo -ne "\t$naive_fiber_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$naive_fiber_time" >> $NAIVE_FIBER_STAT_FILE
    done

    #run opt program with fiber
    echo "Building opt program with fiber: " >> $DEBUG_FILE
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc.libfiber $bench-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc.libfiber $bench
    echo "Running opt program with fiber: " >> $DEBUG_FILE
    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD-cl$CLOCK$suffix.csv"
      opt_fiber_time=$(get_time $bench $thread 1)
      echo -ne "\t$opt_fiber_time" >> $PER_THREAD_STAT_FILE
      echo -e "$thread\t$opt_fiber_time" >> $OPT_FIBER_STAT_FILE
    done

    for thread in $THREADS
    do
      PER_THREAD_STAT_FILE="$DIR/perf_stats-th$thread-ad$AD-cl$CLOCK$suffix.csv"
      echo "" >> $PER_THREAD_STAT_FILE
      final_thread=$thread
    done

    #Print
    echo "Statistics for $final_thread thread(s)"
    echo "Original Time: $orig_time ms" | tee -a $LOG_FILE
    echo "Naive Time: $naive_time ms" | tee -a $LOG_FILE
    echo "Optimized Time: $opt_time ms" | tee -a $LOG_FILE
    if [ $fiber_working -eq 1 ]; then
      echo "Original Fiber Time: $orig_fiber_time ms" | tee -a $LOG_FILE
    fi
    echo "Naive Fiber Time: $naive_fiber_time ms" | tee -a $LOG_FILE
    echo "Optimized Fiber Time: $opt_fiber_time ms" | tee -a $LOG_FILE

    #speedup_naive=`echo "scale = 3; (($naive_time - $opt_time) * 100 / $orig_time)" | bc -l`
    #slowdown_opt=`echo "scale = 3; (($opt_time - $orig_time) * 100 / $orig_time)" | bc -l`
    #slowdown_naive=`echo "scale = 3; (($naive_time - $orig_time) * 100 / $orig_time)" | bc -l`
    slowdown_opt=`echo "scale = 3; ($opt_time / $orig_time)" | bc -l`
    slowdown_naive=`echo "scale = 3; ($naive_time / $orig_time)" | bc -l`
    slowdown_naive_opt=`echo "scale = 3; ($naive_time / $opt_time)" | bc -l`
    echo "Slowdown of naive instrumentation over opt instrumentation: ${slowdown_naive_opt}x" | tee -a $LOG_FILE
    echo "Slowdown of optimal instrumentation over original program: ${slowdown_opt}x" | tee -a $LOG_FILE
    echo "Slowdown of naive instrumentation over original program: ${slowdown_naive}x" | tee -a $LOG_FILE

    slowdown_fiber_naive_opt=`echo "scale = 3; ($naive_fiber_time / $opt_fiber_time)" | bc -l`
    echo "Slowdown of naive fiber instrumentation over opt instrumentation: ${slowdown_fiber_naive_opt}x" | tee -a $LOG_FILE
    if [ $fiber_working -eq 1 ]; then
      slowdown_fiber_opt=`echo "scale = 3; ($opt_fiber_time / $orig_fiber_time)" | bc -l`
      slowdown_fiber_naive=`echo "scale = 3; ($naive_fiber_time / $orig_fiber_time)" | bc -l`
      echo "Slowdown of optimal fiber instrumentation over original program: ${slowdown_fiber_opt}x" | tee -a $LOG_FILE
      echo "Slowdown of naive fiber instrumentation over original program: ${slowdown_fiber_naive}x" | tee -a $LOG_FILE
    fi
  done
}

#1 - benchmark name (optional)
run_accuracy_test() {
  if [ $# -eq 0 ]; then
    accuracy_test water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
  else
    accuracy_test $@ 
  fi
}

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
    CLOCK=1; perf_test water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
    CLOCK=0; perf_test water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
  else
    CLOCK=1; perf_test $@
    CLOCK=0; perf_test $@
  fi
}

echo "Note: Script has performance tests for both instantaneous & predictive clocks."
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: $THREADS, PINNED?: $pinning, Output Directory: $DIR"
mkdir -p $DIR;

if [ $# -eq 0 ]; then
  #run_accuracy_test
  run_perf_test
else
  #run_accuracy_test $@
  run_perf_test $@
fi

rm -f out sum
