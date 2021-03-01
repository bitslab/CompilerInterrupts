#!/bin/bash

ifile="bar_chart.csv"
benchmark="Methods"
ofile="Methods.pdf"
command="set terminal pdf size 24cm,12cm noenhanced;"
#command=$command"ORIGINAL = \"#99ffff\"; OPTIMISTIC = \"#4671d5\"; FULL= \"#ff0000\"; ANYTHING = \"#f36e00\""

command=$command"set output '$ofile';"

#command=$command"set key horizontal;"
#command=$command"set key top left;"

command=$command"set auto x;"
command=$command"set style line 2 lc rgb 'black' lt 1 lw 2;"
command=$command"set yrange [50000:500000];"
command=$command"set style data histogram;"
command=$command"set style histogram cluster gap 1;"
#command=$command"set style fill solid border -1;"
#command=$command"set boxwidth 0.9;"
#command=$command"set xtic scale 0;"
command=$command"set ylabel '#Duration (us)';"

#command=$command"set ytics 0, 50000, 300000;"
#command=$command"set datafile separator ',';"
#command=$command"plot './$ifile' using 1:2 title columnheader(1) with lp $pt lw 2 ps .75;"
command=$command"plot \"$ifile\" using 2:xtic(1) title \"Original\" ls 2 fillstyle pattern 0, '' using 3 title 'Optimistic' ls 2 fillstyle pattern 2, '' using 4 title \"Full\" ls 2 fillstyle pattern 3;"

echo $command | gnuplot
echo "Plot has been generated in $ofile"

exit

