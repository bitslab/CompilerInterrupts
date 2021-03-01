#!/usr/bin/gnuplot --persist

print "Input file: ", ifile
print "Output plot: ", ofile

set terminal pdf size 90cm,30cm noenhanced;
set output ofile;
set style data histogram;
set style histogram cluster gap 2;
set style fill solid 0.5 border -1;
set boxwidth 1;
set key autotitle columnheader;
set grid ytics;
set y2tics;
set ylabel "runtime overhead (%)";
set key spacing 2;
set key width -3;
set key inside;
set key font ", 25";

set title font ", 55";
set xtics font ", 55";
set xtics rotate by -45 offset -2, -2;
set ytics font ", 50" offset -2, -2;
set y2tics font ", 50" offset -2, -2;
set xlabel font ", 45" offset -12,-10,0;
set ylabel font ", 45" offset -15,0,0;

set bmargin 30;
set tmargin 10;
set lmargin 30;
set rmargin 20;

plot for [i=2:6] ifile using i:xtic(1) every ::0 ls i fillstyle pattern 3;
