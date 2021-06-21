#!/bin/bash

# Make sure to check the number of request lines in ${FFWD_PATH}/macros.m4

CUR_PATH=`pwd`
FFWD_PATH=${CUR_PATH}/ffwd/
PLOT_DIR=${CUR_PATH}/plots
EXP_DIR=${CUR_PATH}/exp_results
LOG_FILE=${EXP_DIR}/build_log.txt
ERROR_FILE=${EXP_DIR}/build_error.txt
LOCKS_DIR=${CUR_PATH}/locks
TEMP_FILE=${EXP_DIR}/mops.tmp
OUT_FILE=${CUR_PATH}/results.txt

LOCK_TYPES=('tas' 'spin' 'ttas' 'mcs' 'mutex' 'ticket')
ITERATIONS=5

# Run this command on the master branch 
run_original_delegation_mops(){
  
  make ffwd_add

  rm -f mops.txt
  for i in 2 4 8 16 32 54; do 
    for r in $(seq 1 5); do 
      ./ffwd_add -s 1 -t $(($i*5)) -d 1 >> $TEMP_FILE; 
    done 
    cat $TEMP_FILE | awk '{acc1+=$1; acc2+=$2; acc3+=$3; acc4+=$4;} END {print acc1/NR" "acc2/NR" "acc3/NR" "acc4/NR}' >> mops.txt; rm $TEMP_FILE; 
  done
}

run_delegation_mops(){
  FIBERS_PC=${1:-5}
  CI=${2:-350}
  DATA_FILE=${EXP_DIR}/designated_delegation_mops_CI_${CI}_FPC_${FIBERS_PC}.txt

  echo "Testing delegation [ITERATIONS=$ITERATIONS, CI=$CI, FIBERS_PC=$FIBERS_PC]"

  make clean ci_preemptive_iterations PROGRAM_TO_TEST=${FFWD_PATH}/ffwd_add_iterations_flat_delegation.c FFWD_FLAGS="-DFLAT_DELEGATION" > $LOG_FILE 2> $ERROR_FILE
    
  printf "\n\n\"CI\"\n" $CI > $DATA_FILE
  for cl in 2 4 8 16 32 54; do
    for i in $(seq 1 $ITERATIONS); do
      ./ffwd_add_iterations_lg_ck_ci_${CI}_preemptive_user_thread -s 1 -t $(($cl*$FIBERS_PC)) -p $cl -w 10 -i $CI > /dev/null
      cat $OUT_FILE | awk '/clients_nr|hw_threads|server_nr/ {printf "%d ",$2} /ml_ops_per_sec/ {print $2}' >> $TEMP_FILE 
      rm -f $OUT_FILE
      sleep 1s
    done
    cat $TEMP_FILE | awk '{acc1+=$1; acc2+=$2; acc3+=$3; acc4+=$4;} END {print acc1/NR" "acc2/NR" "acc3/NR" "acc4/NR}' >> $DATA_FILE
    rm -f $TEMP_FILE
  done

  echo "Testing exclusive delegation [ITERATIONS=$ITERATIONS, CI=$CI, FIBERS_PC=$FIBERS_PC]"

  make clean ci_preemptive_iterations PROGRAM_TO_TEST=${FFWD_PATH}/ffwd_add_iterations_flat_delegation.c FFWD_FLAGS="-DFLAT_DELEGATION -DEXCLUSIVE" > $LOG_FILE 2> $ERROR_FILE
    
  printf "\n\n\"CI (exclusive)\"\n" >> $DATA_FILE
  for cl in 2 4 8 16 32 54; do
    for i in $(seq 1 $ITERATIONS); do
      ./ffwd_add_iterations_lg_ck_ci_${CI}_preemptive_user_thread -s 1 -t $(($cl*$FIBERS_PC)) -p $cl -w 10 -i $CI > /dev/null
      cat $OUT_FILE | awk '/clients_nr|hw_threads|server_nr/ {printf "%d ",$2} /ml_ops_per_sec/ {print $2}' >> $TEMP_FILE
      rm -f $OUT_FILE
      sleep 1s
    done
    cat $TEMP_FILE | awk '{acc1+=$1; acc2+=$2; acc3+=$3; acc4+=$4;} END {print acc1/NR" "acc2/NR" "acc3/NR" "acc4/NR}' >> $DATA_FILE
    rm -f $TEMP_FILE
  done
}

