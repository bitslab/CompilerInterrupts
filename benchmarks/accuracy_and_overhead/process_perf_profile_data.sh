#!/bin/bash

CUR_PATH=`pwd`
SUB_DIR="${SUB_DIR:-"perf_profile"}"
DIR=$CUR_PATH/microbenchmark_stats/$SUB_DIR
CI_SETTINGS="2 12"
CMD_LOG="$DIR/perf_record_processing_info.txt"

THREAD="32"
CI_SETTINGS="12"

source $CUR_PATH/include.sh

dump_data()
{
  if [ ! -f $event_ifile ]; then
    echo "Data for $event_ifile is not available!!!"
    return
  else
    echo "Using perf script to convert $event_ifile to human-readable form in $event_ofile"
    perf script -i $event_ifile > $event_ofile
  fi

  if [ ! -f $interval_ifile ]; then
    echo "Data for $interval_ifile is not available!!!"
  else
    #pid=`perf script -F pid -i $event_ifile | head -1`
    echo "Using perf script to convert $interval_ifile to human-readable form in $interval_ofile"
    perf script -i $interval_ifile > $interval_ofile
  fi

  if [ ! -f $syscall_ifile ]; then
    echo "Data for $syscall_ifile is not available!!!"
  else
    #pid=`perf script -F pid -i $event_ifile | head -1`
    echo "Using perf script to convert $syscall_ifile to human-readable form in $syscall_ofile"
    perf script -i $syscall_ifile > $syscall_ofile
  fi

  #perf script --per-event-dump -i fft.data
  rm -f $interval_ifile $event_ifile $syscall_ifile
  printf "${GREEN}Interval data is dumped in $interval_ofile\nSyscall data is dumped in $syscall_ofile\nEvent data is dumped in $event_ofile\n${NC}" | tee -a $CMD_LOG
}

find_long_intervals_for_sampled_data() {
  if [ ! -f $event_ofile ] || [ ! -f $interval_ofile ]; then
    echo "Data for $bench ($event_ofile & $interval_ofile) is not available!!!"
    return
  fi
  large_intv_ofile=${filename}-large_intv_traces.txt
  echo "Finding long intervals for $bench"
  gawk -v intv="$interval" 'BEGIN{c=0;j=0;k=0;l=0;old_j=-1}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>intv {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 && /cycles:/ {
    while ($3>long_end[j] && j<c) {j++};
    if($3>long_start[j] && $3<long_end[j]) {
        doprint=1;k++;
        if (old_j!=j) {old_j=j; printf "%d. Duration: %f ms, Intv Start: %f, Intv End: %f\n\n", j+1, (long_end[j]-long_start[j])*1000, long_start[j], long_end[j]}
    } 
    else {
      if(doprint){doprint=0;if(j<c) j++}; l++
    }
  }
  ARGIND==2 && doprint==1 {print}
  END {
    print "Number of long intervals:", c; 
    print "Number of matched significant intervals that constitute the long intervals:", k;
    print "Number of insignificant intervals:", l;
    print "Number of matched long intervals:", j;
    for (i=0;i<c;i++) { print "Start: ", long_start[i]; print "End: ", long_end[i]; }
  }' \
  $event_ofile $interval_ofile > $large_intv_ofile
  printf "${GREEN}Long interval trace statistics & details are dumped in $large_intv_ofile\n${NC}" | tee -a $CMD_LOG
}

