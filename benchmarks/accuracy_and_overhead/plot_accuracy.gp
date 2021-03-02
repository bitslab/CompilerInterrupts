#!/usr/bin/gnuplot --persist

print "Input file: ", ifile
print "Output plot: ", ofile

set terminal pdf size 90cm,30cm noenhanced;
set output ofile;
set style data histogram;
set style fill solid;
set xtics font ", 55";
set xtics rotate by -45 offset -2, -2;
set ytics font ", 50" offset -2, -2;
set key font ", 20";
set bmargin 30;
set tmargin 15;
set lmargin 35;
set rmargin 20;
set xlabel font ", 45" offset -12,-10,0;
set ylabel font ", 45" offset -18,0,0;
set key spacing 2;
set key width 1;
set key font ", 25"; 
set grid ytics;
set errorbars linecolor black;
set ylabel "Interval error distribution (cycles)";
set style histogram cluster gap 2 errorbars linewidth 6;

plot [:] [-3000:15000] for [t=2:6] ifile using t:(column(columnhead(t)."-10")):(column(columnhead(t)."-90")):xtic(1) ti col lt t, for [t=2:6] for [p in "1 5 10 30 70 90 95 99"] ifile using (column(0)+t*0.125-1.5):(column(columnhead(t)."-".p)):(p) w labels textcolor lt t noti
