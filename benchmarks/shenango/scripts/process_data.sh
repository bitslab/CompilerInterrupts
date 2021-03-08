#!/bin/bash

#if [ 0 -eq 1 ]; then
#
#
#
#cpuminer_server_stat_file=`find cpuminer/ -name "stats.frames*" -exec basename {} \;`
#cpuminer_client_stat_file=`find cpuminer/ -name "stats.lines*" -exec basename {} \;`
#
#cpuminer_server_load_file="cpuminer_server_load.txt"
#cpuminer_client_load_file="cpuminer_client_load.txt"
#
#process_mc_load_stats cpuminer/$cpuminer_server_stat_file $cpuminer_server_load_file
#process_mc_load_stats cpuminer/$cpuminer_client_stat_file $cpuminer_client_load_file
#
#cp cpuminer/cpuminer-hashrate .
#fi

create_swaptions_orig() {
  echo "Generating swaptions load comparisons for non-data mode"

  out_file="swaptions_orig"
  echo -e "NoHT\tHT-NoPinning\tHT-Pinning\tIOKerneld\tCPUMiner\tShenango-IOKerneld\tShenango-CPUMiner\tIOKerneld-Memcached\tCPUMiner-Memcached\tShenango-IOKerneld-Memcached\tShenango-CPUMiner-Memcached" | tee $out_file

#files="swaptions-orig-noht.out swaptions-orig-ht-no-pinning.out swaptions-orig-ht.out swaptions-iokerneld.out swaptions-shenango-iokerneld.out swaptions-cpuminer.out swaptions-shenango-cpuminer.out swaptions-iokerneld-memcached.out swaptions-shenango-iokerneld-memcached.out swaptions-cpuminer-memcached.out swaptions-shenango-cpuminer-memcached.out"
  files="swaptions-orig-noht.out swaptions-orig-ht-no-pinning.out swaptions-orig-ht.out swaptions-iokerneld.out swaptions-cpuminer.out swaptions-shenango-iokerneld.out swaptions-shenango-cpuminer.out swaptions-iokerneld-memcached.out swaptions-cpuminer-memcached.out swaptions-shenango-iokerneld-memcached.out swaptions-shenango-cpuminer-memcached.out"

  dir="orig_files"
  mkdir -p $dir
  for file in $files;
  do
    if [ ! -f ../$file ]; then
      echo "../$file is not present"
      exit
    fi
    cp ../$file $dir
#awk '!/Swaption per second/ {print} /Swaption per second/ {$1="";print $0}' $shenango_iokernel_file > tmp; mv tmp $shenango_iokernel_file
#awk '!/Swaption per second/ {print} /Swaption per second/ {$1="";print $0}' $shenango_cpuminer_file > tmp; mv tmp $shenango_cpuminer_file

    grep "Swaption per second" $dir/$file | grep -v "inf\|nan\|e+\|e-" | \
      awk '{total+=$4; nr+=1}
      END {printf("%0.2f\t",total/nr)}' | tee -a $out_file
    #grep "Swaption per second" $file | grep -v "inf\|nan\|e+\|e-" | wc -l
  done
  echo "" | tee -a $out_file

#grep "Swaption per second" $iokernel_file | grep -v "inf\|nan" | \
#  awk '{total+=$4; nr+=1}
#  END {printf("%0.2f\t",total/nr)}' | tee -a $orig_out_file
#grep "Swaption per second" $cpuminer_file | grep -v "inf\|nan" | \
#  awk '{total+=$4; nr+=1}
#  END {printf("%0.2f\n",total/nr)}' | tee -a $orig_out_file
}

