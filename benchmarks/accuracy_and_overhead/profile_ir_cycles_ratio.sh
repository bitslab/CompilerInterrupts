#!/bin/bash
# this script is used for profiling for the right tuning parameters to achieve the target interval in cycles
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-"profile"}"
DIR=$CUR_PATH/microbenchmark_stats/$SUB_DIR
WRITE_DIR=/local_home/nilanjana/temp/$SUB_DIR
STAT_FILE="$DIR/profiler_interval_accuracy_statistics.txt"

CYCLE="${CYCLE:-5000}"
THREADS="${THREADS:-"1 32"}"
CI_SETTINGS="2 12 4 6 10"
#EXTRA_FLAGS="-DPROFILE"
EXTRA_FLAGS="-DINTV_SAMPLING"

CLOCK_FREQ_IN_MHZ=2200
OUTLIER_THRESHOLD=20
PI_SET="${PI_SET:-"500 1000 2000 2500 5000 10000 15000 20000 25000 30000 35000 40000 50000 80000"}"

#PI_SET="25 50 75 100 125 250 500 750 1000 2000" # for CI10 (legacy-tl)
#PI_SET="500 1000 2000 2500 5000 7500 10000 15000 20000 25000 30000 35000 40000 50000 80000" # for 32 threads (legacy-tl)

ERROR_ALLOWED_PERCENTAGE="20"
ERROR_DIFF_ALLOWED_PERCENTAGE="10"

#THREADS="1"
#CI_SETTINGS="2 12"

# include.sh should be included after the path declarations
source include.sh

old_profile_test() {
#THREADS="32"
#CI_SETTINGS="10"
#PI_SET=""
  suffix_conf=1
  printf "${GREEN}Profiling for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS threads, app list: $benches, PI: $PI_SET\n${NC}"
  for thread in $THREADS; do
    for ci_setting in $CI_SETTINGS; do
      for bench in $*; do
        set_benchmark_info $bench
        for pi in $PI_SET; do
          ci=`echo "scale=0; $pi/5" | bc`
          build_ci $bench $ci_setting $thread $pi $ci

          OUT_STAT_FILE="${DIR}/${bench}-th${thread}-ci${ci_setting}-pi${pi}"
          dry_run_exp $bench $suffix_conf
          run_exp $bench $suffix_conf $thread
          grep "Thread" $OUT_FILE > $OUT_STAT_FILE
        done
      done
    done
  done
}

# format of output file: PI, Median, 5pc, 95pc, 1pc, 99pc
summarize_run() {
  pi=$1
  ifile=$2
  ofile=$OUT_STAT_FILE

  printf "$pi\t" >> $ofile
  awk '/^0.5/ {printf("%d\t", $2); exit}' $ifile >> $ofile
  awk '/^0.05/ {printf("%d\t", $2); exit}' $ifile >> $ofile
  awk '/^0.95/ {printf("%d\t", $2); exit}' $ifile >> $ofile
  awk '/^0.01/ {printf("%d\t", $2); exit}' $ifile >> $ofile
  awk '/^0.99/ {printf("%d\n", $2); exit}' $ifile >> $ofile

  # return the median
  awk '/^0.5/ {printf("%d", $2); exit}' $ifile
}

