set terminal 'pdfcairo';
set output './mops_server_vs_thread_nr_with_5_cl_per_th.pdf';
set key horiz;
set key left top;
set key maxcolumn 2;
set ylabel 'Single Server Throughput (Mops)';
set yrange [0:50];
set xlabel 'Hardware Threads';
set xrange [0:60];
plot './exp_results/dedicated_delegation_mops_FPC_5.txt' using 2:4 with linespoints pt 2 lw 2.5 ps .75 title columnhead(1), \
	for [i=0:0] './exp_results/designated_delegation_mops_CI_350_FPC_5.txt'index i using 2:4 with linespoints pt 4 lw 2.5 ps .75 title columnhead(1), \
	for [i=0:*] './exp_results/designated_delegation_mops_CI_350_FPC_5_variant.txt'index i using 2:4 with linespoints pt 4 lw 2.5 ps .75 title columnhead(1), \
	for [i=0:*] './exp_results/locks_mops_vs_threads.txt' index i using 1:2 with linespoints pt 6 lw 2.5 ps .75 title columnhead(1);