create_swaptions_summary_load() {
  outfile="${mode}${cycle}_summary_swaptions_load"
  base_path=`pwd`
  base_path="$base_path/${mode}${cycle}"
  summary_file="${mode}${cycle}_summary_mc"
  echo -e "memcached_load(Mpps)\tthroughput\tno_data_batch_ops/s\tno_data_#records\tdata_batch_ops/s\tdata_#records" | tee $outfile
  if [ ! -f $summary_file ]; then
    echo "$summary_file needs to be created first. Run create_mc_summary() first."
    return
  fi

  echo "Generating swaptions load summary"

  for rate in $rates
  do
    dir=$rate
    if [ ! -d "$base_path/$dir" ]; then
      echo "Directory $base_path/$dir does not exist."
      continue
    fi
    stat_path="$base_path/$dir"
    raw_file=$stat_path"/swaptions.out"
    stat_file="$dir/swaptions.stat"
    start_time=$(get_data_time 0 $stat_path)
    end_time=$(get_data_time 1 $stat_path)
    #echo "Start time stamp: $start_time, End time stamp: $end_time"
    load=`echo "$rate $num_clients" | awk '{printf("%.2f",$1*$2)}'`
    actual=`awk 'NR!=1 {print $1,$2}' $summary_file | grep -w "^$load" | cut -d' ' -f 2`
    echo -ne "$load\t$actual\t" | tee -a $outfile
    grep "Swaption per second" $raw_file | grep -v "inf\|e+\|e-\|nan" | \
      awk -v start=$start_time -v end=$end_time '{if ($1>start && $1<end) {print $5}}' > data_running
    grep "Swaption per second" $raw_file | grep -v "inf\|e+\|e-\|nan" | \
      awk -v start=$start_time -v end=$end_time '{if ($1<start-1 || $1>end+1) {print $5}}' > no_data_running
    sort -n no_data_running | awk '{line[NR]=$1} END {for(i=1;i<=NR;i++) if(i/NR <= 0.75) {sum+=line[i]; cnt++}; printf("%.2f\t%d\t", sum/cnt, cnt)}' | tee -a $outfile
    sort -n data_running | awk '{line[NR]=$1} END {for(i=1;i<=NR;i++) if(i/NR <= 0.75) {sum+=line[i]; cnt++}; printf("%.2f\t%d\n", sum/cnt, cnt)}' | tee -a $outfile
  done
  rm -f data_running no_data_running
}

create_mc_summary_load() {
  outfile="${mode}${cycle}_summary_mc_load"
  base_path=`pwd`
  base_path="$base_path/${mode}${cycle}"
  echo -e "Expected\tRx\tTx" | tee $outfile
  for rate in $rates
  do
    dir="$base_path/$rate"
    server_load_file="$dir/server_load"
    client_load_file="$dir/client_load"
    echo -ne "$rate" | tee -a $outfile
    awk 'BEGIN {
                tot_rx_mops=0; 
                tot_tx_mops=0;
                nr_rx=0;
                nr_tx=0;
         } 
         { 
           if($1 != 0) {
            nr_rx+=1;
            tot_rx_mops+=$1;
           }
           if($2 != 0) {
            nr_tx+=1;
            tot_tx_mops+=$2;
           }
         }
         END { 
           printf("\t%0.2f\t%0.2f\n",
               (tot_rx_mops/(nr_rx*1000000)), 
               (tot_tx_mops/(nr_tx*1000000)));
         }' $client_load_file | tee -a $outfile
  done
}

process_mc_load_stats() {
  in_file=$1
  out_file=$2
  echo "cmd params: $@"
  echo "infile: $in_file, outfile: $out_file"
  awk 'BEGIN {FS=","; first=1} {if (first==1) {first=0; print "rx_mops","tx_mops",$11,$13} else {print $12, $14, $11, $13}}' $in_file > $out_file
}

create_mc_indv_load_files() {
  dir=$1
  base_path=`pwd`
  base_path="$base_path/${mode}${cycle}"
  stat_path="$base_path/$dir"
  server_stat_file=`find $stat_path -name "stats.frames*" -exec basename {} \;`
  server_stat_file="$stat_path/$server_stat_file"
  client_stat_file=`find $stat_path -name "stats.lines*" -exec basename {} \;`
  client_stat_file="$stat_path/$client_stat_file"
  server_load_file="$stat_path/server_load"
  client_load_file="$stat_path/client_load"
  echo "Path: $stat_path"
  echo "Out file: " $server_load_file " & " $client_load_file
  echo "In file: " $server_stat_file " & " $client_stat_file
  process_mc_load_stats $server_stat_file $server_load_file
  process_mc_load_stats $client_stat_file $client_load_file
}

