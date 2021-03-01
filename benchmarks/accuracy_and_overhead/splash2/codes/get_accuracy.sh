#!/bin/bash

get_accuracy() {
  echo "Running (for interval stats) $1 with 1 thread" | tee -a $DEBUG_FILE
  cdf_name="$1-$2.cdf"
  sample_name="$1-$2.s100"
  pc_name="$1-$2.pc"

  cd /local_home/nilanjana/temp/interval_stats > /dev/null
  # create sampled cdf
  cat interval_stats_thread*.txt | grep -ve "PushSeq\|Total" |\
  awk '{print $4}' |\
  sort -n |\
  awk 'BEGIN {OFMT="%f"} {lines[i++]=$0} END {for(l in lines){print l/(i-1)," ",lines[l]}}' |\
  sort -n -k 2 \
  > $cdf_name 
  gawk -v lines="$(cat $cdf_name | wc -l)" 'lines<1000 || NR % int(lines/100) == 1 {print} {line=$0} END {print line}' $cdf_name > $sample_name
  echo "Sampled cdf to $sample_name"

  gawk 'BEGIN {split("1 5 10 25 50 75 90 95 99",ptiles," "); p=1} 
  !val[p] && $1+0>=(ptiles[p]+0)/100.0 {val[p]=$2; p++} 
  END { for(i=1;i<=length(ptiles);i++) { if(ptiles[i]) {print ptiles[i], ": ", val[i]}}}' file="$sample_name" $sample_name > ./$pc_name

  echo -e "\n============= $bench ================" | tee -a $ACC_LOG_FILE
  cat ./$pc_name | tee -a $ACC_LOG_FILE
  echo -e "\n" | tee -a $ACC_LOG_FILE
  
  cd - > /dev/null
}

echo "Program expects interval stat files to be already present in /local_home/nilanjana/temp/interval_stats/"
if [ $# -ne 2 ]; then
  echo "Usage: ./get_accuracy.sh <bench name> <ci config name>"
  exit
fi

get_accuracy $1 $2
