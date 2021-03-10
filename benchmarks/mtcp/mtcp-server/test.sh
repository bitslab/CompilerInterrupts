#!/bin/bash
THREADS=16 # max - 16

run_server() {
  currpath=`pwd`
  APP_DIR=$currpath"/apps/example"
  cp -R $APP_DIR/config .
#cmd="time $APP_DIR/epserver -p $APP_DIR/root -f $APP_DIR/frames_epserver.conf -N $THREADS 2>&1 | tee out"
cmd="time $APP_DIR/epserver -p $APP_DIR/root -f $APP_DIR/frames_epserver.conf -N $THREADS >out 2>&1 &"
#cmd="time $APP_DIR/epserver -p $APP_DIR/root -f $APP_DIR/frames_epserver.conf -N $THREADS"
  echo $cmd
  eval $cmd
}

run_perf() {
  currpath=`pwd`
  APP_DIR=$currpath"/apps/perf"
  cp -R $APP_DIR/config .
  cp $APP_DIR/client.conf .
  cmd="time $APP_DIR/client wait 131.193.34.60 9000 20"
  echo $cmd
  eval $cmd
}

build_ci() {
  echo "Building epserver & epwget with CI"
  if [ $1 -eq 0 ]; then
    cp apps/example/Makefile_mod.ci apps/example/Makefile
  else
    cp apps/example/Makefile.ci apps/example/Makefile
  fi
  cp mtcp/src/Makefile.ci mtcp/src/Makefile
  cp apps/perf/Makefile.ci apps/perf/Makefile

  rm -f make_log make_error
  make clean > make_log 2>make_error
  time make >> make_log 2>make_error

  # open this to build perf
  if [ 0 -eq 1 ]; then
    echo "Building perf client with CI"
    cd apps/perf/
    rm -f make_log make_error
    make clean >> make_log 2>make_error
    time make >> make_log 2>make_error
    cd -
  fi
}

build_orig() {
  echo "Building original version of epserver & epwget"
  if [ $1 -eq 0 ]; then
    cp apps/example/Makefile_mod.orig apps/example/Makefile
  else
    cp apps/example/Makefile.orig apps/example/Makefile
  fi
  cp mtcp/src/Makefile.orig mtcp/src/Makefile
  cp apps/perf/Makefile.orig apps/perf/Makefile

  rm -f make_log make_error
  make clean > make_log 2>make_error
  time make > make_log 2>make_error

  # open this to build perf
  if [ 0 -eq 1 ]; then
    echo "Building perf client"
    cd apps/perf/
    rm -f make_log make_error
    make clean >> make_log 2>make_error
    time make >> make_log 2>make_error
    cd -
  fi
}

source ./startup.sh
if [ $# -ne 3 ]; then
  echo "Usage ./test.sh <0 - orig, 1 - ci> <(1:build & run, 2:build, 3:run) <0:mod, 1:unmod>"
  exit
fi

#echo 32768 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

opt=$2

#opt=3
#read -p "Choose option: (1:build & run, 2:build, 3:run)? " opt

if [ $opt -eq 1 ] || [ $opt -eq 2 ]; then
  if [ $1 -eq 0 ]; then
    build_orig $3
  else
    build_ci $3
  fi
fi

if [ $opt -eq 1 ] || [ $opt -eq 3 ]; then
  run_server
#run_perf
fi
