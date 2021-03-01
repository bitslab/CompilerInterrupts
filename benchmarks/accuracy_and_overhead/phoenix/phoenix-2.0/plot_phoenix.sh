#!/bin/bash

plot_mr()
{
  file_name="phoenix-mr-$ad"
  out_file="phoenix-mr-$clock-$ad"
  command="set terminal pdf size 72cm,20cm noenhanced;"
  command=$command"set output '$out_file.pdf';"
  command=$command"set title 'Phoenix applications using map reduce with $clock clock (Allowed Deviation $ad)';"
  command=$command"set style line 2 lc rgb 'black' lt 1 lw 2;"
  command=$command"set style data histogram;"
  command=$command"set style histogram cluster gap 1;"
  command=$command"set style fill pattern border -1;"
  command=$command"set boxwidth 0.9;"
  #command=$command"set xtics format;"
  command=$command"set grid ytics;"
  command=$command"set xrange [0.2:];"
  command=$command"set ylabel \"runtime (normalized to Uninstrumented)\";"
  #command=$command"set xtics rotate by -70;"
  command=$command"set key spacing 1;"
  command=$command"set key width 3;"

  command=$command"set title font \", 40\";"
  command=$command"set xtics font \", 37\";"
  command=$command"set ytics font \", 30\";"
  command=$command"set ylabel font \", 37\";"

  command=$command"set yrange [0:2];"
  command=$command"set ytics (0,1,2);"

  command=$command"set tmargin at screen 0.85;"
  ### set bmargin at screen 0.1
  command=$command"set bmargin 10;"
  command=$command"set lmargin 10;"
  command=$command"set rmargin 5;"
  #command=$command"set lmargin at screen 0.02

  command=$command"set ylabel offset -3.5,0;"
  command=$command"set xtics offset 0,-1;"
  #command=$command"set key at graph 0.24, 0.85 horizontal samplen 0.5
  #command=$command"set key at screen 0.84,screen 1 horizontal maxrows 1 font \",37\";"
  command=$command"set key bmargin center maxrows 1 font \",37\";"
  #command=$command"set key auto columnheader;"

  # set size 0.135,0.135
  command=$command"plot \"$file_name.txt\" using 2:xtic(1) title \"Uninstrumented\" ls 2 fillstyle pattern 0, \
              '' using 3 title \"Optimized\" ls 2 fillstyle pattern 1, \
              '' using 4 title \"Naive\" ls 2 fillstyle pattern 5;"  
  echo $command | gnuplot
  echo "Plot has been generated in $out_file.pdf"
}

plot_seq()
{
  file_name="phoenix-seq-$ad"
  out_file="phoenix-seq-$clock-$ad"
  command="set terminal pdf size 72cm,20cm noenhanced;"
  command=$command"set output '$out_file.pdf';"
  command=$command"set title 'Phoenix sequential applications with $clock clock (Allowed Deviation $ad)';"
  command=$command"set style line 2 lc rgb 'black' lt 1 lw 2;"
  command=$command"set style data histogram;"
  command=$command"set style histogram cluster gap 1;"
  command=$command"set style fill pattern border -1;"
  command=$command"set boxwidth 0.9;"
  #command=$command"set xtics format;"
  command=$command"set grid ytics;"
  command=$command"set xrange [0.2:];"
  command=$command"set ylabel \"runtime (normalized to Uninstrumented)\";"
  #command=$command"set xtics rotate by -70;"
  command=$command"set key spacing 1;"
  command=$command"set key width 3;"

  command=$command"set title font \", 40\";"
  command=$command"set xtics font \", 37\";"
  command=$command"set ytics font \", 30\";"
  command=$command"set ylabel font \", 37\";"

  command=$command"set yrange [0:3];"
  command=$command"set ytics (0,1,2,3);"

  command=$command"set tmargin at screen 0.85;"
  ### set bmargin at screen 0.1
  command=$command"set bmargin 10;"
  command=$command"set lmargin 10;"
  command=$command"set rmargin 5;"
  #command=$command"set lmargin at screen 0.02

  command=$command"set ylabel offset -3.5,0;"
  command=$command"set xtics offset 0,-1;"
  #command=$command"set key at graph 0.24, 0.85 horizontal samplen 0.5
  #command=$command"set key at screen 0.84,screen 1 horizontal maxrows 1 font \",37\";"
  command=$command"set key bmargin center maxrows 1 font \",37\";"
  #command=$command"set key auto columnheader;"

  # set size 0.135,0.135
  command=$command"plot \"$file_name.txt\" using 2:xtic(1) title \"Uninstrumented\" ls 2 fillstyle pattern 0, \
              '' using 3 title \"Optimized\" ls 2 fillstyle pattern 1, \
              '' using 4 title \"Naive\" ls 2 fillstyle pattern 5;"  
  echo $command | gnuplot
  echo "Plot has been generated in $out_file.pdf"
}

plot_pthread()
{
  file_name="phoenix-pthread-$ad"
  out_file="phoenix-pthread-$clock-$ad"
  command="set terminal pdf size 72cm,20cm noenhanced;"
  command=$command"set output '$out_file.pdf';"
  command=$command"set title 'Phoenix applications using pthread with $clock clock (Allowed Deviation $ad)';"
  command=$command"set style line 2 lc rgb 'black' lt 1 lw 2;"
  command=$command"set style data histogram;"
  command=$command"set style histogram cluster gap 1;"
  command=$command"set style fill pattern border -1;"
  command=$command"set boxwidth 0.9;"
  #command=$command"set xtics format;"
  command=$command"set grid ytics;"
  command=$command"set xrange [0.2:];"
  command=$command"set ylabel \"runtime (normalized to Uninstrumented)\";"
  #command=$command"set xtics rotate by -70;"
  command=$command"set key spacing 1;"
  command=$command"set key width 3;"

  command=$command"set title font \", 40\";"
  command=$command"set xtics font \", 37\";"
  command=$command"set ytics font \", 30\";"
  command=$command"set ylabel font \", 37\";"

  command=$command"set yrange [0:2];"
  command=$command"set ytics (0,1,2);"

  command=$command"set tmargin at screen 0.85;"
  ### set bmargin at screen 0.1
  command=$command"set bmargin 10;"
  command=$command"set lmargin 10;"
  command=$command"set rmargin 5;"
  #command=$command"set lmargin at screen 0.02

  command=$command"set ylabel offset -3.5,0;"
  command=$command"set xtics offset 0,-1;"
  #command=$command"set key at graph 0.24, 0.85 horizontal samplen 0.5
  #command=$command"set key at screen 0.84,screen 1 horizontal maxrows 1 font \",37\";"
  command=$command"set key bmargin center maxrows 1 font \",37\";"
  #command=$command"set key auto columnheader;"

  # set size 0.135,0.135
  command=$command"plot \"$file_name.txt\" using 2:xtic(1) title \"Uninstrumented\" ls 2 fillstyle pattern 0, \
              '' using 3 title \"Optimized\" ls 2 fillstyle pattern 1, \
              '' using 4 title \"Naive\" ls 2 fillstyle pattern 5;"  
  echo $command | gnuplot
  echo "Plot has been generated in $out_file.pdf"
}

if [ $# -ne 2 ]; then
  echo "Usage: ./plot_bar_chart_splash2.sh <predictive/instantaneous> <allowed deviation>"
  exit
fi

ad=$2
clock=$1

plot_mr
plot_seq
plot_pthread
