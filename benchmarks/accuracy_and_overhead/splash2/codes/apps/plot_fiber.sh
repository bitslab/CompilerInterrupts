#!/bin/bash

plot() {
  bench="$1"
  ad=$2
  FILE_NAME="splash2-fiber-exp-over-push-interval.pdf"

  command="set terminal pdf monochrome;"
  command=$command"set output '$FILE_NAME';"
  command=$command"set key horizontal;"
  command=$command"set style function linespoints;"
  command=$command"set key center top;"
  command=$command"set key samplen 2;"
  command=$command"set title 'Splash2 water-nsquared performance benchmark with 32 threads/fibers over varying quanta';"
  command=$command"set xlabel 'yield interval (in #instructions)';"
  command=$command"set ylabel 'duration (ms)';"
  command=$command"set xrange [0:50000];"
  command=$command"set xtics 0,5000,50000;"
  command=$command"set yrange [0.0:500.0];"
  command=$command"set ytics 0, 50, 500;"
  command=$command"set key on horizontal;"

  file="instantaneous_stats/fiber_exp_stats.txt"
  command=$command"plot for[in=0:2] '$file' i in u 1:2 w lines t columnheader(1)"
  echo $command | gnuplot
  echo "Plot has been generated in $FILE_NAME"
}

plot
