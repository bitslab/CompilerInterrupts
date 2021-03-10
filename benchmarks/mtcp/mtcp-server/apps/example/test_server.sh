#!/bin/bash
server_name=`hostname`

run_server() {
  #currpath=`pwd`
  APP_DIR="."
  cmd="time $APP_DIR/epserver -p $APP_DIR/root -f $APP_DIR/${server_name}_epserver.conf -N $THREADS >out 2>&1 &"
  #cmd="time $APP_DIR/epserver -p $APP_DIR/root -f $APP_DIR/frames_epserver.conf -N $THREADS"
  echo $cmd
  eval $cmd
}

# unused
run_perf() {
  currpath=`pwd`
  APP_DIR=$currpath"/apps/perf"
  cp -R $APP_DIR/config .
  cp $APP_DIR/client.conf .
  cmd="time $APP_DIR/client wait 131.193.34.60 9000 20"
  echo $cmd
  eval $cmd
}

THREADS=16 # max - 16
if [ $# -eq 1 ]; then
  THREADS=$1
fi
echo "Running server with $THREADS thread(s)"
run_server
