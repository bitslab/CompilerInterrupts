#!/bin/bash

benchmarks="radix fft cholesky lu-c lu-nc"

build_bench_orig() {
  rm -f make_log make_error
  make -f Makefile.orig $1-clean
  make -f Makefile.orig $1
}

build_all_orig() {
  echo "Running original test cases"
  for bench in $benchmarks
  do
    build_bench_orig $bench
  done
}

build_bench_lc() {
  echo "Running compiler interrupt enabled test cases"
  rm -f make_log make_error
  make -f Makefile.lc $1-clean
  make -f Makefile.lc $1
}

build_all_lc() {
  for bench in $benchmarks
  do
    build_bench_lc $bench
  done
}

build_bench_orig_libfiber() {
  rm -f make_log make_error
  make -f Makefile.orig.libfiber $1-clean
  make -f Makefile.orig.libfiber $1
}

build_all_orig_libfiber() {
  echo "Running original test cases"
  for bench in $benchmarks
  do
    build_bench_orig_libfiber $bench
  done
}

build_bench_lc_libfiber() {
  echo "Running compiler interrupt enabled test cases"
  rm -f make_log make_error
  make -f Makefile.lc.libfiber $1-clean
  make -f Makefile.lc.libfiber $1
}

build_all_lc_libfiber() {
  for bench in $benchmarks
  do
    build_bench_lc_libfiber $bench
  done
}

run_radix() {
  echo "Running RADIX"
  threads=$1
  suffix=$2
  keys=134217728
  radix=1024
  max_val=524288
  command="./radix-$suffix -p$threads -n$keys -r$radix -m$max_val"

  cd radix
#./radix-orig -p8 -n134217728 -r1024 -m524288 # runtime ~ 4s
#./radix-orig -p8 -n1073741824 -r1024 -m524288 # runtime ~ 34s
#./radix-$suffix -p$threads -n$keys -r$radix -m$max_val
  echo "Command: $command"
  eval $command
  cd -
}

run_fft() {
  echo "Running FFT"
  threads=$1
  suffix=$2
  m=24
  n=1048576
  l=4
  command="./fft-$suffix -m$m -p$threads -n$n -l$l"

  cd fft
#./fft-orig -m24 -p8 -n1048576 -l4 # runtime ~ 2.5s
#./fft-orig -m26 -p8 -n1048576 -l4 # runtime ~ 9.5s
  echo "Command: $command"
  eval $command
  cd -
}

run_cholesky() {
  echo "Running CHOLESKY"
  threads=$1
  suffix=$2
  B=32
  C=1024 # reduced size to increase runtime
  command="./cholesky-$suffix -p$threads -B$B -C$C inputs/tk29.O" #tk29.O chosen as it was taking the maximum runtime
  cd cholesky
  echo "Command: $command"
  eval $command
  cd -
}

run_lu-c() {
  echo "Running LU-C"
  threads=$1
  suffix=$2
  dim=4096
  block_size=16
  command="./lu-c-$suffix -n$dim -p$threads -b$block_size"

  cd lu/contiguous_blocks
#./lu-c-orig -n2048 -p8 -b16 # runtime ~ 1.4s
#./lu-c-orig -n4096 -p8 -b16 # runtime ~ 5.7s
#./lu-c-orig -n8196 -p8 -b16 # runtime ~ 34s
  echo "Command: $command"
  eval $command
  cd -
}

run_lu-nc() {
  echo "Running LU-NC"
  threads=$1
  suffix=$2
  dim=2048
  block_size=16
  command="./lu-nc-$suffix -n$dim -p$threads -b$block_size"

  cd lu/non_contiguous_blocks
#./lu-c-orig -n2048 -p8 -b16 # runtime ~ 3s
#./lu-c-orig -n4096 -p8 -b16 # runtime ~ 15s
#./lu-c-orig -n8196 -p8 -b16 # runtime ~ 2m
  echo "Command: $command"
  eval $command
  cd -
}

build_n_run_bench_orig() {
  build_bench_orig $1
  run_$1 32 orig
}

build_n_run_bench_lc() {
  build_bench_lc $1
  run_$1 32 lc
}

build_n_run_bench_orig_libfiber() {
  build_bench_orig_libfiber $1
  run_$1 32 orig
}

build_n_run_bench_lc_libfiber() {
  build_bench_lc_libfiber $1
  run_$1 32 lc
}

build_n_run_all_orig() {
  build_n_run_bench_orig radix
  build_n_run_bench_orig fft
  build_n_run_bench_orig lu-c
  build_n_run_bench_orig lu-nc
  build_n_run_bench_orig cholesky
}

build_n_run_all_lc() {
  build_n_run_bench_lc radix
  build_n_run_bench_lc fft
  build_n_run_bench_lc lu-c
  build_n_run_bench_lc lu-nc
  build_n_run_bench_lc cholesky
}

build_n_run_all_orig_libfiber() {
  build_n_run_bench_orig_libfiber radix
  build_n_run_bench_orig_libfiber fft
  build_n_run_bench_orig_libfiber lu-c
  build_n_run_bench_orig_libfiber lu-nc
  build_n_run_bench_orig_libfiber cholesky
}

build_n_run_all_lc_libfiber() {
  build_n_run_bench_lc_libfiber radix
  build_n_run_bench_lc_libfiber fft
  build_n_run_bench_lc_libfiber lu-c
  build_n_run_bench_lc_libfiber lu-nc
  build_n_run_bench_lc_libfiber cholesky
}

build_n_run_all_orig
build_n_run_all_lc
build_n_run_all_orig_libfiber
build_n_run_all_lc_libfiber
