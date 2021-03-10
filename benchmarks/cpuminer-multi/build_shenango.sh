#!/bin/bash

cpuminer_orig_build() {
  echo "Building original cpuminer"
  cp Makefile.orig Makefile
  make clean -j 20
  make -j 20 > make_log_orig 2>make_err_orig
  err_status=`echo $?`
  if [ $err_status -eq 0 ]; then
    mv cpuminer cpuminer-orig
  else
    diff=`diff Makefile.orig Makefile`
    if [ -z "$diff" ]; then
      echo "Cpuminer orig version did not build properly. Check make_log_orig & make_err_orig."
      exit
    else
      cpuminer_orig_build
    fi
  fi
}

cpuminer_shenango_build() {
  echo "Building experiment for CI Interval $1"
  cp Makefile.lc Makefile
  make clean -j 20
  cyc=$1
  pi=`expr $cyc / 4`
  cmt_intv=`expr $pi / 5`
  echo "PI: $pi, CI: $cmt_intv, CYC: $cyc"
  PUSH_INTV=$pi CMMT_INTV=$cmt_intv CYCLE_INTV=$cyc make -j 20 > make_log_$1 2>make_err_$1
  err_status=`echo $?`
  if [ $err_status -eq 0 ]; then
    mv cpuminer cpuminer-$cyc
  else
    diff=`diff Makefile.lc Makefile`
    if [ -z "$diff" ]; then
      echo "CPUMiner did not build properly. Check make_log_$1 and make_err_$1."
      exit
    else
      cpuminer_shenango_build
    fi
  fi
}

cpuminer_shenango_profile_build() {
  echo "Building experiment for CI Interval $1"
  make clean -j 20
  #pi=$1
  #cyc=`expr $1 \* 4`
  #cmt_intv=`expr $pi / 5`
  cyc=$1
  pi=`expr $cyc / 4`
  cmt_intv=`expr $pi / 5`
  echo "PI: $pi, CI: $cmt_intv, CYC: $cyc"
  PUSH_INTV=$pi CMMT_INTV=$cmt_intv CYCLE_INTV=$cyc EXTRA_CFLAGS="-DPROFILE" make -j 20 > make_log_$1 2>make_err_$1
  mv cpuminer cpuminer-profile-pi$pi-cyc$cyc
}

#intervals="${intervals:-500 1000 2000 5000 10000 20000}"
intervals="${intervals:- 1000 2000 4000 8000 16000 32000 64000}"
#intervals="${intervals:- 4000 16000 64000}"

if [ $# -eq 1 ]; then
  echo "Cleaning stale builds"
  make clean
  rm -f cpuminer-orig
  for intv in $intervals; do
    rm -f cpuminer-$intv
  done
  rm -f make_log* make_err*
  exit
fi

echo "Building different versions of cpuminer"
cpuminer_orig_build
for intv in $intervals
do
  cpuminer_shenango_build $intv
done
