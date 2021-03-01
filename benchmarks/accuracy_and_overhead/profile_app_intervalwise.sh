#!/bin/bash
# This script runs perf record on the apps, based on intervals. Need to run the profile_app_eventwise.sh script after this to start running the app & profile it parallely on events, for comparison.

CYCLE="${CYCLE:-5000}"
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-"perf_profile"}"
DIR=$CUR_PATH/microbenchmark_stats/$SUB_DIR

source $CUR_PATH/include.sh

if ! [ $(id -u) = 0 ]; then
   echo "This script needs to be run as root!"
   exit
fi

if [ $# -ne 2 ]; then
  echo "Usage: ./profile_app_intervalwise.sh <bench> <ci setting number>"
fi

program="$1"
ci_setting="$2"
interval_ofile="$DIR/${program}-ci${ci_setting}-interval.data"
syscall_ofile="$DIR/${program}-ci${ci_setting}-syscall.data"
executable_name=$(get_executable_name $program 1)

echo "100000" > /proc/sys/kernel/perf_event_max_sample_rate
printf "${GREEN}Max sample rate set: "
cat /proc/sys/kernel/perf_event_max_sample_rate
printf "${NC}"

echo "Waiting on $program ..."
proc_id=`pidof $executable_name`
while [ -z $proc_id ]; do 
  proc_id=`pidof $executable_name`
done

#cmd="perf record -g -F 100000 -p $proc_id --per-thread -o $interval_ofile"
#cmd="perf record -e syscalls:sys_enter_* --per-thread -p $proc_id -c 1 -o $interval_ofile"

#cmd="perf record -F 100000 -T -p $proc_id -o $interval_ofile"
cmd="perf record -e syscalls:sys_enter_* -e syscalls:sys_exit_* --per-thread -p $proc_id -c 1 -o $syscall_ofile"
run_command $cmd

echo "Ran perf record on $program ($proc_id)"

sleep 2

mkdir -p $DIR