run_delegation_CI_variant(){

  FIBERS_PC=${1:-5}
  CI=${2:-350}
  DATA_FILE=${EXP_DIR}/designated_delegation_mops_CI_${CI}_FPC_${FIBERS_PC}_variant.txt

  CI_FLAGS="CI_DELTA=$CI INST_LEVEL=12 CYCLE_INTV=$(($CI / 2)) CMMT_INTV=$(($CI / 3))"
  echo "Testing delegation CI_FLAGS=$CI_FLAGS [ ITERATIONS=$ITERATIONS, CI=$CI, FIBERS_PC=$FIBERS_PC ]"

  make $CI_FLAGS clean ffwd_add_iterations_lg_ck_ci_${CI}_preemptive_user_thread_general PROGRAM_TO_TEST=${FFWD_PATH}/ffwd_add_iterations_flat_delegation.c FFWD_FLAGS="-DFLAT_DELEGATION" > $LOG_FILE 2> $ERROR_FILE
    
  printf "\n\n\"CI-cycles\"\n" > $DATA_FILE
  for cl in 2 4 8 16 32 54; do
    for i in $(seq 1 $ITERATIONS); do
      ./ffwd_add_iterations_lg_ck_ci_${CI}_preemptive_user_thread_general -s 1 -t $(($cl*$FIBERS_PC)) -p $cl -w 10 -i $CI -r $(($CI / 2)) -c $(($CI / 2)) > /dev/null
      cat $OUT_FILE | awk '/clients_nr|hw_threads|server_nr/ {printf "%d ",$2} /ml_ops_per_sec/ {print $2}' >> $TEMP_FILE 
      rm -f $OUT_FILE
      sleep 1s
    done
    cat $TEMP_FILE | awk '{acc1+=$1; acc2+=$2; acc3+=$3; acc4+=$4;} END {print acc1/NR" "acc2/NR" "acc3/NR" "acc4/NR}' >> $DATA_FILE
    rm -f $TEMP_FILE
  done

}

run_standard_delegation_mops(){
  FIBERS_PC=${1:-5}
  DATA_FILE=${EXP_DIR}/dedicated_delegation_mops_FPC_${FIBERS_PC}.txt
  echo "Testing standard delegation [ITERATIONS=$ITERATIONS, FIBERS_PC=$FIBERS_PC]"

  make clean ffwd_add_iterations > $LOG_FILE 2> $ERROR_FILE
    
  printf "\n\n\"dedicated\"\n" > $DATA_FILE
  for cl in 2 4 8 16 32 54; do
    for i in $(seq 1 $ITERATIONS); do
      ./ffwd_add_iterations -s 1 -t $(($cl*$FIBERS_PC)) -p $cl -w 10 | awk '/clients_nr|hw_threads|server_nr/ {printf "%d ",$2} /ml_ops_per_sec/ {print $2}' >> $TEMP_FILE
      sleep 1s
    done
    cat $TEMP_FILE | awk '{acc1+=$1; acc2+=$2; acc3+=$3; acc4+=$4;} END {print acc1/NR" "acc2/NR" "acc3/NR" "acc4/NR}' >> $DATA_FILE
    rm -f $TEMP_FILE
  done
}

run_locks(){
  cd $LOCKS_DIR
  DATA_FILE=${EXP_DIR}/locks_mops_vs_threads.txt
  
  rm -f $DATA_FILE

  make clean all_iterations   
  
  for lt in ${LOCK_TYPES[@]}; do
    echo "Testing $lt"
    printf "\n\n\"%s\"\n" $lt >> $DATA_FILE
    for cl in 2 4 8 16 32 54; do
      for i in $(seq 1 $ITERATIONS); do
        ./${lt}_iterations -t $cl -c 10 | awk '/clients_nr/ {printf "%d ",$2} /ml_ops_per_sec/ {print $2}' >> $TEMP_FILE
        sleep 1s
      done
      cat $TEMP_FILE | awk '{acc1+=$1; acc2+=$2;} END {print acc1/NR" "acc2/NR}' >> $DATA_FILE
      rm -f $TEMP_FILE
    done
  done
  
  cd - > /dev/null
}

plot_mops(){
  
  FIBERS_PC=${1:-5}
  CI=${2:-350}
  cat plot_mops_delegation_vs_thread_nr.gp | gnuplot
  mv mops_server_vs_thread_nr_with_${FIBERS_PC}_cl_per_th.pdf $PLOT_DIR

}

mkdir -p $EXP_DIR $PLOT_DIR

run_locks
run_delegation_CI_variant
run_delegation_mops
run_standard_delegation_mops
plot_mops

