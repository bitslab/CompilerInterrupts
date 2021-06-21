#!/bin/bash
# this script is used for checking the sanity of outputs of the program after the transformations
CUR_PATH=`pwd`/$(dirname "${BASH_SOURCE[0]}")/
SUB_DIR="${SUB_DIR:-"check_output"}"
DIR=$CUR_PATH/exp_results/$SUB_DIR
DIFF_FILE="$DIR/overall_diff.txt"
PTHREAD_DIFF_FILE="$DIR/pthread_diff.txt"

CYCLE="${CYCLE:-5000}"
THREADS="${THREADS:-"1"}"
CI_SETTINGS="2"
HLINE="\n\n--------------------------------------------------------------------------------\n\n"
#CI_SETTINGS="12"

source $CUR_PATH/include.sh

#1 - benchmark name (optional)
check_output() {
  echo "Experiment for checking output for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS threads, app list: $*"
  for thread in $THREADS; do
    for bench in $*; do

      set_benchmark_info $bench

      PTHREAD_FILE="$DIR/out-$bench-pthread-th$thread"
      build_orig $bench $thread
      run_exp $bench $PTHREAD_RUN $thread 0 0 $CYCLE
      mv $OUT_FILE $PTHREAD_FILE
      if [ "$bench" == "matrix_multiply" ]; then
        cp $AO_OUTPUT_DIRECTORY/outputs/matrix_file_A.txt $DIR/pthread-th$thread-matrix_file_A.txt
        cp $AO_OUTPUT_DIRECTORY/outputs/matrix_file_B.txt $DIR/pthread-th$thread-matrix_file_B.txt
      fi

      # An extra run to check if the parameters change between runs
      run_exp $bench $PTHREAD_RUN $thread 0 0 $CYCLE
      mv $OUT_FILE "${PTHREAD_FILE}-2"
      echo -e $HLINE | tee -a $PTHREAD_DIFF_FILE
      echo "Output diff for $bench for pthread runs, $thread thread(s):-" | tee -a $PTHREAD_DIFF_FILE
      echo -e $HLINE | tee -a $PTHREAD_DIFF_FILE
      diff -y --suppress-common-lines $PTHREAD_FILE "${PTHREAD_FILE}-2" | tee -a $PTHREAD_DIFF_FILE
      echo -e $HLINE | tee -a $PTHREAD_DIFF_FILE
      if [ "$bench" == "matrix_multiply" ]; then
        cp $AO_OUTPUT_DIRECTORY/outputs/matrix_file_A.txt $DIR/pthread-th$thread-matrix_file_A-2.txt
        cp $AO_OUTPUT_DIRECTORY/outputs/matrix_file_B.txt $DIR/pthread-th$thread-matrix_file_B-2.txt
       echo "Output file diff for $bench for $ci_str_lower, $thread thread(s):-" | tee -a $PTHREAD_DIFF_FILE
       echo "================ matrix_file_A.txt ===================" | tee -a $PTHREAD_DIFF_FILE
       diff -y --suppress-common-lines $DIR/pthread-th$thread-matrix_file_A.txt $DIR/pthread-th$thread-matrix_file_A-2.txt | tee -a $PTHREAD_DIFF_FILE
       echo "================ matrix_file_B.txt ===================" | tee -a $PTHREAD_DIFF_FILE
       diff -y --suppress-common-lines $DIR/pthread-th$thread-matrix_file_B.txt $DIR/pthread-th$thread-matrix_file_B-2.txt | tee -a $PTHREAD_DIFF_FILE
       echo -e $HLINE | tee -a $PTHREAD_DIFF_FILE
      fi

      for ci_setting in $CI_SETTINGS; do
        ci_str=$(get_ci_str $ci_setting)
        ci_str_lower=$(get_ci_str_in_lower_case $ci_setting)
        echo "Checking output for $bench with $thread threads & $ci_str type" | tee -a $CMD_LOG

        CI_FILE="$DIR/out-$bench-$ci_str_lower-th$thread"
        EXTRA_FLAGS="-DAVG_STATS" build_ci $bench $ci_setting $thread
        run_exp $bench $CI_RUN $thread $ci_setting 0 $CYCLE
        mv $OUT_FILE $CI_FILE

        echo -e $HLINE | tee -a $DIFF_FILE
        echo "Output diff for $bench for $ci_str_lower, $thread thread(s):-" | tee -a $DIFF_FILE
        echo -e $HLINE | tee -a $DIFF_FILE
        diff -y --suppress-common-lines $PTHREAD_FILE $CI_FILE | tee -a $DIFF_FILE
        echo -e $HLINE | tee -a $DIFF_FILE

        if [ "$bench" == "matrix_multiply" ]; then
          cp $AO_OUTPUT_DIRECTORY/outputs/matrix_file_A.txt $DIR/$ci_str_lower-th$thread-matrix_file_A.txt
          cp $AO_OUTPUT_DIRECTORY/outputs/matrix_file_B.txt $DIR/$ci_str_lower-th$thread-matrix_file_B.txt

          echo "Output file diff for $bench for $ci_str_lower, $thread thread(s):-" | tee -a $DIFF_FILE
          echo "================ matrix_file_A.txt ===================" | tee -a $DIFF_FILE
          diff -y --suppress-common-lines $DIR/pthread-th$thread-matrix_file_A.txt $DIR/$ci_str_lower-th$thread-matrix_file_A.txt | tee -a $DIFF_FILE
          echo "================ matrix_file_B.txt ===================" | tee -a $DIFF_FILE
          diff -y --suppress-common-lines $DIR/pthread-th$thread-matrix_file_B.txt $DIR/$ci_str_lower-th$thread-matrix_file_B.txt | tee -a $DIFF_FILE
          echo -e $HLINE | tee -a $DIFF_FILE
        fi
      done
    done
  done
}

rm -f $DIFF_FILE $PTHREAD_DIFF_FILE

benches="$splash2_benches $phoenix_benches $parsec_benches"

# Usage:
#   No argument : run for all benchmark suites
#   $1=0, $2=<name of benchmark>
#   $1=1, $2=<name of benchmark suite>
if [ $# -ne 0 ]; then
  if [ $1 -eq 1 ]; then
    benches=""
    for arg in $@; do
      if [ "$arg" == "splash2" ]; then
        benches="$benches$splash2_benches "
      elif [ "$arg" == "phoenix" ]; then
        benches="$benches$phoenix_benches "
      elif [ "$arg" == "parsec" ]; then
        benches="$benches$parsec_benches "
      fi
    done
  else
    benches="${@:2}"
  fi
fi

check_output $benches
print_end_notice
printf "${GREEN}Output diff is written to $DIFF_FILE\n${NC}"
