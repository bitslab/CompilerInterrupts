#!/bin/bash
  
mkdir -p plots
cp accuracy_and_overhead/plots/accuracy-th1.pdf plots/Figure10.pdf
cp accuracy_and_overhead/plots/overhead-th1.pdf plots/Figure9.pdf
cp accuracy_and_overhead/plots/overhead-th32.pdf plots/Figure11.pdf
cp accuracy_and_overhead/plots/perf-hwc.pdf plots/Figure12.pdf
cp accuracy_and_overhead/plots/runtime.txt plots/Table7.txt

cp server_delegation/plots/mops_server_vs_thread_nr_with_5_cl_per_th.pdf plots/Figure7.pdf
cp server_delegation/plots/client_latency_distribution_with_54_th.pdf plots/Figure8.pdf

cp mtcp/plots/perf_unmod.pdf plots/Figure4.pdf
cp mtcp/plots/perf_mod.pdf plots/Figure5.pdf

cp shenango/scripts/plots/99.9pc.pdf plots/Figure6a.pdf
cp shenango/scripts/plots/median.pdf plots/Figure6b.pdf
cp shenango/scripts/plots/cpuminer-hashrate.pdf plots/Figure6c.pdf
