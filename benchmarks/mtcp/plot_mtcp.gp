#!/usr/bin/gnuplot --persist

print "Input throughput file: ", throughput_file
print "Input latency file: ", latency_file
print "Output plot: ", ofile
print "Yrange: ", yr

set terminal pdf size 5in,2in;
set output ofile;
set key horizontal;
set style function linespoints;
set key center top;
set key samplen 2;
set y2tics;
set linetype 6 lc rgb 'black';
set linetype 8 lc rgb 'black';
set xrange [:32];
set yrange [:yr];
set logscale y2;
set logscale x 2;
set y2label 'Latency (us)';
set ylabel 'Throughput (Mbps)';
set xlabel '#Connections per thread';
set datafile missing "?";
set key font ",11";

plot throughput_file using 1:2 with lp ls 6 lc rgb "red" title "Orig-Throughput", \
     throughput_file using 1:3 with lp ls 8 lc rgb "red" title "CI-Throughput", \
     throughput_file using 1:4 with lp ls 3 lc rgb "red" title "Kernel-Throughput", \
     latency_file using 1:2 axes x1y2 with lp ls 6 lc rgb "blue" title "Orig-Latency", \
     latency_file using 1:3 axes x1y2 with lp ls 8 lc rgb "blue" title "CI-Latency", \
     latency_file using 1:4 axes x1y2 with lp ls 3 lc rgb "blue" title "Kernel-Latency";
