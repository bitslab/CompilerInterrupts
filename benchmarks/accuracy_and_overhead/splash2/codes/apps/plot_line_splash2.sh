#!/bin/bash

plot() {
  bench="$1"
  ad=$2
  if [ $pinned -eq 1 ]; then
    suffix="-pinned"
  else
    suffix=""
  fi
  FILE_NAME="splash2-$1-$clock_name-over-threads-ad$ad$suffix.pdf"

  command="set terminal pdf monochrome;"
  command=$command"set output '$FILE_NAME';"
  command=$command"set datafile missing \"?\";"
  command=$command"set key horizontal;"
  command=$command"set style function linespoints;"
  command=$command"set key center top;"
  command=$command"set key samplen 2;"
  command=$command"set title 'Splash2 $bench performance with $clock_name clock over varying threads';"
  if [ $pinned -eq 1 ]; then
    command=$command"set xlabel '# Threads on a single core / # Fibers on a single thread';"
  else
    command=$command"set xlabel '# Threads/Fibers';"
  fi
  command=$command"set ylabel 'duration (ms)';"

  # following code is commented out
  if [ 0 -eq 1 ]; then
    command=$command"set xrange [0:32];"
    command=$command"set xtics 0,4,32;"
    if [ "$bench" == "water-ns" ]; then
      command=$command"set yrange [0.0:250.0];"
      command=$command"set ytics 0, 30, 250;"
    elif [ "$bench" == "water-sp" ]; then
      command=$command"set yrange [0.0:250.0];"
      command=$command"set ytics 0, 30, 250;"
    elif [ "$bench" == "ocean-ncp" ]; then
      command=$command"set yrange [0.0:250.0];"
      command=$command"set ytics 0, 30, 250;"
    elif [ "$bench" == "ocean-cp" ]; then
      command=$command"set yrange [0.0:250.0];"
      command=$command"set ytics 0, 25, 250;"
    elif [ "$bench" == "barnes" ]; then
      command=$command"set yrange [0.0:700.0];"
      command=$command"set ytics 0, 60, 660;"
    elif [ "$bench" == "volrend" ]; then
      command=$command"set yrange [500.0:900.0];"
      command=$command"set ytics 500, 40, 900;"
    elif [ "$bench" == "fmm" ]; then
      command=$command"set yrange [0.0:600.0];"
      command=$command"set ytics 0, 60, 600;"
    elif [ "$bench" == "raytrace" ]; then
      command=$command"set yrange [300.0:500.0];"
      command=$command"set ytics 300, 20, 500;"
    elif [ "$bench" == "radiosity" ]; then
      command=$command"set yrange [0.0:2500.0];"
      command=$command"set ytics 0, 250, 2500;"
    fi
  fi
  command=$command"set key on horizontal;"

  first=1
  files="$bench-perf_orig-ad$ad-cl$clock$suffix.txt $bench-perf_naive-ad$ad-cl$clock$suffix.txt $bench-perf_opt-ad$ad-cl$clock$suffix.txt "
  files=$files"$bench-perf_orig_fiber-ad$ad-cl$clock$suffix.txt $bench-perf_naive_fiber-ad$ad-cl$clock$suffix.txt $bench-perf_opt_fiber-ad$ad-cl$clock$suffix.txt"
  i=5
  for f in $files
  do
    lines=`cat $f | wc -l`
    if [ $lines -eq 1 ]; then
      continue
    fi
    i=`expr $i + 1`
    pt="pt $i"
    if [ $first -eq 1 ]; then
      command=$command"plot '$f' using 1:2 title columnheader(1) with lp $pt lw 2 ps .75"
      first=0
    else
      command=$command", '$f' using 1:2 title columnheader(1) with lp $pt lw 2 ps .75"
    fi
  done
  echo $command | gnuplot
  echo "Plot has been generated in $FILE_NAME"
}

if [ $# -ne 2 ]; then
  echo "Usage: ./plot_line_splash2.sh <clock type - 0/1> <core pinning? 0/1>"
  echo "Pinning is generally set to 0 for predictive clock"
  #echo "Please configure the parameters according to your need, by changing this file"
  #echo "Set pinned flag for instantaneous clock if needed"
  exit
fi

clock=$1
pinned=$2
allwd_dev=100
if [ $clock -eq 0 ]; then
  clock_name="predictive"
elif [ $clock -eq 1 ]; then
  clock_name="instantaneous"
else
  echo "Clock can only be 0(predictive) or 1(instantaneous)"
fi
benches="water-nsquared water-spatial ocean-ncp ocean-cp barnes volrend fmm raytrace radiosity"
for bench in $benches
do
  plot $bench $allwd_dev
done

