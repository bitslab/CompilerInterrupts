#!/bin/bash
# this script is used for profiling for the right tuning parameters to achieve the target interval in cycles
CUR_PATH=`pwd`/$(dirname "${BASH_SOURCE[0]}")/
SUB_DIR="${SUB_DIR:-"profile"}"
DIR=$CUR_PATH/exp_results/$SUB_DIR
STAT_FILE="$DIR/profiler_interval_accuracy_statistics.txt"
PLOTS_DIR="$CUR_PATH/../plots"

CYCLE="${CYCLE:-5000}"
THREADS="${THREADS:-"1 32"}"
CI_SETTINGS="2 12 4 6 10"

#EXTRA_FLAGS="-DPROFILE"

CLOCK_FREQ_IN_MHZ=2200
OUTLIER_THRESHOLD=20

GENERIC_PI_SET="500 1000 2000 2500 5000 10000 15000 20000 25000 30000 35000 40000 50000 80000 100000 150000"
LEGACY_PI_SET="25 50 75 100 125 250 500 750 1000 2000" # for CI10 (legacy-tl)
#LEGACY_PI_SET="1000 2000 3000 4000 5000 6000 7000 8000 9000 10000" # for CI10 (legacy-tl-hybrid)

#GENERIC_PI_SET="500 1000 2000 2500 5000 7500 10000 15000 20000 25000 30000 35000 40000 50000 80000" # for 32 threads (legacy-tl)

ERROR_ALLOWED_PERCENTAGE="20"
ERROR_DIFF_ALLOWED_PERCENTAGE="10"

#THREADS="1"
#CI_SETTINGS="2 12"

# include.sh should be included after the path declarations
source include.sh
WRITE_DIR=$AO_OUTPUT_DIRECTORY/$SUB_DIR

# format of output file: PI, Median, 5pc, 95pc, 1pc, 99pc
summarize_run() {
  pi=$1
  ifile=$2
  ofile=$3

  printf "$pi\t" >> $ofile
  awk '/^0.5/ {printf("%d\t", $2); exit}' $ifile >> $ofile
  awk '/^0.01/ {printf("%d\t", $2); exit}' $ifile >> $ofile
  awk '/^0.05/ {printf("%d\t", $2); exit}' $ifile >> $ofile
  awk '/^0.1/ {printf("%d\t", $2); exit}' $ifile >> $ofile
  awk '/^0.9/ {printf("%d\t", $2); exit}' $ifile >> $ofile
  awk '/^0.95/ {printf("%d\t", $2); exit}' $ifile >> $ofile
  awk '/^0.99/ {printf("%d\n", $2); exit}' $ifile >> $ofile

  # return the median
  awk '/^0.5/ {printf("%d", $2); exit}' $ifile
}

