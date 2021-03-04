#!/bin/bash
  
mkdir -p plots
cp accuracy_and_overhead/plots/accuracy-th1.pdf plots/Figure10.pdf
cp accuracy_and_overhead/plots/overhead-th1.pdf plots/Figure9.pdf
cp accuracy_and_overhead/plots/overhead-th32.pdf plots/Figure11.pdf
cp accuracy_and_overhead/plots/perf-hwc.pdf plots/Figure12.pdf
cp server_delegation/plots/mops_server_vs_thread_nr_with_5_cl_per_th.pdf plots/Figure7.pdf
cp server_delegation/plots/client_latency_distribution_with_54_th.pdf plots/Figure8.pdf
cp accuracy_and_overhead/plots/runtime.txt plots/Table7.txt
