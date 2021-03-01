#!/bin/bash
CUR_PATH=`pwd`
CLOCK=1
AD=100
THREAD=1
SUB_DIR="${SUB_DIR:-"osdi"}"
SUB_DIR=$SUB_DIR"_profile_th$THREAD"
DIR=$CUR_PATH/parsec_stats/$SUB_DIR
WRITE_DIR=/local_home/nilanjana/temp/$SUB_DIR

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
      $prefix ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > /dev/null 2>&1
      echo "$prefix ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > /dev/null 2>&1" >> $DEBUG_FILE
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
emit_interval_stats() {
  threads=$THREAD
  suffix="_ci"
  prefix="timeout 5m taskset 0x00000001 "
  OUT_DIR="/local_home/nilanjana/temp/interval_stats/"
  OUT_FILE="$WRITE_DIR/tmp"
  OUT_STAT_FILE="$WRITE_DIR/${file_prefix}_$1_lc_ic_vs_tsc"
  rm -f $OUT_DIR/*
  rm -f $OUT_FILE
  dry_run $1

  echo "Exporting $1 interval statistics to $OUT_FILE"

  case "$1" in
    blackscholes)
      cd blackscholes/src > /dev/null
      $prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE
      echo "$prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    fluidanimate)
      cd fluidanimate/src > /dev/null
      $prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE
      echo "$prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    swaptions)
      cd swaptions/src > /dev/null
      $prefix ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > $OUT_FILE
      echo "$prefix ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    canneal)
      cd canneal/src > /dev/null
      $prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > $OUT_FILE
      echo "$prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    dedup)
      cd dedup/src > /dev/null
      $prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE
      echo "$prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
    streamcluster)
      cd streamcluster/src > /dev/null
      $prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > $OUT_FILE
      echo "$prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > $OUT_FILE" >> $DEBUG_FILE
      cd - > /dev/null
    ;;
  esac

  cd $OUT_DIR
  ls
  for file in interval_stats_thread*.txt
  do
    thr_no=`echo $file | grep -o '[0-9]\+'`
    new_name=$OUT_STAT_FILE"_thread"$thr_no".txt"
    mv $file $new_name
    echo "Generated $new_name"
  done
  cd -
}

profile_test() {

  echo "=================================== PROFILE ACCURACY TEST ==========================================="

  case "$ACC_SETTING" in
    2) ci_type="opt-tl"
      AD=100
      echo "Evaluating OPT TL with ECC $AD"
    ;;
    4) ci_type="naive-tl"
      AD=100
      echo "Evaluating NAIVE TL with ECC $AD"
    ;;
    6) ci_type="cd-tl"
      AD=100
      echo "Evaluating CD TL with ECC $AD"
    ;;
    8) ci_type="legacy-acc"
      AD=0
      echo "Evaluating LEGACY ACC with ECC $AD"
    ;;
    9) ci_type="opt-acc"
      AD=0
      echo "Evaluating OPT ACC with ECC $AD"
    ;;
    10) ci_type="legacy-tl"
      AD=1
      echo "Evaluating LEGACY TL with ECC $AD"
    ;;
    11) ci_type="naive-acc"
      AD=0
      echo "Evaluating NAIVE ACC with ECC $AD"
    ;;
    12) ci_type="opt-int"
      AD=100
      echo "Evaluating OPT INTERMEDIATE with ECC $AD"
    ;;
    13) ci_type="naive-int"
      AD=100
      echo "Evaluating NAIVE INTERMEDIATE with ECC $AD"
    ;;
    *)
      echo "Wrong CI Type"
      exit
    ;;
  esac
  echo "Profiling for intervals $PI"

  for bench in $*
  do
    BENCH_DIR=""
    case "$bench" in
    "canneal" | "dedup" | "streamcluster")
      BENCH_DIR="kernels/"
      ;;
    *)
      BENCH_DIR="apps/"
      ;;
    esac

    cd $BENCH_DIR

#PI="5000 10000 15000 20000 25000 30000 35000"
#PI="250 500 1000 1500 2500"
    for pi in $PI; do 
      CI=`echo "scale=0; $pi/5" | bc`
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$pi CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$ACC_SETTING PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING -DRUNNING_MEDIAN" make -f Makefile.ci ${bench} 
      file_prefix="${ci_type}-pi${pi}_ecc${AD}"
      emit_interval_stats $bench
    done

    cd ../ > /dev/null
  done
}

app_profile_test() {

  echo "=================================== PROFILE ACCURACY TEST ==========================================="

  case "$ACC_SETTING" in
    2) ci_type="opt-tl"
      echo "Evaluating OPT TL with ECC $AD"
      AD=100
    ;;
    4) ci_type="naive-tl"
      echo "Evaluating NAIVE TL with ECC $AD"
      AD=100
    ;;
    6) ci_type="cd-tl"
      echo "Evaluating CD TL with ECC $AD"
      AD=100
    ;;
    8) ci_type="legacy-acc"
      echo "Evaluating LEGACY ACC with ECC $AD"
      AD=0
    ;;
    9) ci_type="opt-acc"
      echo "Evaluating OPT ACC with ECC $AD"
      AD=0
    ;;
    10) ci_type="legacy-tl"
      echo "Evaluating LEGACY TL with ECC $AD"
      AD=100
    ;;
    11) ci_type="naive-acc"
      echo "Evaluating NAIVE ACC with ECC $AD"
      AD=0
    ;;
    12) ci_type="opt-int"
      AD=100
      echo "Evaluating OPT INTERMEDIATE with ECC $AD"
    ;;
    13) ci_type="naive-int"
      AD=100
      echo "Evaluating NAIVE INTERMEDIATE with ECC $AD"
    ;;
    *)
      echo "Wrong CI Type"
      exit
    ;;
  esac

  bench=$1
  PI=$2
  BENCH_DIR=""
  case "$bench" in
  "canneal" | "dedup" | "streamcluster")
    BENCH_DIR="kernels/"
    ;;
  *)
    BENCH_DIR="apps/"
    ;;
  esac

  cd $BENCH_DIR

#PI="5000 10000 15000 20000 25000 30000 35000"
  for pi in $PI; do 
    CI=`echo "scale=0; $pi/5" | bc`
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.ci ${bench}-clean
    BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$pi CMMT_INTV=$CI CYCLE_INTV=$CYCLE INST_LEVEL=$ACC_SETTING PROFILE_FLAGS="-DAVG_STATS -DINTV_SAMPLING -DRUNNING_MEDIAN" make -f Makefile.ci ${bench} 
    file_prefix="${ci_type}-pi${pi}_ecc${AD}"
    emit_interval_stats $bench
  done

  cd ../ > /dev/null
}

OPT_TL=2
NAIVE_TL=4
CD_TL=6
LEGACY_ACC=8
OPT_ACC=9
LEGACY_TL=10
NAIVE_ACC=11
OPT_INTERMEDIATE=12
NAIVE_INTERMEDIATE=13

CYCLE=5000


mkdir -p $DIR;
#rm -rf $WRITE_DIR
mkdir -p $WRITE_DIR;

ACC_SETTING=$NAIVE_ACC

if [ $# -eq 0 ]; then

  app_list="blackscholes fluidanimate swaptions canneal dedup streamcluster"
#app_list="blackscholes"
  PI="200 500 1000 2000 5000 10000 15000 20000 25000 30000 35000 40000 45000 50000 75000 100000"
#PI="2000 5000 10000 15000 20000 25000 30000 35000 40000 45000 50000"
  #PI="15000 25000 35000 50000 75000 100000 125000"
  #PI="500 1000 2000 5000 7500 10000 150000"
#PI="10000 15000 20000 25000 30000 35000 40000 45000 50000 75000 100000"

  echo "Profiling for $CYCLE cycles, $THREAD threads, app list: $app_list, PI: $PI"

  ACC_SETTING=$OPT_INTERMEDIATE
  profile_test $app_list

  ACC_SETTING=$OPT_TL
  profile_test $app_list
  exit

  if [ 0 -eq 1 ]; then
    ACC_SETTING=$OPT_ACC
    profile_test blackscholes fluidanimate swaptions canneal dedup streamcluster
    ACC_SETTING=$NAIVE_ACC
    profile_test blackscholes fluidanimate swaptions canneal dedup streamcluster
  fi
  ACC_SETTING=$LEGACY_ACC
  profile_test blackscholes fluidanimate swaptions canneal dedup streamcluster
  ACC_SETTING=$OPT_TL
  profile_test blackscholes fluidanimate swaptions canneal dedup streamcluster
  ACC_SETTING=$NAIVE_TL
  profile_test blackscholes fluidanimate swaptions canneal dedup streamcluster
  ACC_SETTING=$CD_TL
  profile_test blackscholes fluidanimate swaptions canneal dedup streamcluster
  ACC_SETTING=$OPT_INTERMEDIATE
  profile_test blackscholes fluidanimate swaptions canneal dedup streamcluster
  ACC_SETTING=$NAIVE_INTERMEDIATE
  profile_test blackscholes fluidanimate swaptions canneal dedup streamcluster

  #PI="500 1000 2500 4000 5000"
  #PI="100 250 500 750 1000"
  PI="20 50 100 150 250 500 750 1000 2000 5000 10000"
  ACC_SETTING=$LEGACY_TL
  profile_test blackscholes fluidanimate swaptions canneal dedup streamcluster

  if [ 1 -eq 0 ]; then
    app_profile_test blackscholes 13500
    app_profile_test fluidanimate 19000
    app_profile_test swaptions 13000
    app_profile_test canneal 7000
    app_profile_test dedup 40000 
    app_profile_test streamcluster 16500
  fi
else
  profile_test $@
fi

echo "Copy test-suite/process_profile_data.sh to $WRITE_DIR. Edit process_profile_data.sh to change the CI configurations used in profiling. Run script, choose app & the profiled optimal configuration will be exported to current directory."
