#!/bin/bash
CUR_PATH=`pwd`
PLOT_RELATIVE_PATH="exp_results/plots"

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
    RUNS=5 ./exp_performance.sh
    echo "Plot results are expected to be in $CUR_PATH/accuracy_and_overhead/$PLOT_RELATIVE_PATH"
    echo "overhead-th1.pdf should correspond to Figure 9 in PLDI submission!"
    echo "overhead-th32.pdf should correspond to Figure 11 in PLDI submission!"
  popd
}

run_hw_counters_test() {
  pushd accuracy_and_overhead
    RUNS=2 ./exp_hw_perf_counters.sh
    echo "Plot results are expected to be in $CUR_PATH/accuracy_and_overhead/$PLOT_RELATIVE_PATH"
    echo "perf-hwc.pdf should correspond to Figure 12 in PLDI submission!"
  popd
}

run_shenango() {
  pushd shenango
  # must be run from frames
  ./run_shenango_experiments.sh
  echo "Plot results are expected to be in $CUR_PATH/accuracy_and_overhead/$PLOT_RELATIVE_PATH"
  echo "99.9pc.pdf, median.pdf, cpuminer-hashrate.pdf should correspond to Figure 6 in PLDI submission!"
  popd
}

run_mtcp() {
  pushd mtcp
  # must be run from lines
  RUNS=3 ./experiment.sh
  echo "Plot results are expected to be in $CUR_PATH/accuracy_and_overhead/$PLOT_RELATIVE_PATH"
  echo "perf_unmod.pdf should correspond to Figure 4 in PLDI submission!"
  echo "perf_mod.pdf should correspond to Figure 5 in PLDI submission!"
  popd
}

run_server_delegation_fetch_n_add
run_server_delegation_client_req_latency
run_interval_accuracy_test
run_performance_overhead_test
run_hw_counters_test
run_shenango
run_mtcp
