#!/bin/bash
CI=1000
PI="${PI:-"2500 5000 10000 25000 50000 75000 100000 250000 500000 750000 1000000"}"
RUNS="${RUNS:-5}"
AD=100
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-""}"
DIR=$CUR_PATH/parsec_stats/$SUB_DIR
CLOCK=1 #0 - predictive, 1 - instantaneous

LOG_FILE="$DIR/perf_logs-$AD.txt"
DEBUG_FILE="$DIR/perf_debug-$AD.txt"
BUILD_ERROR_FILE="$DIR/perf_test_build_error-$AD.txt"
BUILD_DEBUG_FILE="$DIR/perf_test_build_log-$AD.txt"

dry_run() {
  case "$1" in
    blackscholes)
      cd blackscholes/src > /dev/null
      $prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > /dev/null 2>&1
      echo "$prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    fluidanimate)
      cd fluidanimate/src > /dev/null
      $prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > /dev/null 2>&1
      echo "$prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    swaptions)
      cd swaptions/src > /dev/null
      $prefix ./swaptions$suffix -ns 128 -sm 20000 -nt $threads > /dev/null 2>&1
      echo "$prefix ./swaptions$suffix -ns 128 -sm 20000 -nt $threads > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    canneal)
      cd canneal/src > /dev/null
      $prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > /dev/null 2>&1
      echo "$prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    dedup)
      cd dedup/src > /dev/null
      $prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > /dev/null 2>&1
      echo "$prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
    streamcluster)
      cd streamcluster/src > /dev/null
      $prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > /dev/null 2>&1 
      echo "$prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > /dev/null 2>&1" >> $DEBUG_FILE
    ;;
  esac
  cd - > /dev/null
}

#1 - benchmark name, 2 - #thread
# Do not print anything in this function as a value is returned from this
get_time() {
  threads=1
  suffix_conf=$2
  declare suffix
  if [ $suffix_conf -eq 0 ]; then
    suffix="_llvm"
  else
    suffix="_ci"
  fi

  prefix="timeout 30s"
  dry_run $1

  if [ $3 -eq 1 ]; then
    prefix="timeout 2m taskset 0x00000001 "
  else
    prefix="timeout 2m "
  fi
  OUT_FILE="$DIR/out"
  SUM_FILE="$DIR/sum"
  TMP_FILE="$DIR/tmp"
  INTV_STAT_FILE="$DIR/interval_stats"
  rm -f $OUT_FILE $SUM_FILE $INTV_STAT_FILE

  DIVISOR=`expr $RUNS \* 1000`
  echo -n "scale=2;(" > $SUM_FILE
  net_avg_ic="scale=2;("
  net_avg_tsc="scale=2;("
  for j in `seq 1 $RUNS`
  do
    case "$1" in
      blackscholes)
        cd blackscholes/src > /dev/null
        $prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE
        sleep 0.5
        echo "$prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      fluidanimate)
        cd fluidanimate/src > /dev/null
        $prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE
        sleep 0.5
        echo "$prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      swaptions)
        cd swaptions/src > /dev/null
        $prefix ./swaptions$suffix -ns 32 -sm 100000 -nt $threads > $OUT_FILE
        sleep 0.5
        echo "$prefix ./swaptions$suffix -ns 32 -sm 100000 -nt $threads > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      canneal)
        cd canneal/src > /dev/null
        $prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > $OUT_FILE
        sleep 0.5
        echo "$prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      dedup)
        cd dedup/src > /dev/null
        $prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE
        sleep 0.5
        echo "$prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
      streamcluster)
        cd streamcluster/src > /dev/null
        $prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > $OUT_FILE
        sleep 0.5
        echo "$prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > $OUT_FILE" >> $DEBUG_FILE
        cd - > /dev/null
      ;;
    esac

    time_in_us=`cat $OUT_FILE | grep "$1 runtime: " | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr -d '[:space:]'`
    cat $OUT_FILE | grep "avg_intv_cycles:" > $TMP_FILE

    if [ -s "$TMP_FILE" ]; then
      tsc=`awk -F'[,:]' '{sum1 += ($2 * $4); sum2 += $2} END { if (sum2 > 0) print sum1 / sum2; }' $TMP_FILE`
    fi
    
    if [ -s "$TMP_FILE" ]; then
      ic=`awk -F'[,:]' '{sum1 += ($2 * $6); sum2 += $2} END { if (sum2 > 0) print sum1 / sum2; }' $TMP_FILE`
    fi

    if [ ! -z "$time_in_us" ]; then
      echo $time_in_us | tr -d '\n' >> $SUM_FILE
      echo "$time_in_us us" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        echo -n "+" >> $SUM_FILE
      fi
    fi

    if [ ! -z "$ic" ]; then
      net_avg_ic=$net_avg_ic"$ic"
      echo "$ic IR instructions" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        net_avg_ic=$net_avg_ic"+"
      fi
    fi

    if [ ! -z "$tsc" ]; then
      net_avg_tsc=$net_avg_tsc"$tsc"
      echo "$tsc cycles" >> $DEBUG_FILE
      if [ $j -lt $RUNS ]; then
        net_avg_tsc=$net_avg_tsc"+"
      fi
    fi

  done

  echo ")/$DIVISOR" >> $SUM_FILE
  
  #echo "######### start sum content ###########"
  #cat sum
  #echo "######### end sum content ###########"
  
  time_in_ms=`cat $SUM_FILE | bc`

  if [ ! -z "$time_in_us" ]; then
    echo -n "$time_in_ms"
    echo "Average duration: $time_in_ms ms" >> $DEBUG_FILE
  else
    echo "Average: $time_in_ms ms" >> $DEBUG_FILE
    echo "$time_in_ms"
  fi

  if [ ! -z "$tsc" ]; then
    net_avg_tsc=`echo "$net_avg_tsc)/$RUNS" | bc`
    echo -n ",$net_avg_tsc"
    echo "Average cycles: $net_avg_tsc" >> $DEBUG_FILE
  fi

  if [ ! -z "$ic" ]; then
    net_avg_ic=`echo "$net_avg_ic)/$RUNS" | bc`
    echo ",$net_avg_ic"
    echo "Average instruction count: $net_avg_ic" >> $DEBUG_FILE
  fi
}