create_mc_all_load_files() {
  for rate in $rates
  do
    create_mc_indv_load_files $rate
  done
  create_mc_summary_load
}

create_mc_summary() {
  base_path=`pwd`
  base_path="$base_path/${mode}${cycle}"
  echo "Generating load throughput & latency benchmark files for $mode mode"

  for client in $clients; do 
    outfile="${mode}${cycle}_${client}_detailed_summary_mc"
    echo -ne "Expected_Load(Mops), " | tee $outfile
    grep "Distribution" $base_path/0.01/${client}.memcached.out | sed 's/Never Sent/Never_Sent/g' | tee -a $outfile
    for rate in $rates; do
      dir=$rate
      if [ ! -d "$base_path/$dir" ]; then
        echo "Directory $base_path/$dir does not exist."
        continue
      fi
      log_path="$base_path/$dir/${client}.memcached.out"
      echo -n "$rate, " | tee -a $outfile
      grep "zero" $log_path | tee -a $outfile
    done
  done

  client1="${mode}${cycle}_lines_detailed_summary_mc"
  client2="${mode}${cycle}_pages_detailed_summary_mc"
  outfile="${mode}${cycle}_summary_mc"
  awk -F',' '
  FNR==NR && NR!=1 {
    load[FNR]+=$1; 
    thput[FNR]+=($4/1000000);
    med[FNR]=$7;
    pcn[FNR]=$8;
    pcnn[FNR]=$9;
    pcnnn[FNR]=$10;
    pcnnnn[FNR]=$11;
  } 
  FNR!=NR && NR!=1 {
    load[FNR]+=$1; 
    thput[FNR]+=($4/1000000);
  }
  FNR==NR && NR==1 {print $1,$4,$7,$8,$9,$10,$11}
  END {for (i=2; i<=FNR; i++) 
    printf("%.2f\t%.3f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\n", 
        load[i], thput[i], med[i], pcn[i], pcnn[i], pcnnn[i], pcnnnn[i])}' \
    $client1 $client2 | tee $outfile
}

collect_mc_latency_hist() {
  base_path=`pwd`
  base_path="$base_path/${mode}${cycle}"
  mc_client="lines.memcached.out"

  echo "Generating latency data for histogram"

#for rate in $rates; do
#rm -f $base_path/$rate/latency_hist
#done
  for client in $clients; do
    for rate in $rates; do
      dir=$rate
      if [ ! -d "$base_path/$dir" ]; then
        echo "Directory $base_path/$dir does not exist."
        continue
      fi
      lat_hist_file="$base_path/$dir/${client}_latency_hist"
      log_path="$base_path/$dir/${client}.memcached.out"
      grep "Latencies" $log_path | tr ' ' '\n' | tr ':' ' ' > $lat_hist_file
      echo "Created latency histogram file in $lat_hist_file"
    done
  done
}

copy_files() {
  prefix=$1
  dir=$1
  cp $dir/summary_mc ${prefix}_summary_mc
  cp $dir/detailed_summary_mc ${prefix}_detailed_summary_mc
  cp $dir/summary_swaptions_load ${prefix}_summary_swaptions_load
  cp $dir/summary_mc_load ${prefix}_summary_mc_load
}

get_hashrate_avg_between_intv() {
  start_time=$1
  end_time=$2
  infile=$3
  cat $infile | grep Hash | tr -d ‘,’ | tr -d ',' \
    | awk -v start=$start_time -v end=$end_time '
    {if ($3>start && $3<end) {printf("%d\t%.2f\n", $3, $4);}}' > tmp
  data_hashrate=`sort -n -k 2 tmp | head -1 | awk '{print $2}'` # get the minimum hashrate
  rm -f tmp
  echo $data_hashrate
}

