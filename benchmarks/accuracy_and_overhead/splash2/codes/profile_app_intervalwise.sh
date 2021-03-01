#!/bin/bash
# this script runs perf record on the apps, based on intervals. need to run the profile_app_eventwise.sh script after this to start running the app & profile it parallely on events, for comparison.

app_list="water-spatial"
app_list="radix fft lu-c lu-nc cholesky water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity"

if ! [ $(id -u) = 0 ]; then
   echo "This script needs to be run as root!"
   exit
fi

for app_name in $app_list
do

  app="$app_name-lc"

  echo "100000" > /proc/sys/kernel/perf_event_max_sample_rate
  cat /proc/sys/kernel/perf_event_max_sample_rate

  echo "Waiting on $app_name ..."
  proc_id=`pidof $app`
  while [ -z $proc_id ]; do 
    proc_id=`pidof $app`
  done

  perf record -g -F 100000 --call-graph fp -p $proc_id -o ${app_name}-interval.data
  echo "Ran perf record on $app_name ($proc_id)"

  sleep 2

done

mkdir perf_data_backup
mv *.data perf_data_backup
