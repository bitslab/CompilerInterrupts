#!/bin/bash


dump_data()
{
  pid=`perf script -F pid -i $app.data | head -1`
  perf script -i $app-interval.data --pid $pid > $app-interval.dump
  #perf script --per-event-dump -i fft.data
  perf script -i $app.data > $app.dump
}

find_long_intervals() {
  echo "Finding long intervals for $app"
  gawk -v intv="$interval" 'BEGIN{c=0;j=0;k=0;l=0;old_j=-1}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>intv {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 && /cycles:ppp/ {while ($3 > long_end[j] && j<c) {j++} if($3>long_start[j] && $3<long_end[j]) {doprint=1;k++;if (old_j!=j) {old_j=j; printf "%d. Duration: %f ms, Intv Start: %f, Intv End: %f\n\n", j+1, (long_end[j]-long_start[j])*1000, long_start[j], long_end[j]}} else {if(doprint){doprint=0;j++}; l++}}
  ARGIND==2 && doprint==1 {print}
  END {
    print "Number of long intervals:", c; 
    print "Number of matched significant intervals that constitute the long intervals:", k;
    print "Number of insignificant intervals:", l;
    print "Number of matched long intervals:", j;
    for (i=0;i<c;i++) { print "Start: ", long_start[i]; print "End: ", long_end[i]; }
  }' \
  $app.dump $app-interval.dump > $app-large_intv_traces.txt
}

find_long_inner_calls() {
  echo "Finding long innermost calls for $app"
  gawk -v intv="$interval" 'BEGIN{c=0;j=0;}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>intv {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 && /cycles:ppp/ {while ($3 > long_end[j] && j<c) {j++} if($3>long_start[j] && $3<long_end[j]) {doprint=1;} else if(doprint){doprint=0;j++}} 
  ARGIND==2 && doprint==1 {print}' \
  $app.dump $app-interval.dump \
  | awk '/cycles:ppp/ {printnext=1;next} 
    printnext {print $2;printnext=0}' \
  | sort \
  | uniq -c \
  | sort -n > $app-guilty_func_inner.txt
}

find_long_inner_calls_details() {
  echo "Finding long traces for $app"
  gawk -v intv="$interval" 'BEGIN{c=0;j=0;old_j=-1}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>intv {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 && /cycles:ppp/ {while ($3 > long_end[j] && j<c) {j++} if($3>long_start[j] && $3<long_end[j]) {doprint=1;printnext=1;if(old_j!=j) {old_j=j; printf "%d. Duration: %f ms, Intv Start: %f, Intv End: %f\n", j+1, (long_end[j]-long_start[j])*1000, long_start[j], long_end[j]};printf "\tcycles: %f", $4;next} else if(doprint){doprint=0;j++}} 
  ARGIND==2 && doprint==1 && printnext==1 {printf ", inner func: %s", $2; printnext=0}
  ARGIND==2 && doprint==1 && !/^$/ {outer_func=$2}
  ARGIND==2 && doprint==1 && /^$/ && outer_func {printf ", outer func: %s\n", outer_func}' \
  $app.dump $app-interval.dump \
  > $app-guilty_func_details.txt
}

find_long_outer_calls() {
  echo "Finding long outermost calls for $app"
  gawk -v intv="$interval" 'BEGIN{c=0;j=0;}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>intv {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 && /cycles:ppp/ {while ($3 > long_end[j] && j<c) {j++} if($3>long_start[j] && $3<long_end[j]) {doprint=1;} else if(doprint){doprint=0;j++}} 
  ARGIND==2 && doprint==1 && !/^$/ {outer_func=$2}
  ARGIND==2 && doprint==1 && /^$/ && outer_func {printf ", outer func: %s\n", outer_func}' \
  $app.dump $app-interval.dump \
  | sort \
  | uniq -c \
  | sort -n > $app-guilty_func_outer.txt
}

find_all_exec() {
  awk '!/^$/ {exec=$3} /^$/ {print exec}' $app-large_intv_traces.txt | sort | uniq -c
}

find_interval_sizes() {
  grep cycles $app-interval.dump | awk '{print $3}' | sort -n | uniq -c
}

app_list="radix fft lu-c lu-nc cholesky water-nsquared water-spatial ocean-cp ocean-ncp barnes volrend fmm raytrace radiosity"

for app in $app_list
do

  case "$app" in
  "fft" | "radix" | "lu-c" | "radiosity" | "raytrace" )
    interval="0.001"
    ;;
  "lu-nc" )
    interval=".00001"
    ;;
  "water-nsquared" | "water-spatial" | "lu-nc" )
    interval=".000001"
    ;;
  *)
    interval=".0001"
    ;;
  esac

  dump_data
  find_long_intervals
  find_long_inner_calls
  find_long_inner_calls_details
  find_long_outer_calls
  #find_all_exec

done
