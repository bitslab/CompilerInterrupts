#!/bin/bash
# this script is used for checking instrumentation related statistics at compile & runtime
CUR_PATH=`pwd`/$(dirname "${BASH_SOURCE[0]}")/
SUB_DIR="${SUB_DIR:-"instrumentation_stats"}"
DIR=$CUR_PATH/exp_results/$SUB_DIR
RUN_STAT_FILE="$DIR/run_stats"
INSTR_STAT_FILE="$DIR/instr_stats"

CYCLE="${CYCLE:-5000}"
THREADS="${THREADS:-"1 32"}"
CI_SETTINGS="2 12 4 6 10"
EXTRA_FLAGS="-DAVG_STATS"
PREFIX=""

#THREADS="1"
#CI_SETTINGS="12"

source include.sh

check_probes() {
  infile=$1
  outfile=$RUN_STAT_FILE
  bench=$2
  ci_setting=$3
  th=$4
  echo -ne "$bench\t$ci_setting\t$th\t" | tee -a $outfile
  if [ "$bench" != "lu-c" ] && [ "$bench" != "lu-nc" ]; then
    grep Probe $infile \
      | grep -v main \
      | cut -d":" -f2 \
      | awk '{cnt+=$1} END {print cnt}' | tee -a $outfile
  else
    grep Probe $infile \
      | cut -d":" -f2 \
      | awk '{cnt+=$1} END {print cnt}' | tee -a $outfile
  fi
}

get_executable_size() {

  rm -f $DIR/pthread_size
  for bench in "$@"
  do
    echo "Fetching binary sizes for pthread for $bench"
    set_benchmark_info $bench

    build_orig $bench 1
    size=$(get_binary_size $bench 0)
    echo -e "$bench\t$size" >> $DIR/pthread_size
  done

  for ci_setting in $CI_SETTINGS
  do
    rm -f $DIR/ci${ci_setting}_size
    for bench in "$@"
    do
      echo "Fetching binary sizes for ci type $ci_setting for $bench"
      set_benchmark_info $bench

      build_ci $bench $ci_setting 1
      size=$(get_binary_size $bench 1)
      echo -e "$bench\t$size" >> $DIR/ci${ci_setting}_size
    done
  done
}

build_n_run() {
#THREADS="32"
#CI_SETTINGS="12"
  suffix_conf=1
  for bench in "$@"
  do
    set_benchmark_info $bench
    for ci_setting in $CI_SETTINGS
    do
      for thread in $THREADS
      do
        build_ci $bench $ci_setting $thread

        dry_run_exp $bench $suffix_conf
        run_exp $bench $suffix_conf $thread $ci_setting
        mv $OUT_FILE $DIR/${bench}_ci${ci_setting}_th${thread}_output
      done
    done
  done
}

build() {
#threads="1 32"
#ci_settings="2 12 4 6 10"
  threads="1"
  ci_settings="2"
  for bench in "$@"
  do
    set_benchmark_info $bench
    for ci_setting in $ci_settings
    do
      for thread in $threads
      do
        build_ci $bench $ci_setting $thread
      done
    done
  done
}

create_instr_stat_file() {
  threads="1"
  ci_settings="2 4"
  benches="water-nsquared water-spatial ocean-cp ocean-ncp raytrace radix fft lu-c lu-nc radiosity barnes volrend fmm cholesky"
  rm -f $INSTR_STAT_FILE
  for bench in $benches; do
    echo "*************** Application: $bench ***************" | tee -a $INSTR_STAT_FILE
    for ci_setting in $ci_settings; do
      for th in $threads; do
        BUILD_STATS_FILE="$DIR/${bench}_ci${ci_setting}_th${th}_make_err"
        if [ $ci_setting -eq 2 ]; then
          echo "******* CI stats *******" | tee -a $INSTR_STAT_FILE
          grep "total instrumentations" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "total rule1" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "total rule2" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "total rule3" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "total coredet" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "total self loop" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "total generic loop" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
          grep "Total optimization of function costs" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
        else
          echo "******* Naive stats *******" | tee -a $INSTR_STAT_FILE
          grep "total instrumentations" $BUILD_STATS_FILE | tee -a $INSTR_STAT_FILE
        fi
      done
    done
  done
  cat $INSTR_STAT_FILE
}

