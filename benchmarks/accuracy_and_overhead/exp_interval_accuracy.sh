#!/bin/bash
# this script is used for finding interval accuracy w.r.t target interval in cycles
CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-"intv_accuracy"}"
DIR=$CUR_PATH/exp_results/$SUB_DIR
WRITE_DIR=/local_home/nilanjana/temp/$SUB_DIR
PLOTS_DIR="$CUR_PATH/plots"
STAT_FILE="$DIR/interval_accuracy_statistics.txt"

CYCLE="${CYCLE:-5000}"
THREADS="${THREADS:-"1 32"}"
CI_SETTINGS="12 2 6 10 4"
EXTRA_FLAGS="-DINTV_SAMPLING"

#CI_SETTINGS="2 12"
#THREADS="1"

source $CUR_PATH/include.sh

#1 - benchmark name, 2 - ci setting, 3 - #thread
emit_interval() {
  bench=$1
  ci_setting=$2
  thread=$3
  suffix_conf=1 # always run in CI mode

  #prefix="timeout 5m taskset 0x00000001 "
  # The benchmarks export interval stats in this directory
  # TODO: Make the path configurable using environment variable
  OUT_DIR="/local_home/nilanjana/temp/interval_stats/"

  dry_run_exp $bench $suffix_conf

  # Remove dry run accuracy files
  rm -f $OUT_DIR/*

  run_exp $bench $suffix_conf $thread

  # Change default file names to meaningful names & move them to configured directory, create cdf & get statistics
  ci_str=$(get_ci_str_in_lower_case $ci_setting)
  new_file_prefix="$WRITE_DIR/${bench}-th${thread}-${ci_str}-intervals"
  # Remove old interval accuracy files
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
  sampled_merged_cdfname="${new_file_prefix}.s100"
  cat $thread_filenames | awk '!/[a-zA-Z+]/ {print}' > $merged_filename
  total_samples=`wc -l $merged_filename`
  printf "${BLUE}Merged all thread's accuracy data points to $merged_filename ( total uncollected samples: $total_uncollected_samples, total ci calls: $total_ci_calls, total samples in file: $total_samples )\n${NC}" | tee -a $CMD_LOG $STAT_FILE

  create_cdf $merged_filename $merged_cdfname $sampled_merged_cdfname

  # Remove the big files
  rm -f $thread_filenames $thread_cdfnames $merged_filename $merged_cdfname

  popd > /dev/null
}

process_data() {
  thread=$1
  pctiles_file="$DIR/pctiles-th$thread.txt"
  accerr_file="$DIR/accerr-th$thread.txt"
  plot_file="$PLOTS_DIR/accuracy-th$thread.pdf"

  mkdir -p $PLOTS_DIR
  rm -f $pctiles_file $accerr_file

  # fetch the percentiles
  for f in $WRITE_DIR/*th${thread}*-intervals.s100; do 
    gawk -v name=`basename $f` -v cyc=$CYCLE '
      BEGIN {
        split("1 5 10 30 50 70 90 95 99",ptiles," "); 
        p=1;
        sub(/-th[0-9]*-/,"+",name);
        sub(/-intervals.s100/,"",name);
      } 
      !val[p] && $1+0>=(ptiles[p]+0)/100.0 {val[p]=$2; p++} 
      END { 
        for(i=1;i<length(ptiles);i++) { 
          split(name, tokens, "+");
          if(ptiles[i]) {print tokens[2],tokens[1],ptiles[i],val[i]-cyc,val[i]}
        }
      }' $f >> $pctiles_file
  done

  # create summary file of percentiles
  cat $pctiles_file | sort -k1,2 | \
  gawk '\
    BEGIN {
      split("ci-cycles ci coredet cnb naive",colorder," ")
      split("50 1 5 10 30 70 90 95 99",pctiles," ")
    }
    $1 {cols[$1"-"$3]=1}
    $2 {rows[$2]=1}
    {vals[$1"-"$3"-"$2]=$4}
    END {
      printf("Application\t");
      for(p=1;p<=length(pctiles);p++) {
        for(cn=1;cn<=length(colorder);cn++) {
          printf "%s%s%s\t",colorder[cn], (p>1?"-":""), (p>1?pctiles[p]:"")
        }
      }
      print "";
      for(row in rows) {
        printf "%s ",row;
        for(p=1;p<=length(pctiles);p++) {
          for(cn=1;cn<=length(colorder);cn++) {
            val=vals[colorder[cn]"-"pctiles[p]"-"row];
            if(!val) {val=1000000}
            printf("%s\t", val);
          }
        }
        print ""; 
      }
    }' cycles=$CYCLE \
  > $accerr_file # first set is for 50th percentile

  # put the benches in correct order
  benches="$splash2_benches $phoenix_benches $parsec_benches"
  awk -v apps="$benches" 'BEGIN {split(apps, names, " ");}
    NR==1 {print} {line[$1]=$0} END {for(n in names){print line[names[n]];}}' $accerr_file > tmp;
  mv tmp $accerr_file

  gnuplot -e "ofile='$plot_file'" -e "ifile='$accerr_file'" plot_accuracy.gp
  printf "${GREEN}Accuracy data plotted in $plot_file\n${NC}"
}

#1 - benchmark name (optional)
interval_accuracy_test() {
#THREADS="32"
#CI_SETTINGS="10"
  echo "Experiment for Interval Accuracy for $CYCLE cycles, CI Settings $CI_SETTINGS, $THREADS threads, app list: $*"
  for thread in $THREADS; do
    for ci_setting in $CI_SETTINGS; do
      for bench in $*; do
        ci_str=$(get_ci_str $ci_setting)
        echo "Running interval accuracy experiment for $bench with $thread threads & $ci_str type" | tee -a $CMD_LOG
        set_benchmark_info $bench
        build_ci $bench $ci_setting $thread
        emit_interval $bench $ci_setting $thread
      done
    done
    #process_data $thread
  done
}

process_accuracy_data() {
  for thread in $THREADS; do
    process_data $thread
  done
}

mkdir -p $WRITE_DIR $PLOTS_DIR
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

interval_accuracy_test $benches
print_end_notice
process_accuracy_data
printf "${GREEN}Interval accuracy files are written to $WRITE_DIR. Statistics are written in $STAT_FILE.\n${NC}"