find_long_intervals_for_entry_system_calls() {
  large_intv_ofile=${filename}-large_intv_traces.txt
  echo "Finding long intervals for $bench for threshold interval ${interval}s"
  gawk -v intv="$interval" 'BEGIN{c=0;j=0;k=0;l=0;old_j=-1}
  ARGIND==1 && /ci_end/ {end=$4; cpu_st=$3; th_st=$2;}
  ARGIND==1 && /ci_start/ && end && $4-end>intv {
    long_start[c]=end; long_end[c]=$4; 
    cpu_start[c]=cpu_st; thread_start[c]=th_st; 
    cpu_end[c]=$3; thread_end[c]=$2; 
    c++;
    print c, long_start[c-1], long_end[c-1]}
  ARGIND==2 {
    while ($4>long_end[j] && j<c) {j++};
    if($4>=long_start[j] && $4<=long_end[j]) {
      k++;
      printf "%d. Duration: %f ms, Intv Start: %f, Intv End: %f, Sys call: %s, Thread: %d, CPU: %s\n\n", 
             j+1, (long_end[j]-long_start[j])*1000, long_start[j], long_end[j], $5, $2, $3
    } 
    else {l++;}
  }
  END {
    print "Number of long intervals:", c; 
    print "Number of matched significant system calls that constitute the long intervals:", k;
    print "Number of insignificant system calls:", l;
    for (i=0;i<c;i++) { printf "%d. Duration: %f ms, Intv Start: %f, Intv End: %f, Thread id & cpu of Start Intv: %d & %s, Thread id & cpu of End Intv: %d & %s\n\n", 
      i+1, (long_end[i]-long_start[i])*1000, long_start[i], long_end[i], thread_start[i], cpu_start[i], thread_end[i], cpu_end[i]; }
  }' \
  $event_ofile $interval_ofile > $large_intv_ofile
  printf "${GREEN}Long interval trace statistics & details are dumped in $large_intv_ofile\n${NC}" | tee -a $CMD_LOG
}

find_system_calls_started_in_long_intv() {
  guilty_syscall_ofile=${filename}-guilty_syscalls.txt
  echo "Finding long interval syscalls for $bench for threshold interval ${interval}s"

  gawk -v intv="$interval" 'BEGIN{c=0;j=0;}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>intv {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 {
    while ($4>long_end[j] && j<c) {j++} 
    if($4>=long_start[j] && $4<=long_end[j]) {print $2, $3, $4, $5}
  }' \
  $event_ofile $syscall_ofile > $guilty_syscall_ofile

  echo -e "\n\nUnique calls:- \n" >> $guilty_syscall_ofile
  gawk -v intv="$interval" 'BEGIN{c=0;j=0;}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>intv {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 {
    while ($4>long_end[j] && j<c) {j++} 
    if($4>long_start[j] && $4<long_end[j]) {print $5}
  }' \
  $event_ofile $syscall_ofile \
  | sort \
  | uniq -c \
  | sort -n >> $guilty_syscall_ofile
  printf "${GREEN}Long interval sys calls are dumped in $guilty_syscall_ofile\n${NC}" | tee -a $CMD_LOG

  echo -e "\n\nThread ids:- \n" >> $guilty_syscall_ofile
  awk '{print $2}' $syscall_ofile  | sort -n | uniq >> $guilty_syscall_ofile
}

# when interval profiling is done without call graph
find_long_intervals_and_calls() {
  large_intv_ofile=${filename}-large_intv_traces.txt
  echo "Processing $syscall_ofile & $event_ofile to create relevant statistics in $large_intv_ofile"
  echo "Finding long intervals for $bench for threshold interval ${interval}s"

  gawk -v intv="$interval" '\
  ARGIND==1 && /ci_start/ && !end[$2] {first_ts[$2]=$4}
  ARGIND==1 && /ci_end/ {
    end[$2]=$4
    last_ts[$2]=$4
    thread_intv[$2]++
  }
  ARGIND==1 && /ci_start/ && end[$2] && $4-end[$2]>=intv {
    long_start[$2][c[$2]]=end[$2]; long_end[$2][c[$2]]=$4; 
    total_duration[$2]+=($4-end[$2])
    c[$2]++;
  }
  ARGIND==2 {
    threads_in_intv[$2]++;
    while ($3>long_end[$2][j[$2]] && j[$2]<c[$2]) {j[$2]++};
    if($3>=long_start[$2][j[$2]] && $3<=long_end[$2][j[$2]]) {
      sysc_cnt[$2]++;
      sub(/+[0-9A-Za-z]*/, "", $7);
      event[$2][$7]++
      event_cycles[$2][$7]+=$3
    } 
    else {insignificant_calls[$2]++;}
  }
  END {
    printf "Threads in ci event file: "
    for (thread in thread_intv) {
      printf "%s\t", thread
    }
    printf "\n\nThreads in sampling file: "
    for (thread in threads_in_intv) {
      printf "%s\t", thread
    }
    printf "\n\n"

    for (thread in thread_intv) {
      printf "\n*** Thread %d: Unique Call/Event Statistics ***\n", thread
      printf "Number of intervals: %d, Number of long intervals: %d (%.2f%)\n", 
             thread_intv[thread], c[thread], 
             c[thread]*100/(thread_intv[thread]); 
      printf "Total runtime: %0.2f sec\n", (last_ts[thread]-first_ts[thread])
      printf "Total time spent in long intervals: %.2f sec (%.2f%)\n\n", total_duration[thread], total_duration[thread]*100/(last_ts[thread]-first_ts[thread])

      printf "\nThread %d: Unique Calls/Events (started in long interval) Statistics\n", thread
      u=0
      for (ev in event[thread]) {
        printf "%s called %d times\n", ev, event[thread][ev]
        u++
      }

      printf "\n\nThread %d: Number of calls/events involved in long intervals: %d ( %d unique calls)\n", thread, sysc_cnt[thread], u;
      printf "Thread %d: Number of inconsequential system calls: %d\n\n\n", thread, insignificant_calls[thread];
    }
  }' \
  $event_ofile $interval_ofile > $large_intv_ofile
}

