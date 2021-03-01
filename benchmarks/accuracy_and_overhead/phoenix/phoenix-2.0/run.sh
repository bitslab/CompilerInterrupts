#!/bin/bash

NUMBER_OF_RUNS=50
rm -f tmp sum

command="./tests/matrix_multiply/matrix_multiply-seq 25 5 1 > tmp 2>&1"
echo -n "scale=2;(" > sum
for j in `seq 1 $NUMBER_OF_RUNS`
do
#echo $command
  eval $command
  runtime=`grep "$program runtime:" tmp | cut -d: -f 2 | cut -d' ' -f 2`
  echo $runtime | tr -d '\n' >> sum
  if [ $j -lt $NUMBER_OF_RUNS ]; then
    echo -n "+" >> sum
  fi
done
echo ")/$NUMBER_OF_RUNS" >> sum
runtime=`cat sum | bc`
echo "Runtime: "$runtime
