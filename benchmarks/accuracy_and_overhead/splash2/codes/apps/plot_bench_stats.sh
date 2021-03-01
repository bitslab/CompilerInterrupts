#!/bin/bash

plot_ad() {
  config=$1
  pi=5000
  benches="water-nsquared water-spatial ocean-ncp ocean-cp barnes volrend fmm raytrace radiosity"

  # for interval in cycles, without the this limit, the graph is not visible because of large outliers
  # command=$command"set xrange [0:100000];"

  for bench in $benches
  do
    if [ $config -eq 1 ]; then
      out_file="splash2-$bench-intv_err_tsc_vs_duration-pi$pi.pdf"
      metric="in cycles"
      key1="2:6:3"
      key2="2:6"
#a  dd_cmd="set xrange [0:100000];"
    elif [ $config -eq 2 ]; then
      out_file="splash2-$bench-intv_err_ir_ic_vs_duration-pi$pi.pdf"
      metric="in IR instructions"
      key1="4:6:5"
      key2="4:6"
    fi

    command="set terminal pdf;"
    command=$command"load \"../custom_palette\";"
    command=$command"set key outside;"
    command=$command"unset autoscale;"
    command=$command"set autoscale xmax;"
    command=$command"set autoscale ymax;"
    command=$command"set datafile separator ',';"
    command=$command"set ylabel 'duration (in ms)';"
    command=$command"set title \"splash2 $bench performance comparison over \ninterval errors ($metric) by changing the allowed deviation\";"
    command=$command"set xlabel 'interval error ($metric)';"
    command=$command"set output '$out_file';"

    first=1
    type=1
    in_files="${bench}-acc_vs_perf_lc.txt ${bench}-acc_vs_perf_lc_fiber.txt"

    for in_file in $in_files
    do
      if [ $first -eq 1 ]; then
        first=0
        command=$command"plot '$in_file' every ::2 u $key1 w xerrorbars ls $type notitle, '$in_file' every ::2 u $key2 w lp ls $type title 'PThread-LC'"
      else
        lines=`cat $in_file | wc -l`
        if [ $lines -gt 2 ]; then
          command=$command", '$in_file' every ::2 u $key1 w xerrorbars lc $type notitle, '$in_file' every ::2 u $key2 w lp ls $type title 'Fiber-LC'"
        fi
      fi
      type=`expr $type + 1`
    done

    in_file="${bench}-acc_vs_perf_orig.txt"
    duration=`cat $in_file | tail --lines=1`
    command=$command", $duration title 'Orig'"

    in_file="${bench}-acc_vs_perf_orig_fiber.txt"
    lines=`cat $in_file | wc -l`
    if [ $lines -gt 2 ]; then
      duration=`cat $in_file | tail --lines=1`
      command=$command", $duration title 'Orig-Fiber'"
    fi

#echo $command
    echo $command | gnuplot
    echo "Plot has been generated in $out_file"
  done
}

plot_ad_basic() {
  pi=5000
  benches="water-nsquared water-spatial ocean-ncp ocean-cp barnes volrend fmm raytrace radiosity"
  out_file="splash2-allowed_dev_vs_duration-pi$pi.pdf"

  command="set terminal pdf;"
  command=$command"load \"../custom_palette\";"
  command=$command"set key outside;"
  command=$command"unset autoscale;"
  command=$command"set autoscale xmax;"
  command=$command"set autoscale ymax;"
  command=$command"set datafile separator ',';"
  command=$command"set ylabel 'duration (in ms)';"
  command=$command"set title \"splash2 performance comparison over different \nallowed deviations (in IR instructions)\";"
  command=$command"set xlabel 'allowed deviation (in IR instructions)';"
  command=$command"set output '$out_file';"

  first=1
  type=1
  for bench in $benches
  do
    in_file="${bench}-acc_vs_perf_lc.txt"

    if [ $first -eq 1 ]; then
      first=0
      command=$command"plot '$in_file' every ::2 u 1:6 w lp ls $type title '$bench'"
    else
      command=$command", '$in_file' every ::2 u 1:6 w lp ls $type title '$bench'"
    fi
    type=`expr $type + 1`
  done

  #echo $command
  echo $command | gnuplot
  echo "Plot has been generated in $out_file"
}