read_tune_param() {
  cycle=$3
  case "$2" in
    2) ci_type="opt-tl";;
    4) ci_type="naive-tl";;
    6) ci_type="cd-tl";;
    8) ci_type="legacy-acc";;
    9) ci_type="opt-acc";;
    10) ci_type="legacy-tl";;
    11) ci_type="naive-acc";;
    12) ci_type="opt-int";;
    13) ci_type="naive-int";;
    *)
      echo "Wrong CI Type"
      exit
    ;;
  esac
  if [ $2 -eq 8 ]; then
    intv=5000
  else
#tune_file="./${ci_type}-tuning-${CYCLE}.txt"
    tune_file="../${ci_type}-tuning-5000.txt"
    while read line; do
      present=`echo $line | grep $1 | wc -l`
      if [ $present -eq 1 ]; then
        intv5000=`echo $line | cut -d' ' -f 2`
        break
      fi
    done < $tune_file
    intv=`echo "($intv5000*$cycle)/5000" | bc`
    echo "cycle: $cycle, push intv: $intv, push intv for 5000 cycle: $intv5000" | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE > /dev/null
  fi
  echo $intv
}

perf_test() {
  echo "=================================== PERFORMANCE TEST ==========================================="
  declare final_thread

  for bench in $*
  do
    BENCH_DIR=""
    case "$bench" in
    "canneal" | "dedup" | "streamcluster")
      BENCH_DIR="kernels"
      ;;
    *)
      BENCH_DIR="apps"
      ;;
    esac

    cd $BENCH_DIR
    PER_BENCH_ORIG_STAT_FILE="$DIR/$bench-perf_orig-ad$AD-cl$CLOCK.txt"
    PER_BENCH_PAPI_STAT_FILE="$DIR/$bench-perf_papi-ad$AD-cl$CLOCK.txt"
    PER_BENCH_LC_STAT_FILE="$DIR/$bench-perf_lc-ad$AD-cl$CLOCK.txt"
    PER_BENCH_LC_CYCLES_STAT_FILE="$DIR/$bench-perf_lc_cycles-ad$AD-cl$CLOCK.txt"
    echo "********************** $bench ********************" | tee -a $LOG_FILE $DEBUG_FILE 
    echo "Runtime" > $PER_BENCH_ORIG_STAT_FILE
    echo -e "TI\tRuntime\tTSC" > $PER_BENCH_PAPI_STAT_FILE
    echo -e "TI\tRuntime\tTSC\tIC" > $PER_BENCH_LC_STAT_FILE
    echo -e "TI\tRuntime\tTSC\tIC" > $PER_BENCH_LC_CYCLES_STAT_FILE
    echo -e "Interval(IR)\tOrig_Runtime\tCI_Runtime\tHI_Runtime\tCI_TSC\tCI_IC\tHI_TSC" > $LOG_FILE

    #1. Build original program with pthread
    echo "Building original pthread program: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.llvm ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.llvm ${bench} 
    orig_time=$(get_time $bench 0 0)
    echo "$orig_time" >> $PER_BENCH_ORIG_STAT_FILE
    echo "Orig Runtime: $orig_time" | tee -a $DEBUG_FILE > /dev/null

    for pi in $PI
    do
      #2. Build original program with Periodic CI
      CI_SETTING=2
      AD=100
      pi_IR=$(read_tune_param $bench $CI_SETTING $pi)
      CI=`echo "scale=0; $pi_IR/5" | bc`

      echo "Building original program with Periodic CI, Cycles:$pi, PI:$pi_IR, CI:$CI : " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$pi_IR CMMT_INTV=$CI CYCLE_INTV=$pi INST_LEVEL=$CI_SETTING PROFILE_FLAGS="-DAVG_STATS -DPERF_CNTR" make -f Makefile.ci ${bench} 
      lc_stats=$(get_time $bench 1 0)
      lc_periodic_time=`echo "$lc_stats" | cut -d ',' -f 1`
      lc_avg_tsc=`echo "$lc_stats" | cut -d ',' -f 2`
      lc_avg_ic=`echo "$lc_stats" | cut -d ',' -f 3`

      echo -ne "$pi" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE > /dev/null

      if [ ! -z "$lc_periodic_time" ]; then
        echo -ne "\t$lc_periodic_time" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE > /dev/null
      else
        echo -ne "\t?" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE > /dev/null
      fi

      if [ ! -z "$lc_avg_tsc" ]; then
        echo -ne "\t$lc_avg_tsc" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE > /dev/null
      else
        echo -ne "\t?" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE > /dev/null
      fi

      if [ ! -z "$lc_avg_ic" ]; then
        echo -e "\t$lc_avg_ic" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE > /dev/null
      else
        echo -e "\t?" | tee -a $PER_BENCH_LC_STAT_FILE $DEBUG_FILE > /dev/null
      fi

      #2. Build original program with Periodic CI
      CI_SETTING=12
      AD=100
      pi_IR=$(read_tune_param $bench $CI_SETTING $pi)
      CI=`echo "scale=0; $pi_IR/5" | bc`

      echo "Building original program with Periodic CI-Cycles, Cycles:$pi, PI:$pi_IR, CI:$CI : " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=1 PUSH_INTV=$pi_IR CMMT_INTV=$CI CYCLE_INTV=$pi INST_LEVEL=$CI_SETTING PROFILE_FLAGS="-DAVG_STATS -DPERF_CNTR" make -f Makefile.ci ${bench} 
      lc_stats=$(get_time $bench 1 0)
      lc_periodic_time=`echo "$lc_stats" | cut -d ',' -f 1`
      lc_avg_tsc=`echo "$lc_stats" | cut -d ',' -f 2`
      lc_avg_ic=`echo "$lc_stats" | cut -d ',' -f 3`

      echo -ne "$pi" | tee -a $PER_BENCH_LC_CYCLES_STAT_FILE $DEBUG_FILE > /dev/null

      if [ ! -z "$lc_periodic_time" ]; then
        echo -ne "\t$lc_periodic_time" | tee -a $PER_BENCH_LC_CYCLES_STAT_FILE $DEBUG_FILE > /dev/null
      else
        echo -ne "\t?" | tee -a $PER_BENCH_LC_CYCLES_STAT_FILE $DEBUG_FILE > /dev/null
      fi

      if [ ! -z "$lc_avg_tsc" ]; then
        echo -ne "\t$lc_avg_tsc" | tee -a $PER_BENCH_LC_CYCLES_STAT_FILE $DEBUG_FILE > /dev/null
      else
        echo -ne "\t?" | tee -a $PER_BENCH_LC_CYCLES_STAT_FILE $DEBUG_FILE > /dev/null
      fi

      if [ ! -z "$lc_avg_ic" ]; then
        echo -e "\t$lc_avg_ic" | tee -a $PER_BENCH_LC_CYCLES_STAT_FILE $DEBUG_FILE > /dev/null
      else
        echo -e "\t?" | tee -a $PER_BENCH_LC_CYCLES_STAT_FILE $DEBUG_FILE > /dev/null
      fi

      #3. Build original program with PAPI hardware interrupts
      echo "Building original program with PAPI hardware interrupts: " | tee -a $DEBUG_FILE $BUILD_DEBUG_FILE $BUILD_ERROR_FILE >/dev/null
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.llvm ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE PAPI_FLAGS="-lpapi -DCI_PASS -DPAPI -DIC_THRESHOLD=$pi" make -f Makefile.llvm ${bench} 
      papi_stats=$(get_time $bench 0 0)
      papi_periodic_time=`echo "$papi_stats" | cut -d ',' -f 1`
      papi_avg_tsc=`echo "$papi_stats" | cut -d ',' -f 2`

      echo -ne "$pi" | tee -a $PER_BENCH_PAPI_STAT_FILE $DEBUG_FILE > /dev/null
      if [ ! -z "$papi_periodic_time" ]; then
        echo -ne "\t$papi_periodic_time" | tee -a $PER_BENCH_PAPI_STAT_FILE $DEBUG_FILE > /dev/null
      else
        echo -ne "\t?" | tee -a $PER_BENCH_PAPI_STAT_FILE $DEBUG_FILE > /dev/null
      fi

      if [ ! -z "$papi_avg_tsc" ]; then
        echo -e "\t$papi_avg_tsc" | tee -a $PER_BENCH_PAPI_STAT_FILE $DEBUG_FILE > /dev/null
      else
        echo -e "\t?" | tee -a $PER_BENCH_PAPI_STAT_FILE $DEBUG_FILE > /dev/null
      fi

      echo -ne "$pi\t$orig_time\t$lc_periodic_time\t$papi_periodic_time\t" | tee -a $LOG_FILE
      echo -e "\t$lc_avg_tsc\t$lc_avg_ic\t$papi_avg_tsc" | tee -a $LOG_FILE
    done

    cd ../ > /dev/null
  done
}

#1 - benchmark name (optional)
run_perf_test() {
  if [ $# -eq 0 ]; then
    perf_test blackscholes fluidanimate swaptions canneal dedup streamcluster
  else
    perf_test $@
  fi
}

rm -f $LOG_FILE $DEBUG_FILE $BUILD_ERROR_FILE $BUILD_DEBUG_FILE
#echo "Note: Script has both accuracy tests & performance tests. Change the mode in the next few lines if any one of them is required only. "
#echo "Note: Number of threads for running performance tests need to be configured inside the file"
echo "Configured values:-"
echo "Commit interval: $CI, Push Interval: $PI, Number of runs: $RUNS, Allowed deviation: $AD, Threads: 1"
echo "Usage: ./perf_test_libfiber <nothing / space separated list of splash2 benchmarks>"
mkdir -p $DIR
if [ $# -eq 0 ]; then
  run_perf_test
else
  run_perf_test $@
fi

rm -f $OUT_FILE $SUM_FILE
