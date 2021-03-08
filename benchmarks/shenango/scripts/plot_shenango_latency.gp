#!/usr/bin/gnuplot --persist

print "Output plot: ", ofile
print "col_index: ", col_index
print "ylabel: ", ylab
print "ymax: ", ymax
print "key_status: ", key_status

set terminal pdf linewidth 4 font '25' size 50cm,20cm enhanced;
set output ofile;
set style function linespoints;
set key autotitle columnhead;
if (key_status == 1) {
  set key bottom horizontal font ", 50";
}
else {
  set key off;
}
set ytics font ", 50" offset 0, -2, 0;
set xtics font ", 50" offset 0, -2, 0;
set ylabel ylab font ", 50" offset -12,0,0;
set xrange [:];
set yrange [0:ymax];
set bmargin 10;
set tmargin 5;
set lmargin 25;
set rmargin 10;

plot \
  "standalone_summary_mc" using 1:col_index w lp lw 2 pt 1 ps 1 lc 1 title "Shenango", \
  "pthread-memcached_summary_mc" using 1:col_index w lp lw 2 pt 2 ps 1 lc 2 title "Pthreads", \
  "pthread-memcached-swaptions_summary_mc" using 1:col_index w lp lw 2 pt 3 ps 1 lc 3 title "Pth/batch", \
  "cpuminer1000_summary_mc" using 1:col_index w lp lw 2 pt 4 ps 1 lc 4 title "CI 1000", \
  "cpuminer2000_summary_mc" using 1:col_index w lp lw 2 pt 5 ps 1 lc 5 title "CI 2000", \
  "cpuminer4000_summary_mc" using 1:col_index w lp lw 2 pt 6 ps 1 lc 6 title "CI 4000", \
  "cpuminer8000_summary_mc" using 1:col_index w lp lw 2 pt 7 ps 1 lc 7 title "CI 8000", \
  "cpuminer16000_summary_mc" using 1:col_index w lp lw 2 pt 8 ps 1 lc 8 title "CI 16000", \
  "cpuminer32000_summary_mc" using 1:col_index w lp lw 2 pt 9 ps 1 lc 9 title "CI 32000", \
  "cpuminer64000_summary_mc" using 1:col_index w lp lw 2 pt 10 ps 1 lc 10 title "CI 64000";
