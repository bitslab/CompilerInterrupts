changequote([,])
divert(-1)


define(CORES_PER_SOCKET, esyscmd(lscpu | grep "Core" | tail -c 4 | tr -d '\n'))dnl
define(THREADS_PER_CORE, esyscmd(lscpu | grep "Thread" | tail -c 4 | tr -d '\n'))dnl
define(MAX_SOCK, esyscmd(lscpu | grep Socket | tail -c 2 | tr -d '\n'))dnl
# define(OUTPUT, esyscmd(date +%Y%m%d_%H%M%S | tr -d '\n'))dnl

define(ALL_THREADS, [esyscmd(for F in `ls -d /sys/devices/system/node/node*`; do rm -f ffwd_thread_layout_tmp; for i in $(cat $F/cpulist | sed ['s/,/ /g']); do seq -s [','] $(echo $i | tr -s ['-' ' ']) >> ffwd_thread_layout_tmp; done; cat ffwd_thread_layout_tmp | tr [ , ' ' ] | rs -T | rs 1 | sed ['s/  /,/g'] | sed ['s/$/,/']; done | sed ['$ s/.$//']; rm ffwd_thread_layout_tmp)])

# define(ALL_THREADS, [esyscmd(for F in `ls -d /sys/devices/system/node/node*`; do for i in $(cat $F/cpulist | sed ['s/,/ /g']); do seq -s [','] $(echo $i | tr -s ['-' ' ']) | sed ['s/$/,/']; done; done | sed ['$ s/.$//'] > OUTPUT; cat OUTPUT)])
# define(CLIENT_THREADS, [esyscmd(cut -d [','] -f $(((MAX_SERVERS/4)+1))- OUTPUT)])dnl
# define(SERVER_THREADS, [esyscmd(for i in `seq 1 $((MAX_SERVERS/4)) `; do awk [-F','] ' ((NR-1)% THREADS_PER_CORE ==0){print $'"$i"'}' OUTPUT | awk ['{ORS=",";}; !NF{ORS="\n"};1'] ; done | sed '$ s/.$//'; rm OUTPUT)])dnl

divert
