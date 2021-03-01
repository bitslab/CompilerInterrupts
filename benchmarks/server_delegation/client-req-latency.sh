#!/bin/bash

CUR_PATH=`pwd`
FFWD_PATH=${CUR_PATH}/ffwd/
EXP_DIR=${CUR_PATH}/exp_results
DATA_FILE=${EXP_DIR}/designated_delegation_latency.txt
PLOT_DIR=${CUR_PATH}/plots
LOG_FILE=${EXP_DIR}/build_log.txt
ERROR_FILE=${EXP_DIR}/build_error.txt
LOCKS_DIR=${CUR_PATH}/locks

LOCK_TYPES=('spin' 'mutex')
CLIENTS=54

run_delegation_latency(){

  CI=${2:-350}
  DATA_FILE=${EXP_DIR}/designated_delegation_latency_CI_${CI}_${CLIENTS}_threads.txt

  echo "Testing delegation [CLIENTS=$CLIENTS, CI=$CI]"

  make clean ci_preemptive_iterations PROGRAM_TO_TEST=${FFWD_PATH}/ffwd_add_iterations_flat_delegation.c FFWD_FLAGS="-DPROFILE_CLIENT_LATENCY" > $LOG_FILE 2> $ERROR_FILE
    
  printf "\n\n\"CI\"\n" > $DATA_FILE
  ./ffwd_add_iterations_lg_ck_ci_${CI}_preemptive_user_thread -s 1 -t $CLIENTS -p $CLIENTS -w 10 -i $CI | awk '{if ($1 ~ /-/) {cdf+=$2; print $1" "cdf}}' | tr '-' ' ' >> $DATA_FILE

}

run_delegation_variation_latency(){

  CI=${2:-350}
  DATA_FILE=${EXP_DIR}/designated_delegation_latency_CI_${CI}_${CLIENTS}_threads_variant.txt

  CI_FLAGS="CI_DELTA=$CI INST_LEVEL=12 CYCLE_INTV=$(($CI / 2)) CMMT_INTV=$(($CI / 3))"
  echo "Testing delegation CI_FLAGS=$CI_FLAGS [CLIENTS=$CLIENTS, CI=$CI]"

  make $CI_FLAGS clean ffwd_add_iterations_lg_ck_ci_${CI}_preemptive_user_thread_general  PROGRAM_TO_TEST=${FFWD_PATH}/ffwd_add_iterations_flat_delegation.c FFWD_FLAGS="-DPROFILE_CLIENT_LATENCY" > $LOG_FILE 2> $ERROR_FILE
    
  printf "\n\n\"CI-cycles\"\n" > $DATA_FILE
  ./ffwd_add_iterations_lg_ck_ci_${CI}_preemptive_user_thread_general -s 1 -t $CLIENTS -p $CLIENTS -w 10 -i $CI | awk '{if ($1 ~ /-/) {cdf+=$2; print $1" "cdf}}' | tr '-' ' ' >> $DATA_FILE

}

run_standard_delegation_latency(){

  DATA_FILE=${EXP_DIR}/dedicated_delegation_latency_${CLIENTS}_threads.txt
  echo "Testing standard delegation [CLIENTS=$CLIENTS]" 

  make clean ffwd_add_iterations FFWD_FLAGS="-DPROFILE_CLIENT_LATENCY" > $LOG_FILE 2> $ERROR_FILE
    
  printf "\n\n\"dedicated\"\n" > $DATA_FILE
  HW_CLIENTS=49
  ./ffwd_add_iterations -s 1 -t $CLIENTS -p $HW_CLIENTS -w 10 | awk '{if ($1 ~ /-/) {cdf+=$2; print $1" "cdf}}' | tr '-' ' ' >> $DATA_FILE

}

run_locks_latency(){

  cd $LOCKS_DIR
  DATA_FILE=${EXP_DIR}/locks_latency_${CLIENTS}_threads.txt
  
  rm -f $DATA_FILE

  make clean all_iterations FFWD_FLAGS="-DPROFILE_CLIENT_LATENCY" 
  
  for lt in ${LOCK_TYPES[@]}; do
    echo "Testing $lt"
    printf "\n\n\"%s\"\n" $lt >> $DATA_FILE
    ./${lt}_iterations -t $CLIENTS -c 10 | awk '{if ($1 ~ /-/) {cdf+=$2; print $1" "cdf}}' | tr '-' ' ' >> $DATA_FILE
    sleep 1s
  done
  
  cd - > /dev/null
}


plot_client_latency_cdf(){

  CI=${2:-350}
  cat plot_client_latency_cdf.gp | gnuplot
  mv client_latency_distribution_with_${CLIENTS}_th.pdf  $PLOT_DIR 
}

mkdir -p $EXP_DIR $PLOT_DIR

run_standard_delegation_latency
run_delegation_latency
run_delegation_variation_latency
run_locks_latency
plot_client_latency_cdf