#1 - benchmark name, 2 - ci setting, 3 - #thread, 4 - target interval in IR, 5 - output file name
emit_interval() {
  bench=$1
  ci_setting=$2
  thread=$3
  pi=$4
  sampled_merged_cdfname=$5
  suffix_conf=1 # always run in CI mode

  #PREFIX=""
  PREFIX="LD_PRELOAD=$LIBCALL_WRAPPER_PATH"

  # The benchmarks export interval stats in this directory
  # TODO: Make the path configurable using environment variable
  OUT_DIR="$AO_OUTPUT_DIRECTORY/interval_stats"

  # Remove dry run accuracy files
  rm -f $OUT_DIR/*

  run_exp $bench $suffix_conf $thread $ci_setting $pi $CYCLE

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

    if [ ! -z $uncollected_samples ]; then
      total_uncollected_samples=`expr $total_uncollected_samples + $uncollected_samples`
    fi
    if [ ! -z $ci_calls ]; then
      total_ci_calls=`expr $total_ci_calls + $ci_calls`
    fi
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
  printf "${GREEN}Profiling for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS threads, app list: $benches\n${NC}"
  #IFS=' ' read -r -a pi_arr <<< "$PI_SET"
  allowed_cycle_err=`echo "($CYCLE*$ERROR_ALLOWED_PERCENTAGE)/100" | bc`
  for thread in $THREADS; do
    for ci_setting in $CI_SETTINGS; do
      if [ $ci_setting -eq $LEGACY_TL ]; then
        PI_SET=$LEGACY_PI_SET
      else
        PI_SET=$GENERIC_PI_SET
      fi
      ci_str=$(get_ci_str_in_lower_case $ci_setting)
      printf "${GREEN}Profiling for $ci_str with $THREADS threads & PI Set $PI_SET\n${NC}"
      for bench in $*; do
        echo "Profiling for $bench with $thread threads & $ci_str type" | tee -a $CMD_LOG
        set_benchmark_info $bench
        OUT_STAT_FILE="${DIR}/${bench}-th${thread}-ci${ci_setting}"
        rm -f $OUT_STAT_FILE

        # Do dry run once
        EXTRA_FLAGS="-DINTV_SAMPLING" build_ci $bench $ci_setting $thread 100000 # PI value is unused in the pass currently. So setting it to a random high value.
        PREFIX="LD_PRELOAD=$LIBCALL_WRAPPER_PATH" dry_run_exp $bench 1

        unset min_error
        for pi in $PI_SET; do
          ofile="$WRITE_DIR/${bench}-th${thread}-${ci_str}-pi${pi}.s100"
          emit_interval $bench $ci_setting $thread $pi $ofile
          median=$(summarize_run $pi $ofile $OUT_STAT_FILE)
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
      #rm -f $ofile
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

plot_profile_data() {
  # plot profiled median interval vs configured IR interval
  for thread in $THREADS; do
    for ci_setting in $CI_SETTINGS; do
      suffix="th$thread-ci$ci_setting"
      data_path="$DIR/*-$suffix"
      plot_file="$PLOTS_DIR/profiled-ir-vs-cycle-${suffix}.pdf"
      gnuplot -e "ofile='$plot_file'" -e "data='$data_path'" plot_ir_cycles.gp
      printf "${GREEN}Accuracy data plotted in $plot_file\n${NC}"
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

check_if_ci_needs_rerun() {
  ci_present=0
  ci_cycles_present=0
  for ci_settings in $CI_SETTINGS; do
    if [ $ci_settings -eq $OPT_TL ]; then
      ci_present=1
    fi
    if [ $ci_settings -eq $OPT_INTERMEDIATE ]; then
      ci_cycles_present=1
    fi
  done
  if [ $ci_cycles_present -eq 1 ] && [ $ci_present -ne 1 ]; then
    RERUN_CI_FOR_CI_CYCLES=1
  else
    RERUN_CI_FOR_CI_CYCLES=0
  fi
}

run_test() {
  #THREADS="1"
  printf "${GREEN}Run profiler for base case for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS threads, app list: $benches\n${NC}"
  allowed_cycle_err=`echo "($CYCLE*$ERROR_ALLOWED_PERCENTAGE)/100" | bc`
  check_if_ci_needs_rerun # sets RERUN_CI_FOR_CI_CYCLES
  for thread in $THREADS; do
    for ci_setting in $CI_SETTINGS; do
      if [ $ci_setting -eq $OPT_INTERMEDIATE ]; then
        if [ $RERUN_CI_FOR_CI_CYCLES -eq 1 ]; then
          echo "Re-running CI for CI-cycles"
          ci_setting=2
        else
          continue
        fi
      fi
      ci_str=$(get_ci_str_in_lower_case $ci_setting)
      printf "${GREEN}Profiling $ci_str for $thread thread(s)${NC}\n"
      if [ $thread -eq 1 ]; then
        case $ci_setting in
          2) config_to_cycle_ratio=4;;
          4) config_to_cycle_ratio=4;;
          6) config_to_cycle_ratio=4;;
          10) config_to_cycle_ratio="0.1";;
          12) printf "${RED}CI-cycles shouldn't be profiled on its own! Aborting.${NC}\n"; exit;; # 1 acc. to old profiler
        esac
      else
        case $ci_setting in
          2) config_to_cycle_ratio=2;;
          4) config_to_cycle_ratio=2;;
          6) config_to_cycle_ratio=2;;
          10) config_to_cycle_ratio="0.1";;
          12) printf "${RED}CI-cycles shouldn't be profiled on its own! Aborting.${NC}\n"; exit;; # 1 acc. to old profiler
        esac
      fi
      #local IR_TARGET=`echo "scale=2;($CYCLE * $config_to_cycle_ratio)" | bc`
      local IR_TARGET=`echo "$CYCLE $config_to_cycle_ratio" | awk '{print $1*$2}'`

      OUT_STAT_FILE="${DIR}/profiled-th${thread}-ci${ci_setting}"
      rm -f $OUT_STAT_FILE
      printf "${GREEN}Profiling for $ci_str with $THREADS threads & PI $IR_TARGET\n${NC}"
      for bench in $*; do
        echo "Profiling for $bench with $thread threads & $ci_str type" | tee -a $CMD_LOG
        set_benchmark_info $bench

        EXTRA_FLAGS="-DINTV_SAMPLING" build_ci $bench $ci_setting $thread 100000 # PI value is unused in the pass currently. So setting it to a random high value.

        # Do dry run once
        PREFIX="LD_PRELOAD=$LIBCALL_WRAPPER_PATH" dry_run_exp $bench 1

        ofile="$WRITE_DIR/${bench}-th${thread}-${ci_str}-pi${IR_TARGET}.s100"
        emit_interval $bench $ci_setting $thread $IR_TARGET $ofile
        echo -ne "$bench\t" >> $OUT_STAT_FILE
        median=$(summarize_run $IR_TARGET $ofile $OUT_STAT_FILE)
        error=`echo $median | \
          awk -v cyc=$CYCLE '{ if (cyc>$1) printf "%d", cyc-$1; else printf "%d", $1-cyc }'`
        printf "${BLUE}Stats are exported to $OUT_STAT_FILE\n${NC}"
      done
    done
  done
}

predict_ratio() {
  echo "Analyzing profiling stats for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS threads, app list: $benches"
  for thread in $THREADS; do
    for ci_setting in $CI_SETTINGS; do
      ci_str=$(get_ci_str $ci_setting)
      ofile="predicted-${ci_str}-th${thread}-${CYCLE}.txt"
      rm -f $ofile
      for bench in $*; do
        if [ $ci_setting -eq $OPT_INTERMEDIATE ]; then
          o_temp_file="${DIR}/profiled-th${thread}-ci2"
          predicted_pi=`grep -e "^$bench" $o_temp_file | awk -v cyc=$CYCLE '{target_cyc=0.9*cyc; pi=int($2*target_cyc/$3); print pi}'`
        else
          o_temp_file="${DIR}/profiled-th${thread}-ci${ci_setting}"
          predicted_pi=`grep -e "^$bench" $o_temp_file | awk -v cyc=$CYCLE '{pi=int($2*cyc/$3); print pi}'`
        fi
        echo -e "$bench\t$predicted_pi" | tee -a $ofile
      done
      printf "${GREEN}Exported predicted parameters to $ofile${NC}\n"
      cp $ofile $DIR
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
run_test $benches
predict_ratio $benches
exit

profile_test $benches
summarize $benches
plot_profile_data
print_end_notice
