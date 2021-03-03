#!/bin/bash
CUR_PATH=`pwd`
PLOT_RELATIVE_PATH="exp_results/plots"
RUNS=10 # configure this

run_server_delegation_fetch_n_add() {
  pushd server_delegation
    ./fetch-n-add.sh
    echo "Plot results are expected to be in $CUR_PATH/server_delegation/$PLOT_RELATIVE_PATH"
    echo "client_latency_distribution_with_54_th.pdf should correspond to Figure 8 in PLDI submission!"
  popd
}

run_server_delegation_client_req_latency() {
  pushd server_delegation
    ./client-req-latency.sh
    echo "Plot results are expected to be in $CUR_PATH/server_delegation/$PLOT_RELATIVE_PATH"
    echo "mops_server_vs_thread_nr_with_5_cl_per_th.pdf should correspond to Figure 7 in PLDI submission!"
  popd
}

run_interval_accuracy_test() {
  pushd accuracy_and_overhead
    ./exp_interval_accuracy.sh
    echo "Plot results are expected to be in $CUR_PATH/accuracy_and_overhead/$PLOT_RELATIVE_PATH"
    echo "accuracy-th1.pdf should correspond to Figure 10 in PLDI submission!"
  popd
}

run_performance_overhead_test() {
  pushd accuracy_and_overhead
    ./exp_performance.sh
    echo "Plot results are expected to be in $CUR_PATH/accuracy_and_overhead/$PLOT_RELATIVE_PATH"
    echo "overhead-th1.pdf should correspond to Figure 9 in PLDI submission!"
    echo "overhead-th32.pdf should correspond to Figure 11 in PLDI submission!"
  popd
}

run_hw_counters_test() {
  pushd accuracy_and_overhead
    ./exp_hw_perf_counters.sh
    echo "Plot results are expected to be in $CUR_PATH/accuracy_and_overhead/$PLOT_RELATIVE_PATH"
    echo "perf-hwc.pdf should correspond to Figure 12 in PLDI submission!"
  popd
}

run_server_delegation_fetch_n_add
run_server_delegation_client_req_latency
run_interval_accuracy_test
run_performance_overhead_test
run_hw_counters_test
