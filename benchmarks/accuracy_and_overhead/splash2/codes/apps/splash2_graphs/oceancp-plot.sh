#!/bin/bash

#files="stats_push.csv stats_single_global.csv orig_stats.csv full_stats.csv"
files="oceancp_opt_stats.csv oceancp_orig_stats.csv oceancp_full_stats.csv"
benchmark="vsThreads"
ofile="OceanCPOverThreads.pdf"
command="set terminal pdf monochrome;"
command=$command"set output '$ofile';"
#command=$command"set title 'Splash2 ocean-contiguous-partitions benchmark';"
command=$command"set key horizontal;"
command=$command"set key top left;"
command=$command"set xlabel '#Threads';"
command=$command"set ylabel '#Duration (ms)';"
command=$command"set yrange [0:300];"
command=$command"set xrange [0:32];"
command=$command"set ytics 0, 50, 300;"
command=$command"set xtics 0,4,32;"
command=$command"set datafile separator ',';"
first=1
i=1
for f in $files
do
	#command=$command"plot '$ifile' using 2:4 with lp ps .75"
	#echo $command | gnuplot
  if [ $first -eq 1 ]; then
    command=$command"plot './$f' using 1:2 title columnheader(1) with lp lw 2 ps .75"
    first=0
  else
    command=$command", './$f' using 1:2 title columnheader(1) with lp lw 2 ps .75"
  fi  
done

echo $command | gnuplot
echo "Plot has been generated in $ofile"

exit

