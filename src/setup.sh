#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root"
  exit
fi

# Allow reading instruction counters
echo "2" > /sys/bus/event_source/devices/cpu/rdpmc
# Allow PAPI from reading performance counters
echo "0" > /proc/sys/kernel/perf_event_paranoid

mkdir -p /local_home/exp_results/interval_stats
mkdir -p /local_home/exp_results/intv_accuracy
mkdir -p /local_home/exp_results/outputs
chmod -R 777 /local_home/exp_results/

mkdir -p ../benchmarks/server_delegation/libfiber/bin
chmod -R 777 ../benchmarks/server_delegation/libfiber/bin

#echo "Copying program inputs from home directory to experiment directory"
#cp -R ../../inputs.tgz ../benchmarks/accuracy_and_overhead/
#pushd ../benchmarks/accuracy_and_overhead/
#tar -xvf inputs.tgz
#chmod -R 777 inputs
#popd
