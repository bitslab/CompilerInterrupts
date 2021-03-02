#!/bin/bash

perf probe -d probe_memcached:test_probe1
perf probe -d probe_memcached:test_probe2

perf probe -x ./memcached --add test_probe1=memcached.c:7878
perf probe -x ./memcached --add test_probe2=main
#sudo -H -u nbasu4 bash -c 'perf probe -x ./memcached --add test_probe1=memcached.c:7878'
#sudo -H -u nbasu4 bash -c 'perf probe -x ./memcached --add test_probe2=main'

#sudo -H -u nbasu4 bash -c 'numactl -N 3 -m 3 perf stat -e probe_memcached:test_probe2 -e probe_memcached:test_probe1 ./memcached memcached.config -t 12 -U 5215 -p 5215 -c 32768 -m 32000 -b 32768 -o hashpower=28,no_hashexpand,lru_crawler,lru_maintainer,idle_timeout=0'

#perf stat -e probe_memcached:test_probe2 -e probe_memcached:test_probe1 sudo -H -u nbasu4 bash -c 'numactl -N 3 -m 3 ./memcached memcached.config -t 12 -U 5215 -p 5215 -c 32768 -m 32000 -b 32768 -o hashpower=28,no_hashexpand,lru_crawler,lru_maintainer,idle_timeout=0'

#numactl -N 3 -m 3 perf record -e probe_memcached:test_probe2 -e probe_memcached:test_probe1 --call-graph=dwarf ./memcached memcached.config -t 12 -U 5215 -p 5215 -c 32768 -m 32000 -b 32768 -o hashpower=28,no_hashexpand,lru_crawler,lru_maintainer,idle_timeout=0

numactl -N 3 -m 3 perf record --call-graph=dwarf ./memcached memcached.config -t 12 -U 5215 -p 5215 -c 32768 -m 32000 -b 32768 -o hashpower=28,no_hashexpand,lru_crawler,lru_maintainer,idle_timeout=0

#sudo -H -u nbasu4 bash -c 'numactl -N 3 -m 3 perf record --call-graph=dwarf -o perf_memcached ./memcached memcached.config -t 12 -U 5215 -p 5215 -c 32768 -m 32000 -b 32768 -o hashpower=28,no_hashexpand,lru_crawler,lru_maintainer,idle_timeout=0'

#sudo -H -u nbasu4 bash -c 'numactl -N 3 -m 3 perf record -e probe_memcached:test_probe2 -e probe_memcached:test_probe1 --call-graph=dwarf ./memcached memcached.config -t 12 -U 5215 -p 5215 -c 32768 -m 32000 -b 32768 -o hashpower=28,no_hashexpand,lru_crawler,lru_maintainer,idle_timeout=0'

#perf report -i perf_memcached
