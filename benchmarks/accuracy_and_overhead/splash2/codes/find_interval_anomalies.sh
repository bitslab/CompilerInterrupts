#!/bin/bash

find_long_intervals() {
  gawk 'BEGIN{c=0;j=0;k=0;}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>0.001 {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 && /cycles:ppp/ {if($4>long_start[j] && $4<long_end[j]) {doprint=1;k++} else if(doprint){doprint=0;j++}}
  ARGIND==2 && doprint==1 {print}
  END {print "Number of long intervals:", c; 
  print "Number of matched system intervals:", k;
  for (i=0;i<c;i++) { print "Start: ", long_start[i]; print "End: ", long_end[i]; }
  }' \
  fft.dump system.data.cycles:ppp.dump > large_intv_traces.txt
}

find_long_intervals2() {
  gawk 'BEGIN{c=0;j=0;k=0;}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>0.001 {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 && /cycles:ppp/ {if($4>long_start[j] && $4<long_end[j]) {doprint=1;k++} else if(doprint){doprint=0;j++}}
  ARGIND==2 && doprint==1 {print}
  END {print "Number of long intervals:", c; 
  print "Number of matched system intervals:", k;
  for (i=0;i<c;i++) { print "Start: ", long_start[i]; print "End: ", long_end[i]; }
  }' \
  fft.dump system.data.cycles:ppp.dump > large_intv_traces.txt
}

find_long_inner_calls() {
  gawk 'BEGIN{c=0;j=0;}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>0.001 {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 && /cycles:ppp/ {if($4>long_start[j] && $4<long_end[j]) {doprint=1;} else if(doprint){doprint=0;j++}} 
  ARGIND==2 && doprint==1 {print}' \
  fft.dump system.data.cycles:ppp.dump \
  | awk '/cycles:ppp/ {printnext=1;next} 
    printnext {print $2;printnext=0}' \
  | sort \
  | uniq -c \
  | sort -n > guilty_func.txt
}

find_long_outer_calls() {
  gawk 'BEGIN{c=0;j=0;}
  ARGIND==1 && /ci_end/ {end=$4}
  ARGIND==1 && /ci_start/ && end && $4-end>0.001 {long_start[c]=end;long_end[c]=$4;c++}
  ARGIND==2 && /cycles:ppp/ {if($4>long_start[j] && $4<long_end[j]) {doprint=1;} else if(doprint){doprint=0;j++}} 
  ARGIND==2 && doprint==1 {print}' \
  fft.dump system.data.cycles:ppp.dump \
  | awk '
  /fft\/fft-lc/ {print outf} 
  !/fft\/fft-lc/ {outf=$2}' > guilty_func.txt
#| sort \
#| uniq -c \
#| sort -n > guilty_func.txt
}

find_all_exec() {
  awk '!/^$/ {exec=$3} /^$/ {print exec}' large_intv_traces.txt | sort | uniq -c
}

#find_long_intervals
#find_long_inner_calls
find_long_outer_calls
find_all_exec