process_non_data_hashrate() {
  # Orig file processing
  orig_file="cpuminer-orig.out"
  outfile="${mode}_non_data_hashrate"
  if [ ! -f "orig_files/$orig_file" ]; then
    echo "orig_files/$orig_file is not present"
    exit
  fi
#cp ../$orig_file orig_files/
  orig_hashrate=`awk 'NR==3 {printf("%.2f", $1)}' orig_files/$orig_file`
  co_iokerneld_hashrate=`awk 'NR==5 {printf("%.2f", $1)}' orig_files/$orig_file`
  co_swaptions_hashrate=`awk 'NR==7 {printf("%.2f", $1)}' orig_files/$orig_file`
  co_memcached_hashrate=`awk 'NR==9 {printf("%.2f", $1)}' orig_files/$orig_file`
  #echo "Orig: $orig_hashrate, Co-IOKerneld: $co_iokerneld_hashrate, Co-Swaptions: $co_swaptions_hashrate, Co-Memc: $co_memcached_hashrate"

  echo -e "Interval\tCPUMiner\tInt-IOKernel\tCo-IOKernel\tInt-IOKernel-Orig-%\tInt-IOKernel-Co-%\tInt-Swaptions\tCo-Swaptions\tInt-Swaptions-Orig-%\tInt-Swaptions-Co-%\tInt-Swaptions-Memcached\tCo-Swaptions-Memcached\tInt-Swaptions-Memcached-Orig-%\tInt-Swaptions-Memcached-Co-%" | tee $outfile

#intervals="500 1000 2000 5000 10000 20000"
  intervals="1000 2000 4000 8000 16000 32000 64000"
  for intv in $intervals
  do
    shenango_file="orig_files/cpuminer$intv-shenango.out"
    cpuminer_start_time=`grep cpuminer_time $shenango_file | awk '{print $2}'`
    cpuminer_end_time=`grep cpuminer_time $shenango_file | awk '{print $3}'`
    swaptions_start_time=`grep swaptions_time $shenango_file | awk '{print $2}'`
    swaptions_end_time=`grep swaptions_time $shenango_file | awk '{print $3}'`
    memcached_start_time=`grep memcached_time $shenango_file | awk '{print $2}'`
    memcached_end_time=`grep memcached_time $shenango_file | awk '{print $3}'`
    int_iokerneld_hashrate=$(get_hashrate_avg_between_intv $cpuminer_start_time $cpuminer_end_time $shenango_file)
    int_swaptions_hashrate=$(get_hashrate_avg_between_intv $swaptions_start_time $swaptions_end_time $shenango_file)
    int_memcached_hashrate=$(get_hashrate_avg_between_intv $memcached_start_time $memcached_end_time $shenango_file)
    int_iokerneld_hashrate_orig_pc=`echo "scale=2;{($int_iokerneld_hashrate*100)/$orig_hashrate}" | bc`
    int_swaptions_hashrate_orig_pc=`echo "scale=2;{($int_swaptions_hashrate*100)/$orig_hashrate}" | bc`
    int_memcached_hashrate_orig_pc=`echo "scale=2;{($int_memcached_hashrate*100)/$orig_hashrate}" | bc`
    int_iokerneld_hashrate_co_pc=`echo "scale=2;{($int_iokerneld_hashrate*100)/$co_iokerneld_hashrate}" | bc`
    int_swaptions_hashrate_co_pc=`echo "scale=2;{($int_swaptions_hashrate*100)/$co_swaptions_hashrate}" | bc`
    int_memcached_hashrate_co_pc=`echo "scale=2;{($int_memcached_hashrate*100)/$co_memcached_hashrate}" | bc`

    echo -ne "$intv\t" | tee -a $outfile
    echo -ne "$orig_hashrate\t" | tee -a $outfile

    echo -ne "$int_iokerneld_hashrate\t" | tee -a $outfile
    echo -ne "$co_iokerneld_hashrate\t" | tee -a $outfile
    echo -ne "$int_iokerneld_hashrate_orig_pc\t" | tee -a $outfile
    echo -ne "$int_iokerneld_hashrate_co_pc\t" | tee -a $outfile

    echo -ne "$int_swaptions_hashrate\t" | tee -a $outfile
    echo -ne "$co_swaptions_hashrate\t" | tee -a $outfile
    echo -ne "$int_swaptions_hashrate_orig_pc\t" | tee -a $outfile
    echo -ne "$int_swaptions_hashrate_co_pc\t" | tee -a $outfile

    echo -ne "$int_memcached_hashrate\t" | tee -a $outfile
    echo -ne "$co_memcached_hashrate\t" | tee -a $outfile
    echo -ne "$int_memcached_hashrate_orig_pc\t" | tee -a $outfile
    echo "$int_memcached_hashrate_co_pc" | tee -a $outfile
  done

}

