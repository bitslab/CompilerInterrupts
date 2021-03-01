#!/bin/bash
# this script is meant to profile the events marking the beginning & end of compiler interrupt handler. It is important to build all the benchmarks first, in the CI mode that needs to be debugged. Also, to simultaneously profile the app based on intervals, run the profile_app_intervalwise.sh first, & then start this script. Some of the benchmarks like the water ones, don't seem to work through the script, but works manually, not sure why.

if ! [ $(id -u) = 0 ]; then
   echo "This script needs to be run as root!"
   exit
fi

get_command() {

  prefix=""
  suffix="lc"
  threads=1
  OUT_FILE="./out"

  case "$1" in
    water-nsquared)
      command="$prefix ./water-nsquared-$suffix < input.$threads > $OUT_FILE"
    ;;
    water-spatial)
      command="$prefix ./water-spatial-$suffix < input.$threads > $OUT_FILE"
    ;;
    ocean-cp) 
      command="$prefix ./ocean-cp-$suffix -n1026 -p $threads -e1e-07 -r2000 -t28800 > $OUT_FILE"
    ;;
    ocean-ncp) 
      command="$prefix ./ocean-ncp-$suffix -n258 -p $threads -e1e-07 -r2000 -t28800 > $OUT_FILE"
    ;;
    barnes)
      command="$prefix ./barnes-$suffix < input.$threads > $OUT_FILE"
    ;;
    volrend)
      command="$prefix ./volrend-$suffix $threads inputs/head > $OUT_FILE"
    ;;
    fmm)
      command="$prefix ./fmm-$suffix < inputs/input.65535.$threads > $OUT_FILE"
    ;;
    raytrace)
      command="$prefix ./raytrace-$suffix -p $threads -m72 inputs/balls4.env > $OUT_FILE"
    ;;
    radiosity)
      command="$prefix ./radiosity-$suffix -p $threads -batch -largeroom > $OUT_FILE"
    ;;
    radix)
      command="$prefix ./radix-$suffix -p$threads -n134217728 -r1024 -m524288 > $OUT_FILE"
    ;;
    fft)
      command="$prefix ./fft-$suffix -m24 -p$threads -n1048576 -l4 > $OUT_FILE"
    ;;
    lu-c)
      command="$prefix ./lu-c-$suffix -n4096 -p$threads -b16 > $OUT_FILE"
    ;;
    lu-nc)
      command="$prefix ./lu-nc-$suffix -n2048 -p$threads -b16 > $OUT_FILE"
    ;;
    cholesky)
      command="$prefix ./cholesky-$suffix -p$threads -B32 -C1024 inputs/tk29.O > $OUT_FILE"
    ;;
  esac

  echo $command

}

app_list="radix fft lu-c lu-nc cholesky water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity"
app_list="water-spatial"
perf probe -d ci_start -d ci_end

for app in $app_list
do

  bin="$app-lc"

  BENCH_DIR=""
  case "$app" in
  "lu-c")
    BENCH_DIR="kernels/lu/contiguous_blocks"
    ;;
  "lu-nc")
    BENCH_DIR="kernels/lu/non_contiguous_blocks"
    ;;
  "ocean-cp")
    BENCH_DIR="apps/ocean/contiguous_partitions"
    ;;
  "ocean-ncp")
    BENCH_DIR="apps/ocean/non_contiguous_partitions"
    ;;
  "radix" | "fft" | "cholesky")
    BENCH_DIR="kernels/$app"
    ;;
  *)
    BENCH_DIR="apps/$app"
    ;;
  esac

  cd $BENCH_DIR
  rm -f *.old

  perf probe -l

  perf probe -x $bin ci_start=compiler_interrupt_handler
  perf probe -x $bin ci_end=compiler_interrupt_handler%return

  echo "Probe listing:-"
  perf probe -l

  cmd=$(get_command $app)

  case "$app" in
  "ocean-cp" | "ocean-ncp")
    perf record -g -e probe_ocean:ci_start -e probe_ocean:ci_end -o $app.data $cmd
    mv $app.data ../../../
    ;;
  "lu-c" | "lu-nc")
    perf record -g -e probe_lu:ci_start -e probe_lu:ci_end -o $app.data $cmd
    mv $app.data ../../../
    ;;
  "water-nsquared" | "water-spatial")
    # does not work through script for some reason, but works manually
    pwd
    echo "perf record -g -e probe_water:ci_start -e probe_water:ci_end -o $app.data $cmd"
    perf record -g -e probe_water:ci_start -e probe_water:ci_end -o $app.data $cmd
    mv $app.data ../../
    ;;
  *)
    perf record -g -e probe_$app:ci_start -e probe_$app:ci_end -o $app.data $cmd
    mv $app.data ../../
    ;;
  esac

  perf probe -d ci_start -d ci_end

  perf probe -l

  cd - > /dev/null

  sleep 20

done
