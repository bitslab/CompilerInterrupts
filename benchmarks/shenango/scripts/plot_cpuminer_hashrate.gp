#!/usr/bin/gnuplot --persist

print "Output plot: ", ofile

set terminal pdf linewidth 4 size 50cm,20cm noenhanced;
set output ofile;
set key autotitle columnhead;
set key font ", 50";
set ytics font ", 50" offset 0, -2, 0;
set xtics font ", 50" offset 0, -2, 0;
set xlabel "Memcached Offered Load (million requests/s)" font ", 50" offset 0,-6,0;
set ylabel "Achieved Hash Rate (%)" font ", 50" offset -10,0,0;
set yrange [0:100];
set xrange [0:];
set bmargin 15;
set tmargin 5;
set lmargin 25;
set rmargin 10;

plot \
  "cpuminer1000_hashrate" using 1:5 w lp lw 2 pt 4 ps 1 lc 4 title "CI 1000", \
  "cpuminer2000_hashrate" using 1:5 w lp lw 2 pt 5 ps 1 lc 5 title "CI 2000", \
  "cpuminer4000_hashrate" using 1:5 w lp lw 2 pt 6 ps 1 lc 6 title "CI 4000", \
  "cpuminer8000_hashrate" using 1:5 w lp lw 2 pt 7 ps 1 lc 7 title "CI 8000", \
  "cpuminer16000_hashrate" using 1:5 w lp lw 2 pt 8 ps 1 lc 8 title "CI 16000", \
  "cpuminer32000_hashrate" using 1:5 w lp lw 2 pt 9 ps 1 lc 9 title "CI 32000", \
  "cpuminer64000_hashrate" using 1:5 w lp lw 2 pt 10 ps 1 lc 10 title "CI 64000";
