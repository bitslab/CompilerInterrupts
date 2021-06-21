#!/bin/bash
# this script is meant to profile the events marking the beginning & end of compiler interrupt handler. It is important to build all the benchmarks first, in the CI mode that needs to be debugged. Also, to simultaneously profile the app based on intervals, run the profile_app_intervalwise.sh first, & then start this script. Some of the benchmarks like the water ones, don't seem to work through the script, but works manually, not sure why.
CUR_PATH=`pwd`/$(dirname "${BASH_SOURCE[0]}")/
SUB_DIR="${SUB_DIR:-"perf_profile"}"
DIR=$CUR_PATH/exp_results/$SUB_DIR

CYCLE="${CYCLE:-5000}"
THREAD=1
CI_SETTINGS="2 12"
EXTRA_FLAGS="-DINTV_SAMPLING"

#CI_SETTINGS="12"

source $CUR_PATH/include.sh

if ! [ $(id -u) = 0 ]; then
   echo "This script needs to be run as root!"
   exit
fi

perf_profile() {
  bench=$1
  ci_setting=$2
  thread=$THREAD
  suffix_conf=1
  #ofile="$DIR/${bench}-ci${ci_setting}-for-sampling.data"
  ofile="$DIR/${bench}-ci${ci_setting}.data"

  perf probe -d ci_start -d ci_end__return

  executable_name=$(get_executable_name $bench 1)

  PREFIX="" dry_run_exp $bench $suffix_conf

  pushd $BENCH_DIR
  rm -f *.old

  perf probe -l

  if [ "$BENCH_SUITE" != "phoenix" ]; then
    cmd="perf probe -x $executable_name ci_start=compiler_interrupt_handler"
    run_command $cmd

    cmd="perf probe -x $executable_name ci_end=compiler_interrupt_handler%return"
    run_command $cmd
  else
    cmd="perf probe -x ./tests/$bench/$executable_name ci_start=compiler_interrupt_handler"
    run_command $cmd

    cmd="perf probe -x ./tests/$bench/$executable_name ci_end=compiler_interrupt_handler%return"
    run_command $cmd
  fi

  echo "Probe listing:-"
  perf probe -l

  popd > /dev/null

  # run system-wide profiler before the actual experiment run
  cmd="mv $BUILD_LOG $DIR/tmp1"; run_command $cmd
  cmd="mv $ERROR_LOG $DIR/tmp2"; run_command $cmd
  $CUR_PATH/profile_app_intervalwise.sh $bench $ci_setting &
  sleep 2
  cmd="mv $DIR/tmp1 $BUILD_LOG"; run_command $cmd
  cmd="mv $DIR/tmp2 $ERROR_LOG"; run_command $cmd

  # Experiment run
  case "$bench" in
  "ocean-cp" | "ocean-ncp")
    PREFIX="perf record -g -e probe_ocean:ci_start -e probe_ocean:ci_end__return -o $ofile"
    ;;
  "lu-c" | "lu-nc")
    PREFIX="perf record -g -e probe_lu:ci_start -e probe_lu:ci_end__return -o $ofile"
    ;;
  "water-nsquared" | "water-spatial")
    # does not work through script for some reason, but works manually
    PREFIX="perf record -g -e probe_water:ci_start -e probe_water:ci_end__return -o $ofile"
    ;;
  "blackscholes" | "fluidanimate" | "swaptions" | "canneal" | "streamcluster" | "dedup")
    PREFIX="perf record -g -e probe_${executable_name}:ci_start -e probe_${executable_name}:ci_end__return -o $ofile"
    ;;
  *)
    PREFIX="perf record -g -e probe_${bench}:ci_start -e probe_${bench}:ci_end__return -o $ofile"
    ;;
  esac

  PREFIX="LD_PRELOAD=$LIBCALL_WRAPPER_PATH $PREFIX"

  printf "${GREEN}Experiment run for CI:-\n${NC}" | tee -a $CMD_LOG
  run_exp $bench $suffix_conf $thread $ci_setting 0 $CYCLE

  perf probe -d ci_start -d ci_end__return
  perf probe -l

  sleep 10
  echo -e "\n\n\n\n\n"
}

perf_profile_test() {
  thread=$THREAD
  echo "Experiment for performance profiling for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREAD threads, app list: $*"
  for ci_setting in $CI_SETTINGS; do
    for bench in $*; do
      ci_str=$(get_ci_str $ci_setting)
      echo "Running performance profiling experiment for $bench with $thread threads & $ci_str type" | tee -a $CMD_LOG
      set_benchmark_info $bench
      build_ci $bench $ci_setting $thread

      perf_profile $bench $ci_setting $thread
      mv $OUT_FILE $DIR/${bench}-th${thread}-ci${ci_setting}-output
    done
  done
}

strace_profile() {
  bench=$1
  ci_setting=$2
  thread=$THREAD
  suffix_conf=1
  #ofile="$DIR/${bench}-ci${ci_setting}-for-sampling.data"
  ofile="$DIR/${bench}-ci${ci_setting}-th${thread}.strace"

  executable_name=$(get_executable_name $bench 1)

  PREFIX="" dry_run_exp $bench $suffix_conf

  # Experiment run
  PREFIX="strace -T -t -k -E LD_PRELOAD=$LIBCALL_WRAPPER_PATH -o $ofile "

  printf "${GREEN}Experiment run for CI:-\n${NC}" | tee -a $CMD_LOG
  run_exp $bench $suffix_conf $thread $ci_setting 0 $CYCLE

  sleep 10
  echo -e "\n\n\n\n\n"
}

strace_profile_test() {
  thread=$THREAD
  echo "Experiment for performance profiling for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREAD threads, app list: $*"
  for ci_setting in $CI_SETTINGS; do
    for bench in $*; do
      ci_str=$(get_ci_str $ci_setting)
      echo "Running performance profiling experiment for $bench with $thread threads & $ci_str type" | tee -a $CMD_LOG
      set_benchmark_info $bench
      build_ci $bench $ci_setting $thread

      strace_profile $bench $ci_setting $thread
      mv $OUT_FILE $DIR/${bench}-th${thread}-ci${ci_setting}-output
    done
  done
}

benches="$splash2_benches $phoenix_benches $parsec_benches"

# Usage:
#   No argument : run for all benchmark suites
#   $1=0, $2=<name of benchmark>
#   $1=1, $2=<name of benchmark suite>

if [ $# -ne 0 ]; then
  if [ $1 -eq 1 ]; then
    benches=""
    for arg in $@; do
      if [ "$arg" == "splash2" ]; then
        benches="$benches$splash2_benches "
      elif [ "$arg" == "phoenix" ]; then
        benches="$benches$phoenix_benches "
      elif [ "$arg" == "parsec" ]; then
        benches="$benches$parsec_benches "
      fi
    done
  else
    benches="${@:2}"
  fi
fi

perf_profile_test $benches
strace_profile_test $benches

print_end_notice