#1 - benchmark name, 2 - #thread, 3 - output file name
emit_interval() {
  bench=$1
  thread=$2
  sampled_merged_cdfname=$3
  suffix_conf=1 # always run in CI mode

  #PREFIX=""
  PREFIX="LD_PRELOAD=$LIBCALL_WRAPPER_PATH"

  # The benchmarks export interval stats in this directory
  # TODO: Make the path configurable using environment variable
  OUT_DIR="/local_home/nilanjana/temp/interval_stats/"

  # Remove dry run accuracy files
  rm -f $OUT_DIR/*

  run_exp $bench $suffix_conf $thread

  new_file_prefix="${sampled_merged_cdfname%.*}"
  rm -f ${new_file_prefix}*.*

  pushd $OUT_DIR
  total_uncollected_samples=0
  total_ci_calls=0
  thread_filenames=""
  for file in interval_stats_thread*.txt
  do
    thr_no=`echo $file | grep -o '[0-9]\+'`
    new_name=${new_file_prefix}"_thread"$thr_no".txt"
    cdf_name=${new_file_prefix}"_thread"$thr_no".cdf"
    mv $file $new_name

    uncollected_samples=`awk '/Uncollected/ {print $3}' $new_name`
    ci_calls=`awk '/Total CI calls/ {print $4}' $new_name`
    total_uncollected_samples=`expr $total_uncollected_samples + $uncollected_samples`
    total_ci_calls=`expr $total_ci_calls + $ci_calls`
    printf "${GREEN}Generated accuracy data points in $new_name ( uncollected samples: $uncollected_samples, ci calls: $ci_calls )\n${NC}" | tee -a $CMD_LOG $STAT_FILE

    #create_cdf $new_name $cdf_name
    thread_filenames="$thread_filenames $new_name"
    thread_cdfnames="$thread_cdfnames $cdf_name"
  done

  # Merge files, create CDF & get statistics
  merged_filename="${new_file_prefix}.txt"
  merged_cdfname="${new_file_prefix}.cdf"
  cat $thread_filenames | awk '!/[a-zA-Z+]/ {print}' > $merged_filename
  total_samples=`wc -l $merged_filename`
  printf "${BLUE}Merged all thread's accuracy data points ( total uncollected samples: $total_uncollected_samples, total ci calls: $total_ci_calls, total samples in file: $total_samples )\n${NC}" | tee -a $CMD_LOG $STAT_FILE

  create_cdf $merged_filename $merged_cdfname $sampled_merged_cdfname

  # Remove the big files
  rm -f $thread_filenames $thread_cdfnames $merged_filename $merged_cdfname

  popd > /dev/null
}

profile_test() {
#THREADS="1"
#CI_SETTINGS="12"
  printf "${GREEN}Profiling for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS threads, app list: $benches, PI: $PI_SET\n${NC}"
  #IFS=' ' read -r -a pi_arr <<< "$PI_SET"
  allowed_cycle_err=`echo "($CYCLE*$ERROR_ALLOWED_PERCENTAGE)/100" | bc`
  for thread in $THREADS; do
    for ci_setting in $CI_SETTINGS; do
      for bench in $*; do
        ci_str=$(get_ci_str_in_lower_case $ci_setting)
        echo "Profiling for $bench with $thread threads & $ci_str type" | tee -a $CMD_LOG
        set_benchmark_info $bench
        OUT_STAT_FILE="${DIR}/${bench}-th${thread}-ci${ci_setting}"
        rm -f $OUT_STAT_FILE

        # Do dry run once
        build_ci $bench $ci_setting $thread 100000 20000
        PREFIX="LD_PRELOAD=$LIBCALL_WRAPPER_PATH" dry_run_exp $bench 1

        unset min_error
        for pi in $PI_SET; do
          ci=`echo "scale=0; $pi/5" | bc`
          build_ci $bench $ci_setting $thread $pi $ci

          ofile="$WRITE_DIR/${bench}-th${thread}-${ci_str}-pi${pi}.s100"
          emit_interval $bench $thread $ofile
          median=$(summarize_run $pi $ofile)
          error=`echo $median | \
            awk -v cyc=$CYCLE '{ if (cyc>$1) printf "%d", cyc-$1; else printf "%d", $1-cyc }'`
          if [ -s $min_error ] || [ $min_error -ge $error ]; then
            min_error=$error
            min_pi=$pi
            echo "Setting min error to $error for PI $pi"
          else
            echo "Current error $error, Current PI $pi, Allowed error $allowed_cycle_err"
            # To take care of oscillations in error
            err_diff=`echo "$error $min_error" | awk '{ error_diff_pc=(($1-$2)*100)/$2; printf "%d",error_diff_pc }'`
            if [ $error -gt $allowed_cycle_err ] && [ $err_diff -gt $ERROR_DIFF_ALLOWED_PERCENTAGE ] ; then
              printf "${GREEN}Error $error for PI $pi exceeded allowed error $allowed_cycle_err, difference with min error: $err_diff. So we stopped checking further PIs.\nMin PI: $min_pi, Min error: $min_error.\n${NC}" | tee -a $CMD_LOG
              break
            fi
          fi
        done
        printf "${BLUE}Stats are exported to $OUT_STAT_FILE\n${NC}"
      done
    done
  done
}

summarize() {
#THREADS="1"
#CI_SETTINGS="12"
  for thread in $THREADS; do
    for ci_setting in $CI_SETTINGS; do
      ci_str=$(get_ci_str $ci_setting)
      ofile="$ci_str-tuning-th$thread-$CYCLE.txt"
      for bench in $*; do
        ifile="${DIR}/${bench}-th${thread}-ci${ci_setting}"
        opt_pi=`awk -v app=$bench -v target=$CYCLE 'BEGIN {min_median=1000000000000; pi=0;} 
        {
          if ($2>target) {median=($2-target)} else {median=(target-$2)}
          if(min_median > median) {
            min_median = median
            pi=$1
          }
        }
        END {printf "%d", pi}' $ifile`
        printf "${GREEN}Best PI configuration for $bench for $CYCLE cycles: $opt_pi IR\n${NC}" | tee -a $CMD_LOG

        # replace the result in the output file
        unset present
        if [ -f $ofile ]; then
          present=`grep $bench $ofile`
        fi
        if [ -z "$present" ]; then
          echo -e "$bench\t$opt_pi" >> $ofile
        else
          awk -v pat=$bench -v pi=$opt_pi\
            '$0~pat {printf("%s\t%d\n", pat, pi)} $0 !~ pat {print}' $ofile > tmp
          mv tmp $ofile
        fi
      done
    done
  done
}

get_thread_ids() {
  file=$1
  id=`awk '/^Thread [1-9]+/ {print $2}' $file | cut -d':' -f1 | sort -n -k1 | uniq | tr '\n' ' '`
  echo $id
}

old_summarize() {
#THREADS="1"
#CI_SETTINGS="2"
#PI_SET="500"
  echo "Analyzing profiling stats for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS threads, app list: $benches, PI: $PI_SET"
  for thread in $THREADS; do
    for ci_setting in $CI_SETTINGS; do
      ci_str=$(get_ci_str $ci_setting)
      for bench in $*; do
        o_temp_file="${DIR}/${bench}-th${thread}-ci${ci_setting}"
        echo -e "PI\tCICycles\tCycleError" > $o_temp_file
        for pi in $PI_SET; do
          echo "Bench: $bench, thread: $thread, ci setting: $ci_setting, pi: $pi" | tee -a $CMD_LOG $OUTLIER_LOG
          ifile="${DIR}/${bench}-th${thread}-ci${ci_setting}-pi${pi}"
          o_pi_all_thrd_temp_file="${DIR}/${bench}-th${thread}-ci${ci_setting}-pi${pi}-all-tmp"
          o_pi_temp_file="${DIR}/${bench}-th${thread}-ci${ci_setting}-pi${pi}-threadwise-tmp"
          rm -f $o_pi_all_thrd_temp_file $o_pi_temp_file

          # print thread id (repeatable) and cycles in between CIs
          # only considering cases where at least 10000 CIs got fired i.e. the thread ran for a while to be considered valid
          awk -v cf_mhz=$CLOCK_FREQ_IN_MHZ '/^Thread/ {if($3>10000) printf("%s %d\n", $2,($6*cf_mhz*1000000)/$3)}' $ifile > $o_pi_all_thrd_temp_file

          medians=""
          thread_ids=$(get_thread_ids $ifile)
          #echo $thread_ids | tr ' ' '\n'

          # Summarizing over individual threads
          for th_id in $thread_ids; do
            elems=`grep -e $th_id $o_pi_all_thrd_temp_file | awk '{print $2}' | tr '\n' ' '`
            if [ -z "$elems" ]; then
              echo "No CI called for thread $th_id" >> $OUTLIER_LOG
              continue
            fi
            median=$(get_median $elems)
            medians=$medians" "$median

            # print thread id and cycles in between CIs
            echo -e "${pi} $median $th_id" >> $o_pi_temp_file
            
            # Checking for outliers
            #avg=$(get_avg $elems)
            header="Thread $th_id (median: $median):" OUTLIER_THRESHOLD=20 get_outliers $median $elems
          done

          # Summarizing over all threads
          median_of_medians=$(get_median $medians)
          #get_median_debug $medians
          #avg=$(get_avg $medians)
          header="All Threads (median: $median_of_medians):" OUTLIER_THRESHOLD=20 get_outliers $median_of_medians $medians
          header="$bench-th$thread-pi$pi:" OUTLIER_THRESHOLD=200 is_main_thread_outlier $median_of_medians $medians
          header="$bench-th$thread-pi$pi:" OUTLIER_THRESHOLD=200 is_last_thread_outlier $median_of_medians $medians
          echo -e "$pi\t$median_of_medians" |\
            awk -v cyc=$CYCLE '
              { if($2>cyc) {dist=$2-cyc} else {dist=cyc-$2}; 
                printf("%d\t%d\t%d\n", $1, $2, dist) }' |\
            tee -a $o_temp_file
            #rm -f $o_pi_all_thrd_temp_file $o_pi_temp_file 
        done
      done

      # Summarize over all benchmarks
      ofile="$ci_str-tuning-th$thread-$CYCLE.txt"
      # modify ofile only for the bench
      for bench in $*; do
        o_temp_file="${DIR}/${bench}-th${thread}-ci${ci_setting}"
        opt_pi=`sort -n -k 2 $o_temp_file\
          | awk -v cyc=$CYCLE '
          BEGIN {min_dist=1000000} 
          NR>1 { if ($3 < min_dist) {min_dist=$3; min_pi=$1} }
          END {print min_pi}'` 
        if [ -f $ofile ]; then
          present=`grep $bench $ofile`
        fi
        if [ -z "$present" ]; then
          echo -e "$bench\t$opt_pi" >> $ofile
        else
          awk -v pat=$bench -v pi=$opt_pi\
            '$0~pat {printf("%s\t%d\n", pat, pi)} $0 !~ pat {print}' $ofile > tmp
          mv tmp $ofile
        fi
      done
    done
  done
}

mkdir -p $WRITE_DIR
rm -f $STAT_FILE

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

build_libcall_wrapper
profile_test $benches
summarize $benches
print_end_notice

