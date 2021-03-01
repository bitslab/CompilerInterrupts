#!/bin/bash

plot() {
  bench="$1"
  ad=$2
  FILE_NAME="splash2-$1-_intv_dist_ic-ad$ad.pdf"

  command="set terminal pdf monochrome;"
  command=$command"set output '$FILE_NAME';"
  command=$command"set key horizontal;"
  command=$command"set style function linespoints;"
  command=$command"set key center top;"
  command=$command"set key samplen 2;"
  command=$command"set title 'Splash2 $bench distribution of push intervals (in cycles)';"
  command=$command"set datafile separator \",\";"
#command=$command"set key autotitle columnhead;"
  command=$command"set xlabel 'Push Seq No.';"
  command=$command"set ylabel 'Push Interval (IR instructions)';"
  if [ "$bench" == "water-ns" ]; then
    if [ 1 -eq 1 ] ; then
    command=$command"set xrange [0:85000];"
    command=$command"set xtics 0,10000,85000;"
    else
    command=$command"set xrange [0:10];"
    command=$command"set xtics 0,1,10;"
    fi
    command=$command"set yrange [0.0:6000];"
    command=$command"set ytics 0, 1000, 6000;"
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
  command=$command"set key on horizontal;"

  file="${bench}_lc_ic_vs_tsc.txt"
  command=$command"plot '$file' using 1:2 with lines"
  echo $command | gnuplot
  echo "Plot has been generated in $FILE_NAME"
}

if [ $# -ne 2 ]; then
  echo "Usage: ./plot_bar_chart_splash2.sh <predictive/instantaneous> <allowed deviation>"
  exit
fi

clock=$1
allwd_dev=100
#benches="water-ns water-sp ocean-ncp ocean-cp barnes volrend fmm raytrace radiosity"
benches="water-ns"
for bench in $benches
do
  plot $bench $allwd_dev
done

