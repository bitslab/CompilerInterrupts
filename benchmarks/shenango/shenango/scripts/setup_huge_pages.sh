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
	cat .echo_tmp
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
	#clear_huge_pages
	remove_mnt_huge

	echo ""
	echo "  Input the number of ${HUGEPGSZ} hugepages for each node"
	echo "  Example: to have 128MB of hugepages available per node in a 2MB huge page system,"
	echo "  enter '64' to reserve 64 * 2MB pages on each node"

	echo > .echo_tmp

  server=`hostname`
  case $server in
    "frames") node_name="node3" ;;
    *) node_name="node0" ;;
  esac

	Pages=8192

  echo -n "Number of pages for each node: " $Pages
	for d in /sys/devices/system/node/node? ; do
		node=$(basename $d)
#echo -n "Number of pages for $node: "
#read Pages
		echo "Setting hugepages for node $d"
    if [ "$node_name" == "$node" ]; then
		  echo "echo $Pages > $d/hugepages/hugepages-${HUGEPGSZ}/nr_hugepages" >> .echo_tmp
    else
		  echo "echo 0 > $d/hugepages/hugepages-${HUGEPGSZ}/nr_hugepages" >> .echo_tmp
    fi
	done
	echo "Reserving hugepages"
  cat .echo_tmp
	sudo sh .echo_tmp
	#cat .echo_tmp
	rm -f .echo_tmp

	for d in /sys/devices/system/node/node? ; do
		node=$(basename $d)
		set_pages=`cat $d/hugepages/hugepages-${HUGEPGSZ}/nr_hugepages`
    if [ "$node_name" == "$node" ]; then
		  if [ $Pages -ne $set_pages ]; then
			  echo "Hugepage setting failed for $d. Expected pages: $Pages, Set pages: $set_pages"
		  fi
    fi
	done

	create_mnt_huge
}

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
echo 32768 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages # for lines, with 8 sockets
cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

set_numa_pages