create_png() {
  echo "Creating CFG diagrams for $@"
  for bench in $@
  do
    set_benchmark_info $bench
    cp ../create_cfg_png.sh $BENCH_DIR
    echo ""
    pushd $BENCH_DIR
    ./create_cfg_png.sh opt_simplified.ll
    popd
  done
}

is_main_colocated() {
  prog=$1
  list_of_colocated_main="water-nsquared water-spatial ocean-cp ocean-ncp raytrace radix fft radiosity barnes volrend fmm cholesky"
  for p in $list_of_colocated_main
  do
    if [ "$prog" == "$p" ]; then
      echo 1
      return
    fi
  done
  echo 0
}

check_ci_calls() {
  infile=$1
  bench=$2
  ci_setting=$3
  th=$4
#echo -ne "$bench\t$ci_setting\t$th\t" | tee -a $outfile
  colocated_main=$(is_main_colocated $bench)
  if [ $colocated_main -eq 1 ]; then
    probe_cnt=`grep "CI Count" $infile \
      | grep -v main \
      | cut -d":" -f2 \
      | awk '{cnt+=$1} END {print cnt}'`
  else
    probe_cnt=`grep "CI Count" $infile \
      | cut -d":" -f2 \
      | awk '{cnt+=$1} END {print cnt}'`
  fi
  echo $probe_cnt
}

check_probes() {
  infile=$1
  bench=$2
  ci_setting=$3
  th=$4
#echo -ne "$bench\t$ci_setting\t$th\t" | tee -a $outfile
  colocated_main=$(is_main_colocated $bench)
  if [ $colocated_main -eq 1 ]; then
    probe_cnt=`grep "Probe Count" $infile \
      | grep -v main \
      | cut -d":" -f2 \
      | awk '{cnt+=$1} END {print cnt}'`
  else
    probe_cnt=`grep "Probe Count" $infile \
      | cut -d":" -f2 \
      | awk '{cnt+=$1} END {print cnt}'`
  fi
  echo $probe_cnt
}

commit_push_stats() {
  suffix_conf=1

  #echo -e "Application  CI-1  CI-32  CI-Cyc-1  CI-Cyc-32  Naive-1  Naive-32  CnB-1  CnB-32  CoreDet-1  CoreDet-32" | tee $probe_file $ci_calls_file
  for thread in $THREADS; do
    for ci_setting in $CI_SETTINGS; do
      ci_str=$(get_ci_str_in_lower_case $ci_setting)
      probe_vs_ci_calls_file="${DIR}/${ci_str}_th${thread}_probe_ci_call_stats"
      echo -e "Application\tProbes\tCICalls\tProbesPerCICall" | tee $probe_vs_ci_calls_file
      for bench in $@; do
        echo -ne "$bench\t" | tee -a $probe_vs_ci_calls_file
        set_benchmark_info $bench
        build_ci $bench $ci_setting $thread

        dry_run_exp $bench $suffix_conf
        run_exp $bench $suffix_conf $thread $ci_setting

        new_ofile="$DIR/${bench}_ci${ci_setting}_th${thread}_probe_output"
        mv $OUT_FILE $new_ofile

        probe_cnt=$(check_probes $new_ofile $bench $ci_setting $thread)
        ci_call_cnt=$(check_ci_calls $new_ofile $bench $ci_setting $thread)
        factor=`echo "$ci_call_cnt $probe_cnt" | awk '{printf("%d", ($2/$1))}'`
        #echo "Probe count for $bench ci $ci_setting thread $th: $probe_cnt"
        echo -e "$probe_cnt\t$ci_call_cnt\t$factor" | tee -a $probe_vs_ci_calls_file
      done
      printf "${GREEN}Exported ci call & probe stats to ${probe_vs_ci_calls_file}\n${NC}"
    done
  done
}

