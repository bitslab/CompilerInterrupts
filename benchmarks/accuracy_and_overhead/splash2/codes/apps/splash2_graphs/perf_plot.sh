#!/bin/bash

prefix="ocean_ncp"
name="OceanNCP"
#files="waterns_orig_stats.csv waterns_cshift_commit_push_stack_lc.csv waterns_cshift_push_only.csv waterns_cshift_singleMLC_commit_push_tl_lc.csv waterns_cshift_commit_push_tl_lc.csv waterns_cshift_singleMLC_commit_push_stack_lc.csv waterns_cshift_singleMLC_push_only.csv"
#files="waterns_orig_stats.csv waterns_all_commit_push_stack_lc.csv waterns_all_push_only.csv waterns_all_singleMLC_commit_push_tl_lc.csv waterns_all_commit_push_tl_lc.csv waterns_all_singleMLC_commit_push_stack_lc.csv waterns_all_singleMLC_push_only.csv"
files="${prefix}_orig_stats.csv ${prefix}_bb_all_commit_push_stack_lc.csv ${prefix}_bb_all_push_only.csv ${prefix}_bb_all_singleMLC_commit_push_tl_lc.csv ${prefix}_bb_all_commit_push_tl_lc.csv ${prefix}_bb_all_singleMLC_commit_push_stack_lc.csv ${prefix}_bb_all_singleMLC_push_only.csv"
#files="waterns_orig_stats.csv stats0.csv stats1.csv stats2.csv stats3.csv stats4.csv stats5.csv"

benchmark="PerfTest"
ofile="${name}PerfTestPerBB.pdf"
#ofile="PerfTestAll.pdf"
command="set terminal pdf monochrome;"
command=$command"set output '$ofile';"
#command=$command"set title 'Splash2 ${name} benchmark';"
command=$command"set key horizontal;"
command=$command"set key top left;"
command=$command"set xlabel '#Threads';"
command=$command"set ylabel 'Duration (ms)';"
command=$command"set yrange [0:120];"
#command=$command"set yrange [0:700];"
command=$command"set xrange [0:32];"
command=$command"set ytics 0, 20, 120;"
#command=$command"set ytics 0, 100, 700;"
command=$command"set xtics 0,4,32;"
command=$command"set datafile separator ',';"
first=1
i=1
for f in $files
do
	#command=$command"plot '$ifile' using 2:4 with lp ps .75"
	#echo $command | gnuplot
  if [ $first -eq 1 ]; then
    command=$command"plot './$f' using 1:2 title columnheader(1) with lp lt 1 pt $i lw 1 ps .5"
    first=0
  else
    command=$command", './$f' using 1:2 title columnheader(1) with lp lt 1 pt $i lw 1 ps .5"
  fi  
  i=`expr $i + 1`
done

echo $command | gnuplot
echo "Plot has been generated in $ofile"

exit

