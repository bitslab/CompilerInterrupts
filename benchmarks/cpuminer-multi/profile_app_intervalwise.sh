#!/bin/bash
# this script runs perf record on the apps, based on intervals. need to run the profile_app_eventwise.sh script after this to start running the app & profile it parallely on events, for comparison.

if ! [ $(id -u) = 0 ]; then
   echo "This script needs to be run as root!"
   exit
fi

app="cpuminer"

echo "100000" > /proc/sys/kernel/perf_event_max_sample_rate
cat /proc/sys/kernel/perf_event_max_sample_rate

echo "Waiting cpuminer ..."
proc_id=`pidof $app`
while [ -z $proc_id ]; do 
  proc_id=`pidof $app`
done

echo "Running perf record cpuminer ($proc_id)"
perf record -g -F 100000 --call-graph fp -p $proc_id -o $app-interval.data
echo "Ran perf record cpuminer ($proc_id)"

sleep 2

mkdir perf_data_backup
mv *.data perf_data_backup