# when sys calls entry & exit both are present
find_long_intervals_and_syscalls() {
  large_intv_ofile=${filename}-large_intv_syscalls.txt
  echo "Processing $syscall_ofile & $event_ofile to create relevant statistics in $large_intv_ofile"
  echo "Finding long intervals for $bench for threshold interval ${interval}s"
  gawk -v intv="$interval" '\
  ARGIND==1 && /ci_start/ && !end[$2] {first_ts[$2]=$4}
  ARGIND==1 && /ci_end/ {
    end[$2]=$4; 
    last_ts[$2]=$4
    threads_in_event[$2]++
  }
  ARGIND==1 && /ci_start/ && end[$2] && $4-end[$2]<intv {s[$2]++}
  ARGIND==1 && /ci_start/ && end[$2] && $4-end[$2]>=intv {
    long_start[$2][c[$2]]=end[$2]; long_end[$2][c[$2]]=$4; 
    total_duration[$2]+=(($4-end[$2])*1000)
    c[$2]++;
  }
  ARGIND==2 {
    threads_in_intv[$2]++
    while ($4>long_end[$2][j[$2]] && j[$2]<c[$2]) {j[$2]++};
    if($4>=long_start[$2][j[$2]] && $4<=long_end[$2][j[$2]]) {
      if(sub(/sys_enter/, "sys_exit", $5)) { 
        syscall[$2][$5]=$4 
        syscall_start[$2][$5]=long_start[$2][j[$2]]
        syscall_end[$2][$5]=long_end[$2][j[$2]]
      } else {
        k[$2]++;
        syscall_cnt[$2]++
        /*printf "long interval: %d, ", j[$2]+1*/
        if(syscall[$2][$5]) {
          if(long_start[$2][j[$2]]==syscall_start[$2][$5] && long_end[$2][j[$2]]==syscall_end[$2][$5]) {
            /*printf "syscall: %d, %s: %0.2f ms\n", syscall_cnt[$2], $5, ($4-syscall[$2][$5])*1000*/
            unique_syscall[$2][$5] += ($4-syscall[$2][$5]);
            unique_syscall_cnt[$2][$5]++;
          } else {
            /*printf "syscall: %d, %s (error): %0.2f ms\n", syscall_cnt[$2], $5, ($4-syscall[$2][$5])*1000*/
          }
        }
        /*else*/
          /*printf "syscall: %d, %s (no entry): %0.2f ms\n", syscall_cnt[$2], $5, $4*/
        delete syscall[$2][$5]
      }
    } 
    else {l[$2]++;}
  }
  END {
    print "\n************* Long Interval Statistics *************\n"

    for (thread in threads_in_event) {
      printf "--- Thread %d ---\n", thread
      printf "Number of intervals: %d, Number of long intervals: %d (%.2f%)\n", s[thread]+c[thread], c[thread], c[thread]*100/(s[thread]+c[thread]); 
      printf "Total runtime: %0.2f sec\n", (last_ts[thread]-first_ts[thread])
      printf "Total time spent in long intervals: %.2f sec (%.2f%)\n\n", total_duration[thread]/1000, (total_duration[thread]*100)/((last_ts[thread]-first_ts[thread])*1000)
    }

    print "\n************ Unique System Call Statistics ************\n"
    for (thread in threads_in_intv) {
      if (thread in unique_syscall) {
        printf "--- Thread %d ---\n", thread
        for (usc in unique_syscall[thread]) {
          total_syscall_duration[thread]+=(unique_syscall[thread][usc]*1000)
          u[thread]++
        }
        printf "Total time spent in system calls in long intervals: %0.2f ms (%0.2f%)\n", total_syscall_duration[thread], (total_syscall_duration[thread]*100)/total_duration[thread];
        printf "Number of system calls involved in long intervals: %d ( unique calls: %d )\n", k[thread], u[thread];
        printf "Number of inconsequential system calls: %d\n\n", l[thread];

        for (usc in unique_syscall[thread]) {
          name=usc
          sub(/syscalls:sys_exit_/,"",name)
          printf "%s\t%0.2f us (%0.2f%) called %d times\n", name, (unique_syscall[thread][usc]*1000), (unique_syscall[thread][usc]*1000*100/total_syscall_duration[thread]), unique_syscall_cnt[thread][usc]
        }
        printf "\n\n"
      }
      else
        printf "--- Thread %d is not found in ci events file ---\n", thread
    }
  }' \
  $event_ofile $syscall_ofile > $large_intv_ofile 2>&1
  printf "${GREEN}Long interval trace statistics & details are dumped in $large_intv_ofile\n${NC}" | tee -a $CMD_LOG
}

