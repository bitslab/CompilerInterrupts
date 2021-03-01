#!/bin/bash

CI=1000
PI=5000
RUNS=10
DIR=acc_intv_stats
#AD="0 50 100 200"
AD="0"

run_lc() {
  rm -f out
  THREADS=1

  case "$1" in
    water-ns)
      cd water-nsquared > /dev/null
      ./WATER-NSQUARED < input.$THREADS > ../out
      cd - > /dev/null
    ;;
    water-sp)
      cd water-spatial > /dev/null
      ./WATER-SPATIAL < input.$THREADS > ../out
      cd - > /dev/null
    ;;
    ocean-cp) 
      cd ocean/contiguous_partitions > /dev/null
      ./OCEAN -n130 -p $THREADS -e1e-07 -r20000 -t28800 > ../../out
      cd - > /dev/null
    ;;
    ocean-ncp) 
      cd ocean/non_contiguous_partitions > /dev/null
      ./OCEAN -n130 -p $THREADS -e1e-07 -r20000 -t28800 > ../../out
      cd - > /dev/null
    ;;
    barnes)
      cd barnes > /dev/null
      ./BARNES < input.$THREADS > ../out
      cd - > /dev/null
    ;;
    volrend)
      cd volrend > /dev/null
      ./VOLREND $THREADS inputs/head > ../out
      cd - > /dev/null
    ;;
    fmm)
      cd fmm > /dev/null
      ./FMM < inputs/input.16384.$THREADS > ../out
      cd - > /dev/null
    ;;
    raytrace)
      cd raytrace > /dev/null
      ./RAYTRACE -p $THREADS -m72 inputs/car.env > ../out
      cd - > /dev/null
    ;;
    radiosity)
      cd radiosity > /dev/null
      ./RADIOSITY -p $THREADS -batch -room > ../out
      cd - > /dev/null
    ;;
  esac
}

run_test() {
  BUILD_ERROR_FILE="$DIR/acc_intv_test_build_error.txt"
  BUILD_DEBUG_FILE="$DIR/acc_intv_test_build_log.txt"
  LOG="$DIR/log.txt"
  rm -f $BUILD_ERROR_FILE $BUILD_DEBUG_FILE $LOG
  for bench in $*
  do
    AVG_STAT_FILE="$DIR/${bench}_avg_acc_intv_over_ad.txt"
    UPD_STAT_FILE="$DIR/${bench}_avg_updates_over_ad.txt"
    echo -e "AD\tPredictive_Interval\tInstantaneous_Interval" | tee $AVG_STAT_FILE
    echo -e "AD\t#Predictive_Updates\t#Instantaneous_Updates" > $UPD_STAT_FILE
    for ad in $AD
    do
      echo -ne "$ad\t" | tee -a $AVG_STAT_FILE $UPD_STAT_FILE
      #run predictive
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$ad CLOCK_TYPE=0 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench
      run_lc $bench
      ./average_interval out > avg
      mv out $DIR/${bench}_pred
      average=`cat avg | grep Avg | cut -d':' -f 2`
      updates=`cat avg | grep Updates | cut -d':' -f 2`
      echo -ne "$average\t" | tee -a $AVG_STAT_FILE
      echo -ne "$updates\t" >> $UPD_STAT_FILE
      cat avg >> $LOG
      echo "$bench predictive clock with AD $ad -> avg: $average, updates: $updates" >> $LOG

      #run instantaneous 
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
      BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$ad CLOCK_TYPE=1 PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench
      run_lc $bench
      ./average_interval out > avg
      mv out $DIR/${bench}_inst
      average=`cat avg | grep Avg | cut -d':' -f 2`
      updates=`cat avg | grep Updates | cut -d':' -f 2`
      echo -e "$average" | tee -a $AVG_STAT_FILE
      echo -e "$updates" >> $UPD_STAT_FILE
      cat avg >> $LOG
      echo "$bench instantaneous clock with AD $ad -> avg: $average, updates: $updates" >> $LOG
    done
  done
}

echo "Note: Script has both accuracy tests & performance tests. Change the mode in the next few lines if any one of them is required only. "
echo "Note: Number of threads for running performance tests need to be configured inside the file" 
mkdir -p $DIR
mkdir -p stats
if [ $# -eq 0 ]; then
  run_test water-ns water-sp ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity
else
  run_test $1
fi
