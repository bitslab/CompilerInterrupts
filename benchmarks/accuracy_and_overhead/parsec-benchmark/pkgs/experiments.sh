#!/bin/bash
RUNS=2
#SUBDIR="new_tuned_hw"
CYCLES="5000"
SUBDIR="locals"
#LLVM_BUILD_PATH=/mnt/nilanjana/ LLVM_SRC_PATH=/home/nbasu4/logicalclock/ci-llvm-v9/ MACROS=/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/parsec-benchmark/pkgs/null_macros/c.m4.null PI=1000000 THREADS="1" SUB_DIR="${SUBDIR}exp1" RUNS=$RUNS ./experiments_over_CI_types_n_threads.sh
#LLVM_BUILD_PATH=/mnt/nilanjana/ LLVM_SRC_PATH=/home/nbasu4/logicalclock/ci-llvm-v9/ MACROS=/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/parsec-benchmark/pkgs/null_macros/c.m4.null PI=5000 THREADS="1 2 4 8 16 32" SUB_DIR="${SUBDIR}exp2" RUNS=3 ./experiments_over_CI_types_n_threads.sh 
#LLVM_BUILD_PATH=/mnt/nilanjana/ LLVM_SRC_PATH=/home/nbasu4/logicalclock/ci-llvm-v9/ MACROS=/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/parsec-benchmark/pkgs/null_macros/c.m4.null SUB_DIR="${SUBDIR}exp3" RUNS=3 ./experiment_ci_overhead_with_perf_cntrs.sh
#LLVM_BUILD_PATH=/mnt/nilanjana/ LLVM_SRC_PATH=/home/nbasu4/logicalclock/ci-llvm-v9/ MACROS=/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/parsec-benchmark/pkgs/null_macros/c.m4.null SUB_DIR="${SUBDIR}exp4" ./experiment_interval_accuracy.sh 
#LLVM_BUILD_PATH=/mnt/nilanjana/ LLVM_SRC_PATH=/home/nbasu4/logicalclock/ci-llvm-v9/ MACROS=/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/parsec-benchmark/pkgs/null_macros/c.m4.null SUB_DIR="${SUBDIR}exp5" ./experiments_with_libfiber.sh

#PI=1000000 THREADS="1" SUB_DIR="${SUBDIR}exp1" RUNS=$RUNS ./experiments_over_CI_types_n_threads.sh
#PI=5000 THREADS="1 2 4 8 16 32" SUB_DIR="${SUBDIR}exp2" RUNS=$RUNS ./experiments_over_CI_types_n_threads.sh 
#SUB_DIR="${SUBDIR}exp3" RUNS=$RUNS ./experiment_ci_overhead_with_perf_cntrs.sh
#SUB_DIR="${SUBDIR}exp4" ./experiment_interval_accuracy.sh 
#SUB_DIR="${SUBDIR}exp5" ./experiments_with_libfiber.sh

#LLVM_BUILD_PATH=/mnt/nilanjana/ LLVM_SRC_PATH=/home/nbasu4/logicalclock/ci-llvm-v9/ MACROS=/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/parsec-benchmark/pkgs/null_macros/c.m4.null SUB_DIR="${SUBDIR}exp4" ./sanity_test.sh

#LLVM_BUILD_PATH=/mnt/nilanjana/ LLVM_SRC_PATH=/home/nbasu4/logicalclock/ci-llvm-v9/ MACROS=/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/parsec-benchmark/pkgs/null_macros/c.m4.null PI=1000000 THREADS="1" SUB_DIR="${SUBDIR}exp1" RUNS=$RUNS ./quick_perf_test.sh
#LLVM_BUILD_PATH=/mnt/nilanjana/ LLVM_SRC_PATH=/home/nbasu4/logicalclock/ci-llvm-v9/ MACROS=/home/nbasu4/logicalclock/ci-llvm-v9/test-suite/parsec-benchmark/pkgs/null_macros/c.m4.null SUB_DIR="${SUBDIR}exp4" ./quick_interval_accuracy.sh

#PI=1000000 THREADS="1" SUB_DIR="${SUBDIR}exp1" RUNS=$RUNS ./quick_perf_test.sh

#SUB_DIR="${SUBDIR}exp4" ./quick_interval_accuracy.sh
#SUB_DIR="${SUBDIR}exp1" RUNS=$RUNS ./quick_perf_test.sh
#THREAD="32" PI=5000 SUB_DIR="${SUBDIR}exp3" RUNS=1 ./quick_hw_cntrs_perf.sh
#THREAD="32" SUB_DIR="${SUBDIR}exp6" ./quick_interval_accuracy.sh

#THREAD="1" PI=5000 SUB_DIR="${SUBDIR}_th1" RUNS=1 ./quick_hw_cntrs_perf.sh
#THREAD="32" PI=5000 SUB_DIR="${SUBDIR}_th32" RUNS=1 ./quick_hw_cntrs_perf.sh

THREAD="1" CYCLE="${CYCLES}" SUB_DIR="${SUBDIR}_th1" ./quick_interval_accuracy.sh
THREAD="32" CYCLE="${CYCLES}" SUB_DIR="${SUBDIR}_th32" ./quick_interval_accuracy.sh
SUB_DIR="${SUBDIR}" CYCLE="${CYCLES}" RUNS=3 ./quick_perf_test.sh
