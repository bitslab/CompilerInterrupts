#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root"
  exit
fi

CURR_PATH=`pwd`/$(dirname "${BASH_SOURCE[0]}")

# Allow reading instruction counters
echo "2" > /sys/bus/event_source/devices/cpu/rdpmc
# Allow PAPI from reading performance counters
echo "0" > /proc/sys/kernel/perf_event_paranoid

mkdir -p $CURR_PATH/../lib
chmod 777 $CURR_PATH/../lib

ENV_FILE="env_var.sh"
touch $ENV_FILE

if ! grep -q "AO_INPUT_DIRECTORY" $ENV_FILE; then
  AO_INPUT_DIRECTORY="/local_home/inputs/"
  echo "AO_INPUT_DIRECTORY=$AO_INPUT_DIRECTORY" >> $ENV_FILE
else
  AO_INPUT_DIRECTORY=`grep AO_INPUT_DIRECTORY $ENV_FILE | cut -d '=' -f 2`
fi

if [ ! -d "$AO_INPUT_DIRECTORY" ]; then
  echo "Input directory $AO_INPUT_DIRECTORY does not exist. Either place the input files in the given path, or edit the path in $ENV_FILE."
  exit
else
  chmod -R 777 $AO_INPUT_DIRECTORY
fi

if ! grep -q "AO_OUTPUT_DIRECTORY" $ENV_FILE; then
  AO_OUTPUT_DIRECTORY="/local_home/exp_results/"
  echo "AO_OUTPUT_DIRECTORY=$AO_OUTPUT_DIRECTORY" >> $ENV_FILE
else
  AO_OUTPUT_DIRECTORY=`grep AO_OUTPUT_DIRECTORY $ENV_FILE | cut -d '=' -f 2`
fi

mkdir -p $AO_OUTPUT_DIRECTORY/interval_stats
mkdir -p $AO_OUTPUT_DIRECTORY/outputs
chmod -R 777 $AO_OUTPUT_DIRECTORY

mkdir -p ../benchmarks/server_delegation/libfiber/bin
chmod -R 777 ../benchmarks/server_delegation/libfiber/bin

mkdir -p ../benchmarks/plots/
chmod -R 777 ../benchmarks/plots/

echo "Edit $ENV_FILE if you want to change environment settings for the experiment."
cat $ENV_FILE

#echo "Copying program inputs from home directory to experiment directory"
#cp -R ../../inputs.tgz ../benchmarks/accuracy_and_overhead/
#pushd ../benchmarks/accuracy_and_overhead/
#tar -xvf inputs.tgz
#chmod -R 777 inputs
#popd
