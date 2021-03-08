#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

THREADS=16 # max - 16

build_ci() {
  echo "Building epserver & epwget with CI"
  if [ $1 -eq 0 ]; then
    echo "Building epserver & epwget with CI in modified mode"
    cp apps/example/Makefile_mod.ci apps/example/Makefile
  else
    echo "Building epserver & epwget with CI in unmodified mode"
    cp apps/example/Makefile.ci apps/example/Makefile
  fi
  cp mtcp/src/Makefile.ci mtcp/src/Makefile

  rm -f make_log make_error
  make clean > make_log 2>make_error
  time make >> make_log 2>make_error
  error_status=$?
  if [ $error_status -ne 0 ]; then
    printf "${RED}Build failed with status $error_status.\n${NC}" | tee -a $CMD_LOG
    cat make_error
    exit
  fi

  # open this to build perf
  if [ 0 -eq 1 ]; then
    echo "Building perf client with CI"
    cp apps/perf/Makefile.ci apps/perf/Makefile
    cd apps/perf/
    rm -f make_log make_error
    make clean >> make_log 2>make_error
    time make >> make_log 2>make_error
    cd -
  fi
}

build_orig() {
  if [ $1 -eq 0 ]; then
    echo "Building original version of epserver & epwget in modified mode"
    cp apps/example/Makefile_mod.orig apps/example/Makefile
  else
    echo "Building original version of epserver & epwget in unmodified mode"
    cp apps/example/Makefile.orig apps/example/Makefile
  fi
  cp mtcp/src/Makefile.orig mtcp/src/Makefile

  rm -f make_log make_error
  make clean > make_log 2>make_error
  time make > make_log 2>make_error
  error_status=$?
  if [ $error_status -ne 0 ]; then
    printf "${RED}Build failed with status $error_status.\n${NC}" | tee -a $CMD_LOG
    cat make_error
    exit
  fi

  # open this to build perf
  if [ 0 -eq 1 ]; then
    echo "Building perf client"
    cp apps/perf/Makefile.orig apps/perf/Makefile
    cd apps/perf/
    rm -f make_log make_error
    make clean >> make_log 2>make_error
    time make >> make_log 2>make_error
    cd -
  fi
}

clean() {
  rm -f make_log make_error
  make clean > make_log 2>make_error
  error_status=$?
  if [ $error_status -ne 0 ]; then
    printf "${RED}Build clean failed with status $error_status.\n${NC}" | tee -a $CMD_LOG
    cat make_error
    exit
  fi
}

export RTE_TARGET=x86_64-native-linuxapp-gcc
export RTE_SDK=$PWD/dpdk

if [ $# -eq 0 ]; then
  clean
elif [ $# -eq 2 ]; then
  if [ $1 -eq 0 ]; then
    build_orig $2
  else
    build_ci $2
  fi
else
  echo "For building, usage: ./build.sh <0 - orig, 1 - ci> <0:mod, 1:unmod>"
  echo "For cleaning, usage: ./build.sh"
fi