run_stat() {
  ofile="${DIR}/run_stats"
  ofile_raw="${DIR}/run_stats_raw"
  CI_SETTINGS_RAW="4 2 12 10 6"
  CI_SETTINGS_NORM="2 12 10 6"
  naive_setting="4"
  echo -e "Application  CI-1  CI-32  CI-Cyc-1  CI-Cyc-32  CnB-1  CnB-32  CoreDet-1  CoreDet-32" | tee $ofile
  for bench in $benches; do
    echo -ne "$bench  " | tee -a $ofile
    for ci_setting in $CI_SETTINGS_NORM; do
      for th in $THREADS; do
        naive_probe_cnt=$(check_probes ${DIR}/${bench}_ci${naive_setting}_th${th}_output $bench $ci_setting $th)
        probe_cnt=$(check_probes ${DIR}/${bench}_ci${ci_setting}_th${th}_output $bench $ci_setting $th)
        probe_cnt_pc=`echo "$probe_cnt $naive_probe_cnt" | awk '{printf("%.2f", (($1/$2)*100))}'`
        #echo "Probe count for $bench ci $ci_setting thread $th: $probe_cnt"
        echo -ne "$probe_cnt_pc  " | tee -a $ofile
      done
    done
    echo "" | tee -a $ofile
  done

  echo -e "Application  Naive-1  Naive-32  CI-1  CI-32  CI-Cyc-1  CI-Cyc-32  CnB-1  CnB-32  CoreDet-1  CoreDet-32" | tee $ofile_raw
  for bench in $benches; do
    echo -ne "$bench  " | tee -a $ofile_raw
    for ci_setting in $CI_SETTINGS_RAW; do
      for th in $THREADS; do
        probe_cnt=$(check_probes ${DIR}/${bench}_ci${ci_setting}_th${th}_output $bench $ci_setting $th)
        #echo "Probe count for $bench ci $ci_setting thread $th: $probe_cnt"
        echo -ne "$probe_cnt  " | tee -a $ofile_raw
      done
    done
    echo "" | tee -a $ofile_raw
  done
}

inst_stat() {
  for th in $THREADS; do
    thread=$1
    ofile="${DIR}/instr_stats_th${thread}"
    echo -e "Application\tCI_instr\tNaive_instr\tCI_Intr_PC\tR1\tR2\tR3\tSLT\tGLT\tFCO\tPrePO\tPostPO" | tee $ofile
    for bench in $alt_benches; do
      optfile="${DIR}/${bench}_ci2_th${thread}_make_err"
      naivefile="${DIR}/${bench}_ci4_th${thread}_make_err"
      opt_inst=`grep "total instrumentations" $optfile | awk '{count+=$4} END {print count}'`
      naive_inst=`grep "total instrumentations" $naivefile | awk '{count+=$4} END {print count}'`
      opt_inst_pc=`echo "$opt_inst $naive_inst" | awk '{printf("%.2f", ($1*100)/$2)}'`
      r1=`grep "total rule1" $optfile | awk '{count+=$4} END {print count}'`
      r2=`grep "total rule2" $optfile | awk '{count+=$4} END {print count}'`
      r3=`grep "total rule3" $optfile | awk '{count+=$4} END {print count}'`
      slt=`grep "total self loop transforms" $optfile | awk '{count+=$6} END {print count}'`
      glt=`grep "total generic loop transforms" $optfile | awk '{count+=$6} END {print count}'`
      fco=`grep "Total optimization of function costs" $optfile | awk '{count+=$6} END {print count}'`
      post_po=`grep "total coredet transforms" $optfile | awk '{count+=$5} END {print count}'`
      pre_po=`grep "Total preprocessing" $optfile | awk '{count+=$3} END {print count}'`
      if [ "$bench" == "histogram" ]; then
        echo -e "phoenix-suite  $opt_inst  $naive_inst  $opt_inst_pc  $r1  $r2  $r3  $slt  $glt  $fco  $pre_po  $post_po" | tee -a $ofile
      else
        #echo -e "$bench\t$opt_inst\t$naive_inst\t$opt_inst_pc\t$r1\t$r2\t$r3\t$slt\t$glt\t$fco\t$ppo"
        echo -e "$bench  $opt_inst  $naive_inst  $opt_inst_pc  $r1  $r2  $r3  $slt  $glt  $fco  $pre_po  $post_po" | tee -a $ofile
      fi
    done
  done
}