plot_pi() {
  config=$1
  ad=100
  benches="water-nsquared water-spatial ocean-ncp ocean-cp barnes volrend fmm raytrace radiosity"

  # for interval in cycles, without the this limit, the graph is not visible because of large outliers
  # command=$command"set xrange [0:100000];"

  for bench in $benches
  do
    if [ $config -eq 1 ]; then
      out_file="splash2-$bench-intv_err_tsc_vs_duration-ad$ad.pdf"
      metric="in cycles"
      key1="2:6:3"
      key2="2:6"
#a  dd_cmd="set xrange [0:100000];"
    elif [ $config -eq 2 ]; then
      out_file="splash2-$bench-intv_err_ir_ic_vs_duration-ad$ad.pdf"
      metric="in IR instructions"
      key1="4:6:5"
      key2="4:6"
    fi

    command="set terminal pdf;"
    command=$command"load \"../custom_palette\";"
    command=$command"set key outside;"
    command=$command"unset autoscale;"
    command=$command"set autoscale xmax;"
    command=$command"set autoscale ymax;"
    command=$command"set datafile separator ',';"
    command=$command"set ylabel 'duration (in ms)';"
    command=$command"set title \"splash2 $bench performance comparison over \ninterval errors ($metric), by changing the push interval\";"
    command=$command"set xlabel 'interval error ($metric)';"
    command=$command"set output '$out_file';"

    first=1
    type=1
    in_files="${bench}-push_intv_vs_perf_lc.txt ${bench}-push_intv_vs_perf_lc_fiber.txt"

    for in_file in $in_files
    do
      if [ $first -eq 1 ]; then
        first=0
        command=$command"plot '$in_file' every ::2 u $key1 w xerrorbars ls $type notitle, '$in_file' every ::2 u $key2 w lp ls $type title 'PThread-LC'"
      else
        lines=`cat $in_file | wc -l`
        if [ $lines -gt 2 ]; then
          command=$command", '$in_file' every ::2 u $key1 w xerrorbars lc $type notitle, '$in_file' every ::2 u $key2 w lp ls $type title 'Fiber-LC'"
        fi
      fi
      type=`expr $type + 1`
    done

    in_file="${bench}-push_intv_vs_perf_orig.txt"
    duration=`cat $in_file | tail --lines=1`
    command=$command", $duration title 'Orig'"

    in_file="${bench}-push_intv_vs_perf_orig_fiber.txt"
    lines=`cat $in_file | wc -l`
    if [ $lines -gt 2 ]; then
      duration=`cat $in_file | tail --lines=1`
      command=$command", $duration title 'Orig-Fiber'"
    fi

#echo $command
    echo $command | gnuplot
    echo "Plot has been generated in $out_file"
  done
}

plot_pi_basic() {
  ad=100
  benches="water-nsquared water-spatial ocean-ncp ocean-cp barnes volrend fmm raytrace radiosity"
  out_file="splash2-push_intv_vs_duration-ad$ad.pdf"

  command="set terminal pdf;"
  command=$command"load \"../custom_palette\";"
  command=$command"set key outside;"
  command=$command"unset autoscale;"
  command=$command"set autoscale xmax;"
  command=$command"set autoscale ymax;"
  command=$command"set datafile separator ',';"
  command=$command"set ylabel 'duration (in ms)';"
  command=$command"set title \"splash2 performance comparison over different \npush interval (in IR instructions)\";"
  command=$command"set xlabel 'configured push interval (in IR instructions)';"
  command=$command"set output '$out_file';"

  first=1
  type=1
  for bench in $benches
  do
    in_file="${bench}-push_intv_vs_perf_lc.txt"

    if [ $first -eq 1 ]; then
      first=0
      command=$command"plot '$in_file' every ::2 u 1:6 w lp ls $type title '$bench'"
    else
      command=$command", '$in_file' every ::2 u 1:6 w lp ls $type title '$bench'"
    fi
    type=`expr $type + 1`
  done

  #echo $command
  echo $command | gnuplot
  echo "Plot has been generated in $out_file"
}

plot_ad 1
plot_ad 2
plot_ad_basic

plot_pi 1
plot_pi 2
plot_pi_basic
