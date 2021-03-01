#!/bin/bash

BENCH="water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity radix fft lu-c lu-nc cholesky"
DEBUG_FILE="make_log"
ERROR_FILE="make_error"

dry_run() {
  OUT_FILE="$DIR/strace_$bench.txt"
  suffix="orig"
  prefix="strace -o $OUT_FILE"
  case "$1" in
    water-nsquared)
      cd water-nsquared > /dev/null
      command="$prefix ./water-nsquared-$suffix < input.1 > /dev/null 2>&1"
    ;;
    water-spatial)
      cd water-spatial > /dev/null
      command="$prefix ./water-spatial-$suffix < input.1 > /dev/null 2>&1"
    ;;
    ocean-cp) 
      cd ocean/contiguous_partitions > /dev/null
      command="$prefix ./ocean-cp-$suffix -n1026 -p 1 -e1e-07 -r2000 -t28800 > /dev/null 2>&1"
    ;;
    ocean-ncp) 
      cd ocean/non_contiguous_partitions > /dev/null
      command="$prefix ./ocean-ncp-$suffix -n258 -p 1 -e1e-07 -r2000 -t28800 > /dev/null 2>&1"
    ;;
    barnes)
      cd barnes > /dev/null
      command="$prefix ./barnes-$suffix < input.1 > /dev/null 2>&1"
    ;;
    volrend)
      cd volrend > /dev/null
      command="$prefix ./volrend-$suffix 1 inputs/head > /dev/null 2>&1"
    ;;
    fmm)
      cd fmm > /dev/null
      command="$prefix ./fmm-$suffix < inputs/input.65535.1 > /dev/null 2>&1"
    ;;
    raytrace)
      cd raytrace > /dev/null
      command="$prefix ./raytrace-$suffix -p 1 -m72 inputs/balls4.env > /dev/null 2>&1"
    ;;
    radiosity)
      cd radiosity > /dev/null
      command="$prefix ./radiosity-$suffix -p 1 -batch -largeroom > /dev/null 2>&1"
    ;;
    radix)
      cd radix > /dev/null
      command="$prefix ./radix-$suffix -p1 -n134217728 -r1024 -m524288 > /dev/null 2>&1"
    ;;
    fft)
      cd fft > /dev/null
      command="$prefix ./fft-$suffix -m24 -p1 -n1048576 -l4 > /dev/null 2>&1"
    ;;
    lu-c)
      cd lu/contiguous_blocks > /dev/null
      command="$prefix ./lu-c-$suffix -n4096 -p1 -b16 > /dev/null 2>&1"
    ;;
    lu-nc)
      cd lu/non_contiguous_blocks > /dev/null
      command="$prefix ./lu-nc-$suffix -n2048 -p1 -b16 > /dev/null 2>&1"
    ;;
    cholesky)
      cd cholesky > /dev/null
      command="$prefix ./cholesky-$suffix -p1 -B32 -C1024 inputs/tk29.O > /dev/null 2>&1"
    ;;
  esac
  echo "Dry run: "$command
  eval $command
  cd - > /dev/null
}

orig_test() {
  for bench in $BENCH
  do
    BENCH_DIR=""
    case "$bench" in
    "radix" | "fft" | "lu-c" | "lu-nc" | "cholesky")
      BENCH_DIR="kernels"
      ;;
    *)
      BENCH_DIR="apps"
      ;;
    esac

    cd $BENCH_DIR

    echo "Building original program for $bench: " | tee -a $DEBUG_FILE
    #BUILD_LOG=$DEBUG_FILE ERROR_LOG=$ERROR_FILE make -f Makefile.orig $bench-clean
    BUILD_LOG=$DEBUG_FILE ERROR_LOG=$ERROR_FILE make -f Makefile.orig $bench 

    dry_run $bench

    cd ../
  done
}

cd apps; make clean -f Makefile.orig; cd ../
cd kernel; make clean -f Makefile.orig; cd ../
cur_path=`pwd`
DIR="$cur_path/strace_files"
mkdir -p $DIR
orig_test