create_stat_file() {
  threads="1 32"
  ci_settings="2 12 4 6 10"
  benches="water-nsquared water-spatial ocean-cp ocean-ncp raytrace radix fft lu-c lu-nc radiosity barnes volrend fmm cholesky"
  cp $RUN_STAT_FILE $DIR/run_stat_backup
  echo -e "Application\tCI-Type\tThread(s)\t#Probes" > $RUN_STAT_FILE
  for bench in $benches; do
    for ci_setting in $ci_settings; do
      for th in $threads; do
        check_probes $DIR/${bench}_ci${ci_setting}_th${th}_output $bench $ci_setting $th
      done
    done
  done
  cat $RUN_STAT_FILE
}

summarize() {
  threads="1 32"
  ci_settings="2 12 6 10"
  benches="water-nsquared water-spatial ocean-cp ocean-ncp raytrace radix fft lu-c lu-nc radiosity barnes volrend fmm cholesky"
  naive_setting="4"
  RUN_STAT_FILE_MOD=$DIR"/run_stats_mod"

  echo -e "Application\tCI-Type\tThread(s)\t#Probes\t%Probes" | tee $RUN_STAT_FILE_MOD
  for bench in $benches; do
    for ci_setting in $ci_settings; do
      for th in $threads; do
        baseline=`grep $bench $RUN_STAT_FILE | grep -w $naive_setting | grep -w $th | awk '{print $4}'`
        ci_str=$(get_ci_str $ci_setting)
        grep $bench $RUN_STAT_FILE | grep -w $ci_setting | grep -w $th | awk -v name=$ci_str -v base=$baseline '{printf("%s\t%s\t%d\t%.2f\n", $1, name, $3, $4*100/base);}' \
        | tee -a $RUN_STAT_FILE_MOD
#grep $bench $RUN_STAT_FILE | grep -w $ci_setting | grep -w $th | awk -v base=$baseline '{printf("\t%.2f\n",$4*100/base)}' | tee -a $RUN_STAT_FILE_MOD
      done
    done
  done
}

# only for documenting
OPT_LOCAL=1
OPT_TL=2
NAIVE_TL=4
CD_TL=6
LEGACY_ACC=8
OPT_ACC=9
LEGACY_TL=10
NAIVE_ACC=11
OPT_INTERMEDIATE=12
NAIVE_INTERMEDIATE=13
OPT_CYCLES=17

splash2_benches="water-nsquared water-spatial ocean-cp ocean-ncp raytrace radix fft lu-c lu-nc radiosity barnes volrend fmm cholesky"
phoenix_benches="reverse_index histogram kmeans pca matrix_multiply string_match linear_regression word_count"
parsec_benches="blackscholes fluidanimate swaptions canneal streamcluster dedup"

benches="$splash2_benches $phoenix_benches $parsec_benches"
alt_benches=$splash2_benches" histogram "$parsec_benches

mkdir -p $DIR
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

echo "Running for benches: $benches"

build_n_run $benches
#build $benches
#create_png $benches

get_executable_size $benches
inst_stat 1
run_stat

# need to compile CI Pass with PROFILER flag
commit_push_stats $benches

#create_instr_stat_file
#create_stat_file
#summarize

