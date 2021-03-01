#!/bin/bash

plot() {
  bench="$1"
  ad=$2
  clock=1
  FILE_NAME="$bench-ic_vs_pc-cl$clock-ad$ad.pdf"

  command="set terminal pdf monochrome;"
  command=$command"set output '$FILE_NAME';"
  command=$command"set key horizontal;"
  command=$command"set style function linespoints;"
  command=$command"set key center top;"
  command=$command"set key samplen 2;"
  command=$command"set title 'Splash2 $bench software instruction counter vs h/w performance counter $clock_name';"
  command=$command"set xlabel 'average interval size (cycles)';"
  command=$command"set ylabel 'duration (ms)';"
  command=$command"set key on horizontal;"

#files="$bench-perf_lc-ad$ad-cl${clock}.txt $bench-perf_papi-ad$ad-cl${clock}.txt $bench-perf_orig-ad$ad-cl${clock}.txt"
  orig_duration=`cat $bench-perf_orig-ad$ad-cl${clock}.txt | tail --lines=1`
  command=$command"plot '$bench-perf_lc-ad$ad-cl${clock}.txt' every ::1 using 3:2 title \"SIC\" with lp lt 3 lw 2 ps .75"
#command=$command", '$bench-perf_lc-ad$ad-cl${clock}.txt' every ::1 using 3:2:4 with xerrorbars ls 1 notitle"
  command=$command", '$bench-perf_papi-ad$ad-cl${clock}.txt' every ::1 using 3:2 title \"HPC\" with lp lt 2 lw 2 ps .75"
#command=$command", '$bench-perf_papi-ad$ad-cl${clock}.txt' every ::1 using 3:2:4 with xerrorbars ls 1 notitle"
  command=$command", $orig_duration title \"Original\" lt 1 lw 2 ps .05;"
  echo $command | gnuplot
  echo "Plot has been generated in $FILE_NAME"
}

clock=1
allwd_dev=100
benches="water-nsquared water-spatial ocean-ncp ocean-cp barnes volrend fmm raytrace radiosity"
for bench in $benches
do
  plot $bench $allwd_dev
done

