#!/bin/bash

HUGEPGSZ=`cat /proc/meminfo  | grep Hugepagesize | cut -d : -f 2 | tr -d ' '`

#
# Removes hugepage filesystem.
#
remove_mnt_huge()
{
	echo "Unmounting /mnt/huge and removing directory"
	grep -s '/mnt/huge' /proc/mounts > /dev/null
	if [ $? -eq 0 ] ; then
		sudo umount /mnt/huge
	fi

	if [ -d /mnt/huge ] ; then
		sudo rm -R /mnt/huge
	fi
}

#
# Removes all reserved hugepages.
#
clear_huge_pages()
{
	echo > .echo_tmp
	for d in /sys/devices/system/node/node? ; do
		echo "echo 0 > $d/hugepages/hugepages-${HUGEPGSZ}/nr_hugepages" >> .echo_tmp
	done
	echo "Removing currently reserved hugepages"
	sudo sh .echo_tmp
	rm -f .echo_tmp

	remove_mnt_huge
}

#
# Creates hugepage filesystem.
#
create_mnt_huge()
{
	echo "Creating /mnt/huge and mounting as hugetlbfs"
	sudo mkdir -p /mnt/huge

	grep -s '/mnt/huge' /proc/mounts > /dev/null
	if [ $? -ne 0 ] ; then
		sudo mount -t hugetlbfs nodev /mnt/huge
	fi
}

#
# Creates hugepages on specific NUMA nodes.
#
set_numa_pages()
{
	clear_huge_pages

	echo ""
	echo "  Input the number of ${HUGEPGSZ} hugepages for each node"
	echo "  Example: to have 128MB of hugepages available per node in a 2MB huge page system,"
	echo "  enter '64' to reserve 64 * 2MB pages on each node"

	echo > .echo_tmp
	Pages=8192
  echo -n "Number of pages for each node: " $Pages
	for d in /sys/devices/system/node/node? ; do
		node=$(basename $d)
#echo -n "Number of pages for $node: "
#read Pages
		echo "echo $Pages > $d/hugepages/hugepages-${HUGEPGSZ}/nr_hugepages" >> .echo_tmp
	done
	echo "Reserving hugepages"
	sudo sh .echo_tmp
	rm -f .echo_tmp

	create_mnt_huge
}

unbind_dpdk0() 
{
  # Unbind interface from igb_uio
  if [ `hostname` == "frames" ]; then
    sudo ifconfig dpdk0 down
    echo "Unbinding enp196s0f0"
    #sudo python ./dpdk-devbind.py -b ixgbe 0000:c4:00.0
    sudo /home/nbasu4/logicalclock/ci-llvm-v9/test-suite/shenango/shenango/dpdk/usertools/dpdk-devbind.py -b ixgbe 0000:c4:00.0
    sudo ifconfig enp196s0f0 192.168.34.1 netmask 255.255.255.0 up
  elif [ `hostname` == "lines" ]; then
    sudo ifconfig dpdk0 down
    echo "Unbinding enp3s0f0"
    sudo /home/nbasu4/logicalclock/ci-llvm-v9/test-suite/shenango-lines/shenango/dpdk/usertools/dpdk-devbind.py -b ixgbe 0000:03:00.0
    sudo ifconfig enp3s0f0 192.168.34.2 netmask 255.255.255.0 up
  elif [ `hostname` == "pages" ]; then
    sudo ifconfig dpdk0 down
    echo "Unbinding enp3s0f1"
    sudo /home/nbasu4/logicalclock/ci-llvm-v9/test-suite/shenango-lines/shenango/dpdk/usertools/dpdk-devbind.py -b ixgbe 0000:03:00.1
    sudo ifconfig enp3s0f0 192.168.34.3 netmask 255.255.255.0 up
  fi
}

kill_dangling_processes() {
  #echo "Process status before killing:"
  #ps -aef | grep -e "mpstat\|cstate\|iokerneld\|memcached\|swaptions\|synthetic" | grep -v "grep"
  pkill mpstat
  pkill cstate
  pkill iokerneld
  pkill memcached
  pkill memcached-debug
  pkill swaptions
  pkill synthetic
  pkill go
  pkill rstat
  echo "Process status after killing:"
  ps -aef | grep -e "mpstat\|cstate\|iokerneld\|memcached\|swaptions\|synthetic" | grep -v "grep"
  sleep 2
}

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
echo 32768 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages # for lines, with 8 sockets
cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

kill_dangling_processes
set_numa_pages

if [ $# -eq 0 ]; then
  unbind_dpdk0
fi
