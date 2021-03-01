#!/bin/bash

#files="stats_push.csv stats_single_global.csv orig_stats.csv full_stats.csv"
files="waterns_stats_push_graph_1_thread.csv waterns_stats_push_graph_16_threads.csv waterns_stats_push_graph_32_threads.csv"
benchmark="vsThreads"
ofile="WaterNSOverPushInterval.pdf"
command="set terminal pdf monochrome;"
command=$command"set output '$ofile';"
#command=$command"set title 'Splash2 ocean-contiguous-partitions benchmark';"
command=$command"set key horizontal;"
command=$command"set key top left;"
command=$command"set xlabel 'Push Interval (#instructions)';"
command=$command"set ylabel 'Duration (ms)';"
command=$command"set yrange [0:350];"
command=$command"set xrange [1000:10000];"
command=$command"set ytics 0, 50, 350;"
command=$command"set xtics 1000, 1000, 10000;"
command=$command"set datafile separator ',';"
first=1
i=1
for f in $files
do
  echo "Plotting $f"
	#command=$command"plot '$ifile' using 2:4 with lp ps .75"
	#echo $command | gnuplot
  if [ $first -eq 1 ]; then
    command=$command"plot './$f' using 1:2 title columnheader(1) with lp lw 4 ps .75"
    first=0
  else
    command=$command", './$f' using 1:2 title columnheader(1) with lp lw 4 ps .75"
  fi  
done

echo $command | gnuplot
echo "Plot has been generated in $ofile"

exit

