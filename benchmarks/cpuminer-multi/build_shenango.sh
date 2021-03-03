#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

cpuminer_shenango_build() {
  echo "Building experiment for CI Interval $1"
  make clean -j 20
  cyc=$1
  pi=`expr $cyc / 4`
  cmt_intv=`expr $pi / 5`
  echo "PI: $pi, CI: $cmt_intv, CYC: $cyc"
  PUSH_INTV=$pi CMMT_INTV=$cmt_intv CYCLE_INTV=$cyc make -j 20 > make_log_$1 2>make_err_$1
  error_status=$?
  if [ $error_status -ne 0 ]; then
    printf "${RED}Build failed with status $error_status.\n${NC}" | tee -a $CMD_LOG
    cat make_err_$1
    exit
  fi
  mv cpuminer cpuminer-$cyc
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
for intv in $intervals
do
  cpuminer_shenango_build $intv
#cpuminer_shenango_profile_build $intv
done