find_long_inner_calls() {
  inner_func_ofile=${filename}-guilty_func_inner.txt
  echo "Finding long innermost calls for $bench"
  gawk -v intv="$interval" 'BEGIN{c=0;j=0;}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>intv {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 && /cycles:/ {while ($3 > long_end[j] && j<c) {j++} if($3>long_start[j] && $3<long_end[j]) {doprint=1;} else if(doprint){doprint=0;j++}} 
  ARGIND==2 && doprint==1 {print}' \
  $event_ofile $interval_ofile \
  | awk '/cycles:/ {printnext=1;next} 
    printnext {print $2;printnext=0}' \
  | sort \
  | uniq -c \
  | sort -n > $inner_func_ofile
  printf "${GREEN}Long interval innermost calls are dumped in $inner_func_ofile\n${NC}" | tee -a $CMD_LOG
}

find_long_inner_calls_details() {
  guilty_func_ofile=${filename}-guilty_func_details.txt
  echo "Finding long traces for $bench"
  gawk -v intv="$interval" 'BEGIN{c=0;j=0;old_j=-1}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>intv {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 && /cycles:/ {while ($3 > long_end[j] && j<c) {j++} if($3>long_start[j] && $3<long_end[j]) {doprint=1;printnext=1;if(old_j!=j) {old_j=j; printf "%d. Duration: %f ms, Intv Start: %f, Intv End: %f\n", j+1, (long_end[j]-long_start[j])*1000, long_start[j], long_end[j]};printf "\tcycles: %f", $4;next} else if(doprint){doprint=0;j++}} 
  ARGIND==2 && doprint==1 && printnext==1 {printf ", inner func: %s", $2; printnext=0}
  ARGIND==2 && doprint==1 && !/^$/ {outer_func=$2}
  ARGIND==2 && doprint==1 && /^$/ && outer_func {printf ", outer func: %s\n", outer_func}' \
  $event_ofile $interval_ofile \
  > $guilty_func_ofile
  printf "${GREEN}Long interval guilty function calls are dumped in $guilty_func_ofile\n${NC}" | tee -a $CMD_LOG
}

