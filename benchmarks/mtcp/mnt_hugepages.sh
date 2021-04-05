#!/bin/bash

HUGEPGSZ=`cat /proc/meminfo  | grep Hugepagesize | cut -d : -f 2 | tr -d ' '`

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

create_mnt_huge()
{
	echo "Creating /mnt/huge and mounting as hugetlbfs"
	sudo mkdir -p /mnt/huge

	grep -s '/mnt/huge' /proc/mounts > /dev/null
	if [ $? -ne 0 ] ; then
		sudo mount -t hugetlbfs nodev /mnt/huge
	fi
}

set_numa_pages()
{
	remove_mnt_huge

	echo ""
	echo "  Input the number of ${HUGEPGSZ} hugepages for each node"
	echo "  Example: to have 128MB of hugepages available per node in a 2MB huge page system,"
	echo "  enter '64' to reserve 64 * 2MB pages on each node"

	echo > .echo_tmp
	Pages=8192
  echo -n "Number of pages for each node: " $Pages
	for d in /sys/devices/system/node/node? ; do
		node=$(basename $d)
		echo "Setting hugepages for node $d"
		echo "echo $Pages > $d/hugepages/hugepages-${HUGEPGSZ}/nr_hugepages" >> .echo_tmp
	done
	echo "Reserving hugepages"
  cat .echo_tmp
	sudo sh .echo_tmp
	rm -f .echo_tmp

	for d in /sys/devices/system/node/node? ; do
		node=$(basename $d)
		set_pages=`cat $d/hugepages/hugepages-${HUGEPGSZ}/nr_hugepages`
		if [ $Pages -ne $set_pages ]; then
		  echo "Hugepage setting failed for $d. Expected pages: $Pages, Set pages: $set_pages"
		fi
	done

	create_mnt_huge
}


server=`hostname`
echo "Mounting hugetlb on $server"
set_numa_pages

if [ "$server" == "lines" ]; then
  script_path=`pwd`
  USERNAME=`logname`
  run_str="cd $script_path; sudo ./mnt_hugepages.sh"
  ssh ${USERNAME}@frames "$run_str"
fi
