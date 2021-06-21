#!/usr/bin/gnuplot --persist

print "CI file data path: ", ci_path
print "HWC file data path: ", hwc_path
print "Output plot: ", ofile

set terminal pdf;
set output ofile;
set key horizontal;
set style function linespoints;
set key center top;
set key samplen 2;
set key font ",16";
set datafile missing "?";
set style line 1 lc rgb 'royalblue' lw 2 ps .75;
set style line 2 lc rgb 'red' lw 2 ps .75;
set xlabel 'average interval size (cycles)';
set key on horizontal;
set key autotitle columnheader;
set ylabel 'overhead (%)';
set xlabel font ", 17" offset -1,0,0;
set ylabel font ", 17" offset 1,0,0;
set bmargin 5;

set logscale x 2;
set ytics 100
set yrange [1:500];
set xrange [500:640000];

command_ci = sprintf("ls -1B %s", ci_path)
command_hwc = sprintf("ls -1B %s", hwc_path)

print "command for CI files: ", command_ci
print "command for HWC files: ", command_hwc

ci_files_list = system(command_ci)
hwc_files_list = system(command_hwc)

plot for [file_ci in ci_files_list] file_ci u 1:2 w lp ls 1 notitle, for [file_hwc in hwc_files_list] file_hwc u 1:2 w lp ls 2 notitle