find_long_outer_calls() {
  outer_func_ofile=${filename}-guilty_func_outer.txt
  echo "Finding long outermost calls for $bench"
  gawk -v intv="$interval" 'BEGIN{c=0;j=0;}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>intv {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 && /cycles:/ {while ($3 > long_end[j] && j<c) {j++} if($3>long_start[j] && $3<long_end[j]) {doprint=1;} else if(doprint){doprint=0;j++}} 
  ARGIND==2 && doprint==1 && !/^$/ {outer_func=$2}
  ARGIND==2 && doprint==1 && /^$/ && outer_func {printf ", outer func: %s\n", outer_func}' \
  $event_ofile $interval_ofile \
  | sort \
  | uniq -c \
  | sort -n > $outer_func_ofile
  printf "${GREEN}Long interval outermost calls are dumped in $outer_func_ofile\n${NC}" | tee -a $CMD_LOG
}

find_all_exec() {
  awk '!/^$/ {exec=$3} /^$/ {print exec}' ${filename}-large_intv_traces.txt | sort | uniq -c
}

find_interval_sizes() {
  grep cycles $interval_ofile | awk '{print $3}' | sort -n | uniq -c
}

find_long_calls_in_strace() {
  # Exporting calls > 5us
  echo "Exporting all system calls greater than 5us to $strace_ofile"
  awk '!/^ >/ {sub(/</,"",$NF); sub(/>/,"",$NF); if($NF*1000000>5) print $NF,$0}' $strace_ifile | sort -n -k 1 > $strace_ofile

  echo "Exporting all expensive system calls with cumulative duration of all calls in sorted order to $strace_stat_file"
  echo -e "\nExpensive calls in $strace_ofile: " >> $strace_stat_file
  awk '{sub(/\(.*/,"",$3); print $1, $3}' $strace_ofile | sort -k 2 | awk '{if ($2==last) {dur[$2]+=$1} else {dur[$2]=$1; last=$2}} END { for(d in dur) print d, dur[d]}' | sort -k 2 >> $strace_stat_file
}

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

strace_stat_file="strace.stat"
rm -f $strace_stat_file

for ci_setting in $CI_SETTINGS; do
  for bench in $benches; do
    interval=".0001" # 100us ~ 220000 cycles
    interval=".00001" # 10us ~ 22000 cycles
    interval=".000005" # 5us ~ 11000 cycles

    pushd $DIR > /dev/null

    old_filename="${bench}-ci${ci_setting}"
    filename="${bench}-ci${ci_setting}-th${THREAD}"
    event_ifile="${old_filename}.data"
    event_ofile="${filename}.dump"
    interval_ifile="${old_filename}-interval.data"
    interval_ofile="${filename}-interval.dump"
    syscall_ifile="${old_filename}-syscall.data"
    syscall_ofile="${filename}-syscall.dump"
    strace_ifile="${filename}.strace"
    strace_ofile="${filename}.trace"
    echo "Processing perf profile data for $bench" | tee -a $CMD_LOG
    #dump_data

    #find_long_intervals_and_syscalls
    #find_long_intervals_and_calls
    find_long_calls_in_strace

    #find_long_intervals_for_entry_system_calls
    #find_system_calls_started_in_long_intv

    echo -e "\n\n" | tee -a $CMD_LOG

    #find_long_inner_calls
    #find_long_inner_calls_details
    #find_long_outer_calls

    #find_all_exec

    popd > /dev/null
  done
done

pushd $DIR > /dev/null
echo "Exporting all expensive system calls with cumulative duration of all calls over all benchmarks in sorted order to $strace_stat_file"
echo -e "\nExpensive calls in all .trace files for all benchmarks: " | tee -a $strace_stat_file
awk '{sub(/\(.*/,"",$3); print $1, $3}' *.trace | sort -k 2 | awk '{if ($2==last) {dur[$2]+=$1} else {dur[$2]=$1; last=$2}} END { for(d in dur) print d, dur[d]}' | sort -k 2 | tee -a $strace_stat_file
popd > /dev/null
