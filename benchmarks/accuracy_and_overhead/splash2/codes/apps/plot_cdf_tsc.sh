#!/bin/bash

plot() {
  config=$1
  clock=1
  ad=100
  #benches="water-nsquared water-spatial ocean-ncp ocean-cp barnes volrend fmm raytrace radiosity"
  benches="water-nsquared water-spatial ocean-ncp ocean-cp volrend fmm raytrace radiosity" # because there are erroneous results in barnes for ir ic

  if [ $config -eq 1 ]; then
    out_file="splash2-cdf_intv_tsc-ad$ad-cl$clock.pdf"
    infile_suffix="_tsc"
    metric="in cycles"
    add_cmd="set xrange [0:1000000];"
  elif [ $config -eq 2 ]; then
    out_file="splash2-cdf_intv_ir_ic-ad$ad-cl$clock.pdf"
    infile_suffix="_ic"
    metric="in IR instructions"
  elif [ $config -eq 3 ]; then
    out_file="splash2-cdf_intv_ret_ic-ad$ad-cl$clock.pdf"
    infile_suffix="_ret_ic"
    metric="in retired instructions"
    #add_cmd="set xrange [0:30000];"
  fi

  command="set terminal pdf;"
  command=$command"load \"../custom_palette\";"
  command=$command"set output '$out_file';"
  command=$command"set title 'splash2 $bench cumulative distribution of interval sizes ($metric)';"
  command=$command"set ylabel '%samples';"
  command=$command"set xlabel 'interval duration ($metric)';"
  command=$command$add_cmd
  #command=$command"unset key;"

  # for interval in cycles, without the this limit, the graph is not visible because of large outliers
  # command=$command"set xrange [0:100000];"

  first=1

  for bench in $benches
  do
    in_file="cdf-${bench}${infile_suffix}.txt"
    if [ $first -eq 1 ]; then
      first=0
      command=$command"plot '$in_file' u 2:1 w lines lw 2 title '$bench'"
    else
      command=$command", '$in_file' u 2:1 w lines lw 2 title '$bench'"
    fi
  done
  echo $command
  echo $command | gnuplot
  echo "Plot has been generated in $out_file"
}

plot 1
plot 2
plot 3
