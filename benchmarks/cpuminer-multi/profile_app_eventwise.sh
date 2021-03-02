#!/bin/bash
# this script is meant to profile the events marking the beginning & end of compiler interrupt handler. It is important to build all the benchmarks first, in the CI mode that needs to be debugged. Also, to simultaneously profile the app based on intervals, run the profile_app_intervalwise.sh first, & then start this script. Some of the benchmarks like the water ones, don't seem to work through the script, but works manually, not sure why.

if ! [ $(id -u) = 0 ]; then
   echo "This script needs to be run as root!"
   exit
fi

echo "Running the interval-wise profiler in the background! PID: "
#./profile_app_intervalwise.sh &
pgrep profile_app_intervalwise.sh

rm -f *.old

perf probe -d ci_start -d ci_end
perf probe -l

#perf probe -x ./cpuminer ci_start=compiler_interrupt_handler@TriggerAction.h
perf probe -x ./cpuminer ci_start=compiler_interrupt_handler
perf probe -x ./cpuminer ci_end=compiler_interrupt_handler%return

echo "Probe listing:-"
perf probe -l

#cmd="./cpuminer -t 1 -a sha256d -o stratum+tcp://connect.pool.bitcoin.com:3333 -u 15dFNAbSnC7MngwHjoM2gZSuCEg5mmAEKc -p c=BTC > cpuminer-iokernel.perf.out 2>&1 &"
cmd="./cpuminer -t 1 -a sha256d -o stratum+tcp://connect.pool.bitcoin.com:3333 -u 15dFNAbSnC7MngwHjoM2gZSuCEg5mmAEKc -p c=BTC"

perf record -g -e probe_cpuminer:ci_start -e probe_cpuminer:ci_end -o cpuminer.data $cmd
perf probe -l
exit

perf probe -d ci_start -d ci_end
perf probe -l

echo "Killing the interval-wise profiler running in the background!"
pkill profile_app_intervalwise.sh