get_data_time() {

  if [ $# -ne 2 ]; then
    echo "Usage: get_data_time <0: minimum start time, 1: maximum end time> <directory>"
    exit
  fi

  unset limit_time
  for client in $clients
  do
    client_file=$2"/${client}.memcached.out"
    if [ $1 -eq 0 ]; then
      curr_limit_time=`grep "zero" $client_file | awk -F',' '{print $11}' | tr -d " "`
    else
      curr_limit_time=`grep "zero" $client_file | awk -F',' '{print $12}' | tr -d " "`
    fi

    if [ ! -z $limit_time ]; then
      if [ $1 -eq 0 ]; then
        if [ $limit_time -gt $curr_limit_time ]; then
          limit_time=$curr_limit_time
        fi
      else
        if [ $limit_time -lt $curr_limit_time ]; then
          limit_time=$curr_limit_time
        fi
      fi
    else
      limit_time=$curr_limit_time
    fi
  done
  echo $limit_time
}

process_hashrate() {
  base_path=`pwd`
  base_path="$base_path/${mode}${cycle}"
  orig_file="cpuminer-orig.out"
  outfile="${mode}${cycle}_hashrate"
  summary_file="cpuminer${cycle}_summary_mc"
  if [ ! -f "$summary_file" ]; then
    echo "cpuminer_summary_mc needs to be created first. Run create_mc_summary() first."
    return
  fi
  if [ ! -f "orig_files/$orig_file" ]; then
    echo "orig_files/$orig_file is not present"
    exit
  fi
#cp ../$orig_file orig_files/

  orig_hashrate=`awk 'NR==3 {printf("%.2f", $1)}' orig_files/$orig_file`
  echo "Orig Hash Rate: $orig_hashrate"
  echo -e "Configured_Load(Mops)\tActual_Load(Mops)\tCPUMiner\tSwaptions-Memcached-Data\tSwaptions-Memcached-Data-%" | tee $outfile

  for rate in $rates
  do
    dir=$rate
    stat_path="$base_path/$dir"
    infile="$stat_path/cpuminer-iokernel.frames.log"
    load=`echo "$rate $num_clients" | awk '{printf("%.2f",$1*$2)}'`
    actual=`awk 'NR!=1 {print $1,$2}' $summary_file | grep -w "^$load" | cut -d' ' -f 2`
    start_time=$(get_data_time 0 $stat_path)
    end_time=$(get_data_time 1 $stat_path)
    #echo "Start time stamp: $start_time, End time stamp: $end_time"

    data_hashrate=$(get_hashrate_avg_between_intv $start_time $end_time $infile)
    data_hashrate_pc=`echo "scale=2;{($data_hashrate*100)/$orig_hashrate}" | bc`
    echo -ne "$load\t$actual\t" | tee -a $outfile
    echo -ne "$orig_hashrate\t" | tee -a $outfile
    echo -ne "$data_hashrate\t" | tee -a $outfile
    echo -ne "$data_hashrate_pc" | tee -a $outfile
    echo "" | tee -a $outfile
  done
}

#rates="0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5"
#mode="cpuminer"
#create_swaptions_summary_load
#rate="1.0"
#cycle="1000"
#process_hashrate
#process_non_data_hashrate
#exit

rates="0.01 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5"
num_clients=2
clients="lines pages"
#create_swaptions_orig

if [ ! -d "orig_files" ]; then
  echo "orig_files directory needs to be created & cpuminer-orig.out, cpuminer*-shenango.out, swaptions-*.out need to be placed in it manually."
  exit
fi


if [ $# -eq 0 ]; then
  rates="0.01 0.025 0.05 0.075 0.1 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65" # beyond this packets are getting dropped
  mode="pthread-memcached" create_mc_summary

  rates="0.01 0.025 0.05 0.075 0.1 0.15 0.20 0.25 0.30 0.35"
  mode="pthread-memcached-swaptions" create_mc_summary

  rates="0.01 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5"
  mode="standalone" create_mc_summary

  rates="0.01 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5"
  cycles="1000 2000 4000 8000 16000 32000 64000"
  for cycle in $cycles
  do
    mode="cpuminer" create_mc_summary
    mode="cpuminer" process_hashrate
  done
elif [ $# -eq 1 ]; then
  case $1 in
  0)
    mode="standalone"
    echo "Generating stat files for $mode mode"
    create_mc_summary
    create_swaptions_summary_load
    collect_mc_latency_hist
    #copy_files "standalone"
    ;;
  1)
    mode="cpuminer"
  #cycles="500 1000 2000 5000 10000 20000"
    cycles="1000 2000 4000 8000 16000 32000 64000"
    for cycle in $cycles
    do
      create_mc_summary
      process_hashrate
      create_swaptions_summary_load
      collect_mc_latency_hist
    done
    #process_non_data_hashrate
    ;;
  2) 
  #rates="0.01 0.03 0.05 0.07 0.09 0.1 0.11 0.13 0.15 0.17 0.19 0.2 0.21 0.23 0.25 0.27 0.29 0.3 0.31 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5"
    rates="0.01 0.025 0.05 0.075 0.1 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00"
    mode="pthread-memcached" # using shenango's memcached-linux
    echo "Generating stat files for $mode mode"
    create_mc_summary
    collect_mc_latency_hist
    ;;
  3) 
  #rates="0.01 0.03 0.05 0.07 0.09 0.1 0.11 0.13 0.15 0.17 0.19 0.2 0.21 0.23 0.25 0.27 0.29 0.3 0.31 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5"
    rates="0.01 0.025 0.05 0.075 0.1 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00"
    mode="pthread-memcached-swaptions"
    echo "Generating stat files for $mode mode"
    create_mc_summary
    create_swaptions_summary_load
    collect_mc_latency_hist
    ;;
  4) 
    mode="pthread-memcached-1.5.6"
    echo "Generating stat files for $mode mode"
    create_mc_summary
    collect_mc_latency_hist
    ;;
  esac
else
  echo "Usage: ./process_data <opt:- 0:standalone, 1:cpuminer>"
  exit
fi

PLOTS_DIR=$PWD"/plots"
mkdir -p $PLOTS_DIR
gnuplot -e "ofile='${PLOTS_DIR}/cpuminer-hashrate.pdf'" plot_cpuminer_hashrate.gp
gnuplot -e "ofile='${PLOTS_DIR}/99.9pc.pdf'" -e "col_index=6" -e "ymax=250" -e "key_status=1" -e "ylab='99.9% Latency ({/Symbol m}s)'" plot_shenango_latency.gp
gnuplot -e "ofile='${PLOTS_DIR}/median.pdf'" -e "col_index=3" -e "ymax=150" -e "key_status=0" -e "ylab='Median Latency ({/Symbol m}s)'" plot_shenango_latency.gp
