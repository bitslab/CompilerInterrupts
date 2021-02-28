set terminal 'pdfcairo';
set output './client_latency_distribution_with_54_th.pdf';
set key horiz;
set key left top;
set key maxcolumn 2;
set ylabel 'Client Request CDF';
set yrange [0:1.15];
set xtics nomirror;
set logscale x;
set xlabel 'Latency in cycles'
plot './exp_results/dedicated_delegation_latency_54_threads.txt' using 2:3 with lines lw 2.5 title columnhead(1), \
	'./exp_results/designated_delegation_latency_CI_350_54_threads.txt' using 2:3 with lines lw 2.5 title columnhead(1), \
	'./exp_results/designated_delegation_latency_CI_350_54_threads_variant.txt' using 2:3 with lines lw 2.5 title columnhead(1), \
	for [i=0:*] './exp_results/locks_latency_54_threads.txt' index i using 2:3 with lines lw 2.5 title columnhead(1); 
