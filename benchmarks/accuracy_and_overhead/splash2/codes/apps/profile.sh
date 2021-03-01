#!/bin/bash
CI=1000
PI=5000
AD=100
CLOCK=1
num_rules=3
DIR=splash2_stats
OUTFILE="$DIR/splash2_profile"


benches="water-nsquared"
benches="water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity"

mkdir -p $DIR
rm -f $OUTFILE
#echo -e "benchmark\tblocks\tunit_containers\tfinal_containers\tinstrumentations\trule1\trule2\trule3\tcontainer1\tcontainer2\tcontainer3" | tee -a $OUTFILE
echo -e "benchmark\tblocks\tunit_containers\tfinal_containers\trule1\trule2\trule3\tcontainer1\tcontainer2\tcontainer3" | tee -a $OUTFILE

for bench in $benches
do
  BUILD_DEBUG_FILE="${bench}_prof_log"
  BUILD_ERROR_FILE="${bench}_prof_err"

  rm -f $BUILD_DEBUG_FILE $BUILD_ERROR_FILE
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE make -f Makefile.lc $bench-clean
  BUILD_LOG=$BUILD_DEBUG_FILE ERROR_LOG=$BUILD_ERROR_FILE ALLOWED_DEVIATION=$AD CLOCK_TYPE=$CLOCK PUSH_INTV=$PI CMMT_INTV=$CI INST_LEVEL=1 make -f Makefile.lc $bench
  echo -n "$bench" | tee -a $OUTFILE

  count=`cat $BUILD_ERROR_FILE | grep -e "#total blocks" | cut -d ' ' -f 4`
  echo -ne "\t$count" | tee -a $OUTFILE
  count=`cat $BUILD_ERROR_FILE | grep -e "#total unit containers" | cut -d ' ' -f 5`
  echo -ne "\t$count" | tee -a $OUTFILE
  count=`cat $BUILD_ERROR_FILE | grep -e "#total final containers" | cut -d ' ' -f 5`
  echo -ne "\t$count" | tee -a $OUTFILE
#count=`cat $BUILD_ERROR_FILE | grep -e "#total instrumentations" | cut -d ' ' -f 4`
#echo -ne "\t$count" | tee -a $OUTFILE

  i=0
  while [ $i -le $num_rules ];
  do
    count=`cat $BUILD_ERROR_FILE | grep -e "total rule$i" | cut -d ' ' -f 4`
    echo -ne "\t$count" | tee -a $OUTFILE
    i=`expr $i + 1`
  done

  i=0
  while [ $i -le $num_rules ];
  do
    count=`cat $BUILD_ERROR_FILE | grep -e "total container$i" | cut -d ' ' -f 4`
    echo -ne "\t$count" | tee -a $OUTFILE
    i=`expr $i + 1`
  done

  echo "" | tee -a $OUTFILE
done
