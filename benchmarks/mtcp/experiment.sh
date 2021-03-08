#!/bin/bash

CUR_PATH=`pwd`
EXP_DIR="$CUR_PATH/exp_results/"
PLOTS_DIR="$CUR_PATH/plots/"
RUNS="${RUNS:-10}"

# $1 - mode, $2 - yrange
process_data() {
  ci_file="${EXP_DIR}/all_log_ci_$1"
  orig_file="${EXP_DIR}/all_log_orig_$1"
  native_file="${EXP_DIR}/all_log_native_$1"
  latency_file="${EXP_DIR}/combined_latency_$1"
  throughput_file="${EXP_DIR}/combined_throughput_$1"
  gawk 'ARGIND == 1 {a[$1]=$1/16 FS $2; next} ARGIND == 2 {a[$1]=a[$1] FS $2; next} ARGIND == 3 { print a[$1], $2 } ' $orig_file $ci_file $native_file > $latency_file
  gawk 'ARGIND == 1 {a[$1]=$1/16 FS $3; next} ARGIND == 2 {a[$1]=a[$1] FS $3; next} ARGIND == 3 { print a[$1], $3 } ' $orig_file $ci_file $native_file > $throughput_file
  sed -i "1s/.*/Concurrency Orig CI Native/" $latency_file
  sed -i "1s/.*/Concurrency Orig CI Native/" $throughput_file
  gnuplot -e "ofile='${PLOTS_DIR}/perf_$1.pdf'" -e "throughput_file='$throughput_file'" -e "latency_file='$latency_file'" -e "yr=$2" plot_mtcp.gp
}

run_mtcp_app() {
  echo "Running MTCP server-client"
  pushd mtcp-client/apps/example
  time RUNS=$RUNS ./test_client.sh
  popd
}

run_linux_app() {
  echo "Running Native linux server-client"
  pushd mtcp-native
  time RUNS=$RUNS ./run_client.sh
  popd
}

mkdir -p $EXP_DIR $PLOTS_DIR
run_linux_app
run_mtcp_app
process_data "unmod" 10000
process_data "mod" 100
