#!/bin/bash
BENCH="blackscholes fluidanimate swaptions canneal streamcluster dedup"
DEBUG_FILE="make_log"
ERROR_FILE="make_error"

dry_run() {
  threads=1
  OUT_FILE="$DIR/strace_$bench.txt"
  suffix="_llvm"
  prefix="strace -o $OUT_FILE"
  case "$1" in
    blackscholes)
      cd blackscholes/src > /dev/null
      echo "$prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > /dev/null 2>&1"
      $prefix ./blackscholes$suffix $threads ../inputs/in_64K.txt prices.txt > /dev/null 2>&1
    ;;
    fluidanimate)
      cd fluidanimate/src > /dev/null
      $prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > /dev/null 2>&1
      echo "$prefix ./fluidanimate$suffix $threads 5 ../inputs/in_300K.fluid out.fluid > /dev/null 2>&1"
    ;;
    swaptions)
      cd swaptions/src > /dev/null
      $prefix ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > /dev/null 2>&1
      echo "$prefix ./swaptions$suffix -ns 128 -sm 100000 -nt $threads > /dev/null 2>&1"
    ;;
    canneal)
      cd canneal/src > /dev/null
      $prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > /dev/null 2>&1
      echo "$prefix ./canneal$suffix $threads 15000 2000 ../inputs/200000.nets 6000 > /dev/null 2>&1"
    ;;
    dedup)
      cd dedup/src > /dev/null
      $prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > /dev/null 2>&1
      echo "$prefix ./dedup$suffix -c -p -v -t $threads -i ../inputs/media.dat -o output.dat.ddp -w none > /dev/null 2>&1"
    ;;
    streamcluster)
      cd streamcluster/src > /dev/null
      $prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > /dev/null 2>&1 
      echo "$prefix ./streamcluster$suffix 10 20 128 16384 16384 1000 none output.txt $threads > /dev/null 2>&1"
    ;;
  esac
  cd - > /dev/null
}

orig_test() {
  for bench in $BENCH
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

    #BUILD_LOG=$DEBUG_FILE ERROR_LOG=$ERROR_FILE make -f Makefile.llvm ${bench}-clean
    BUILD_LOG=$DEBUG_FILE ERROR_LOG=$ERROR_FILE make -f Makefile.llvm ${bench} 
    dry_run $bench

    cd ../
  done
}

cd apps; make clean -f Makefile.llvm; cd ../
cd kernels; make clean -f Makefile.llvm; cd ../
cur_path=`pwd`
DIR="$cur_path/strace_files"
mkdir -p $DIR
orig_test
