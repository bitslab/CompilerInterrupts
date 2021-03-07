#!/bin/bash
# run with sudo
sysctl -w kernel.shm_rmid_forced=1
sysctl -w kernel.shmmax=18446744073692774399
sysctl -w vm.hugetlb_shm_group=27
sysctl -w vm.max_map_count=16777216
sysctl -w net.core.somaxconn=3072

for n in /sys/devices/system/node/node[1-9]; do
	echo 0 > $n/hugepages/hugepages-2048kB/nr_hugepages
done

server=`hostname`
case $server in
"frames") node=3 ;;
*) node=0 ;;
esac

hugepage_file="/sys/devices/system/node/node${node}/hugepages/hugepages-2048kB/nr_hugepages"
hugepage_count=8192
echo "Setting $hugepage_count hugepages for $hugepage_file"
echo $hugepage_count > $hugepage_file

set_count=`cat $hugepage_file`
if [ $hugepage_count -ne $set_count ]; then
  echo "Huge pages settings may have partially failed for $hugepage_file. Expected count: $hugepage_count, Set count: $set_count."
fi

cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
echo 32768 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages # for lines, with 8 sockets
cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
