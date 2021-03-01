#!/bin/bash

plot()
{
  thread=$1
  ad=$2
  clock=$3
  clock_name=$4
  if [ $pinned -eq 1 ]; then
    suffix="-pinned"
  else
    suffix=""
  fi
  ifile="perf_stats-norm-th$thread-ad$ad-cl$clock$suffix.txt"
  ofile="splash2_stats-${clock_name}_clock-th$thread-ad$ad$suffix.pdf"
  command="set terminal pdf size 72cm,20cm noenhanced;"
  command=$command"set output '$ofile';"
  command=$command"set datafile missing \"?\";"
  command=$command"set style line 2 lc rgb 'black' lt 1 lw 2;"
  command=$command"set style data histogram;"
  command=$command"set style histogram cluster gap 1;"
  command=$command"set style fill pattern border -1;"
  command=$command"set boxwidth 0.9;"
  command=$command"set grid ytics;"
  command=$command"set ylabel \"runtime (normalized to original pthread runtime)\";"
  command=$command"set key spacing 1;"
  command=$command"set key width 3;"

  command=$command"set title font \", 40\";"
  if [ $pinned -eq 1 ]; then
    command=$command"set title 'Splash2 performance benchmark with $clock_name clock over $thread threads running on 1core/fibers running on 1thread';"
  else
    command=$command"set title 'Splash2 performance benchmark with $clock_name clock over $thread threads/fibers';"
  fi
  command=$command"set xtics font \", 30\";"
  command=$command"set ytics font \", 30\";"
  command=$command"set xlabel font \", 30\";"
  command=$command"set ylabel font \", 30\";"

  command=$command"set yrange [0:];"
  #command=$command"set ytics (0,1,2);"

  command=$command"set tmargin at screen 0.85;"
  ### set bmargin at screen 0.1
  command=$command"set bmargin 10;"
  command=$command"set lmargin 20;"
  command=$command"set rmargin 5;"


  command=$command"set ylabel offset -3.5,0;"
  #command=$command"set xtics offset 0,-1;"
  #command=$command"set key at graph 0.24, 0.85 horizontal samplen 0.5
  #command=$command"set key at screen 0.84,screen 1 horizontal maxrows 1 font \",37\";"
  command=$command"set key bmargin center maxrows 1 font \",37\";"
  #command=$command"set key auto columnheader;"

  # set size 0.135,0.135
  if [ $clock -eq 0 ]; then
    command=$command"plot \"$ifile\" using 2:xtic(1) title \"Orig\" ls 2 fillstyle pattern 0, \
                '' using 3 title \"Opt\" ls 2 fillstyle pattern 1, \
                '' using 4 title \"Naive\" ls 2 fillstyle pattern 2;"
  else
    command=$command"plot \"$ifile\" using 2:xtic(1) title \"Orig\" ls 2 fillstyle pattern 0, \
                '' using 3 title \"Opt\" ls 2 fillstyle pattern 1, \
                '' using 4 title \"Naive\" ls 2 fillstyle pattern 2, \
                '' using 5 title \"Orig-Fiber\" ls 2 fillstyle pattern 3, \
                '' using 6 title \"Opt-Fiber\" ls 2 fillstyle pattern 4, \
                '' using 7 title \"Naive-Fiber\" ls 2 fillstyle pattern 5;"  
  fi
  echo $command | gnuplot
  echo "Plot has been generated in $ofile"
}

convert_to_normalized()
{
  thread=$1
  ad=$2
  clock=$3
  if [ $pinned -eq 1 ]; then
    suffix="-pinned"
  else
    suffix=""
  fi
  file_name="perf_stats-th$thread-ad$ad-cl$clock$suffix.csv"
  conv_name="perf_stats-norm-th$thread-ad$ad-cl$clock$suffix.txt"
  first=0
  echo -e "Program\tUninstrumented\tOptimized\tNaive\tUninstrumented-Fiber\tOptimized-Fiber\tNaive-Fiber" > $conv_name
  while read line
  do
    if [ $first -eq 1 ]; then
      progname=`echo $line | cut -d' ' -f 1`
      origtime=`echo $line | cut -d' ' -f 2`
      naivetime=`echo $line | cut -d' ' -f 3`
      opttime=`echo $line | cut -d' ' -f 4`
      origfibertime=`echo $line | cut -d' ' -f 5`
      naivefibertime=`echo $line | cut -d' ' -f 6`
      optfibertime=`echo $line | cut -d' ' -f 7`
      normnaive=`echo "scale = 3; ($naivetime / $origtime)" | bc -l`
      normopt=`echo "scale = 3; ($opttime / $origtime)" | bc -l`

      echo -ne "$program $origtime $opttime $naivetime "
      echo -ne "$progname\t1\t$normopt\t$normnaive" >> $conv_name

      # For some benchmarks, the benchmark does not run with fiber without fiber_yields. For them, replace data with "?"
      if [ "$origfibertime" != "?" ]; then
        normfiberorig=`echo "scale = 3; ($origfibertime / $origtime)" | bc -l`
      else
        normfiberorig=$origfibertime
      fi
      normfibernaive=`echo "scale = 3; ($naivefibertime / $origtime)" | bc -l`
      normfiberopt=`echo "scale = 3; ($optfibertime / $origtime)" | bc -l`
      echo -e "$origfibertime $optfibertime $naivefibertime"
      echo -e "\t$normfiberorig\t$normfiberopt\t$normfibernaive" >> $conv_name
    else
      first=1
    fi
  done < $file_name  
}

if [ $# -ne 2 ]; then
  echo "Usage: ./plot_bar_chart_splash2.sh <clock type - 0/1> <core pinning? 0/1>"
  echo "Pinning is generally set to 0 for predictive clock"
  #echo "Please configure the parameters according to your need, by changing this file"
  #echo "Set pinned flag for instantaneous clock if needed"
  exit
fi

clock=$1
pinned=$2
allwd_dev=100
if [ $clock -eq 0 ]; then
  clock_name="predictive"
elif [ $clock -eq 1 ]; then
  clock_name="instantaneous"
else
  echo "Clock can only be 0(predictive) or 1(instantaneous)"
fi
THREADS="1 2 4 8 16 32"
for thread in $THREADS
do
  convert_to_normalized $thread $allwd_dev $clock
  plot $thread $allwd_dev $clock $clock_name
done

