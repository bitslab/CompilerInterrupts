#!/bin/bash
RUNS=5
CYCLES="5000"
SUBDIR="locals"
#PI=1000000 THREADS="1" SUB_DIR="${SUBDIR}exp1" RUNS=20 ./perf_test.sh
#PI=5000 THREADS="1 2 4 8 16 32" SUB_DIR="${SUBDIR}exp2" RUNS=5 ./perf_test.sh
#SUB_DIR="${SUBDIR}exp3" RUNS=5 ./perf_with_perf_cntrs.sh
#SUB_DIR="${SUBDIR}exp4" ./interval_accuracy.sh

#PI=1000000 THREADS="1" SUB_DIR="${SUBDIR}exp1" RUNS=5 ./quick_perf_test.sh

#SUB_DIR="${SUBDIR}exp4" ./quick_interval_accuracy.sh
#SUB_DIR="${SUBDIR}exp1" ./quick_perf_test.sh
#PI=5000 SUB_DIR="${SUBDIR}exp3" RUNS=1 ./quick_hw_cntrs_perf.sh
#THREAD="32" SUB_DIR="${SUBDIR}exp6" ./quick_interval_accuracy.sh
#THREAD="32" PI=5000 SUB_DIR="${SUBDIR}exp3" RUNS=2 ./quick_hw_cntrs_perf.sh

SUB_DIR="libfiber_exp5" RUNS=3 ./perf_with_libfiber.sh
exit

THREAD="1" CYCLE="${CYCLES}" SUB_DIR="${SUBDIR}_th1" ./quick_interval_accuracy.sh
THREAD="32" CYCLE="${CYCLES}" SUB_DIR="${SUBDIR}_th32" ./quick_interval_accuracy.sh
SUB_DIR="${SUBDIR}" CYCLE="${CYCLES}" RUNS=5 ./quick_perf_test.sh
