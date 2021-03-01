#!/bin/bash

convert() {
  config=$1
  bench="water-nsquared water-spatial ocean-cp ocean-ncp radiosity raytrace fmm volrend barnes"

  #key_pos: 2 for IR inst count, 3 for time stamp, 4 for retired inst count
  if [ $config -eq 1 ]; then
    key_pos=2
    suffix="_ic"
  elif [ $config -eq 2 ]; then
    key_pos=3
    suffix="_ret_ic"
  elif [ $config -eq 3 ]; then
    key_pos=4
    suffix="_tsc"
  fi

  for b in $bench
  do
    infile="${b}_lc_ic_vs_tsc.txt"
    outfile="cdf-${b}${suffix}.txt"
    total_records=`cat $infile | awk 'END {print NR-1}'`
    echo "#records for $b: $total_records"
    cat $infile | tail --lines=+2 | sort -n -k $key_pos | awk -v records=$total_records -v key=$key_pos '{print NR/records, $key}' > $outfile
  #cat $infile | tail --lines=+2 | tr -d ',' | sort -n -k 3 | awk -v records=$total_records '{print NR, $3}' > $outfile
  done
}

convert 1
convert 2
convert 3
