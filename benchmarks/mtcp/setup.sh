#!/bin/bash

LINES_ADDR="a0:36:9f:2d:d9:90"
LINES_IFACE="enp3s0f0"
LINES_IP="131.193.34.70"
LINES_PCI="0000:03:00.0"
LINES_CONF_IP="192.168.34.2"

FRAMES_ADDR="a0:36:9f:17:69:b0"
FRAMES_IFACE="enp196s0f0"
FRAMES_IP="131.193.34.60"
FRAMES_PCI="0000:c4:00.0"
FRAMES_CONF_IP="192.168.34.1"

NETMASK="255.255.255.0"

unbind_frames() {
  ifconfig dpdk0 down > /dev/null
  ifconfig $FRAMES_IFACE down > /dev/null; sleep 5
  ./mtcp-server/dpdk/usertools/dpdk-devbind.py -b ixgbe $FRAMES_PCI
  iface_up=`ip addr | grep $FRAMES_IFACE | grep $FRAMES_IP`
  while [ -z "$iface_up" ]; do
    sleep 2
    ifconfig $FRAMES_IFACE $FRAMES_IP netmask $NETMASK up
    #ip addr del $FRAMES_CONF_IP/24 dev $FRAMES_IFACE
    iface_up=`ip addr | grep $FRAMES_IFACE | grep $FRAMES_IP`
  done
  rmmod dpdk_iface
  sleep 5
}

bind_dpdk_frames() {
  ifconfig $FRAMES_IFACE down

  sleep 10
  (lsmod | grep -q igb_uio) || insmod $RTE_SDK/$RTE_TARGET/kmod/igb_uio.ko
  ./mtcp-server/dpdk/usertools/dpdk-devbind.py --b igb_uio $FRAMES_PCI

  pushd ./mtcp-server/dpdk-iface-kmod
  (lsmod | grep -q dpdk_iface) || insmod dpdk_iface.ko
  ./dpdk_iface_main
  popd

  sleep 5
  iface_up=`ip addr | grep dpdk0 | grep $FRAMES_IP`
  while [ -z "$iface_up" ]; do
    sleep 2
    ifconfig dpdk0 $FRAMES_IP netmask $NETMASK up
    iface_up=`ip addr | grep dpdk0 | grep $FRAMES_IP`
  done
}

unbind_lines() {
  ifconfig dpdk0 down > /dev/null
  ifconfig $LINES_IFACE down > /dev/null; sleep 5
  ./mtcp-client/dpdk/usertools/dpdk-devbind.py -b ixgbe $LINES_PCI
  iface_up=`ip addr | grep $LINES_IFACE | grep $LINES_IP`
  while [ -z "$iface_up" ]; do
    sleep 2
    ifconfig $LINES_IFACE $LINES_IP netmask $NETMASK up
    #ip addr del $LINES_CONF_IP/24 dev $LINES_IFACE
    iface_up=`ip addr | grep $LINES_IFACE | grep $LINES_IP`
  done
  rmmod dpdk_iface
  sleep 5
}

bind_dpdk_lines() {
  ifconfig $LINES_IFACE down

  sleep 10
  (lsmod | grep -q igb_uio) || insmod $RTE_SDK/$RTE_TARGET/kmod/igb_uio.ko
  ./mtcp-client/dpdk/usertools/dpdk-devbind.py --b igb_uio $LINES_PCI

  pushd ./mtcp-client/dpdk-iface-kmod
  (lsmod | grep -q dpdk_iface) || insmod dpdk_iface.ko
  ./dpdk_iface_main
  popd

  sleep 5
  iface_up=`ip addr | grep dpdk0 | grep $LINES_IP`
  while [ -z "$iface_up" ]; do
    sleep 2
    ifconfig dpdk0 $LINES_IP netmask $NETMASK up
    iface_up=`ip addr | grep dpdk0 | grep $LINES_IP`
  done
}

setup_huge_pages() {
  HUGEPGSZ=`cat /proc/meminfo  | grep Hugepagesize | cut -d : -f 2 | tr -d ' '`
	grep -s '/mnt/huge' /proc/mounts > /dev/null
	if [ $? -ne 0 ] ; then
    echo "hugetlbfs is not mounted. Use <dpdk_path>/usertools/dpdk-setup.sh to mount. Aborting."
    exit
  fi
  
	echo > .echo_tmp
	for d in /sys/devices/system/node/node? ; do
		node=$(basename $d)
		echo "echo 8192 > $d/hugepages/hugepages-${HUGEPGSZ}/nr_hugepages" >> .echo_tmp
	done
  
	echo "Reserving hugepages"
	sudo sh .echo_tmp
	rm -f .echo_tmp
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root for mtcp mode."
   exit 1
fi

if [ ! -d mtcp-client ]; then
  echo "mtcp-client is not present. Copy mtcp-server to create mtcp-client. Aborting."
  exit
fi

if [ ! -d mtcp-server/dpdk ] || [ ! -f mtcp-server/dpdk-iface-kmod/dpdk_iface.ko ]; then
  echo "mtcp-server has not been setup properly for dpdk-based mtcp. Aborting."
  exit
fi

if [ ! -d mtcp-client/dpdk ] || [ ! -f mtcp-client/dpdk-iface-kmod/dpdk_iface.ko ]; then
  echo "mtcp-client has not been setup properly for dpdk-based mtcp. Aborting."
  exit
fi

CUR_PATH=`pwd`
server=`hostname`
export RTE_TARGET="x86_64-native-linuxapp-gcc"
if [ "$server" == "frames" ]; then
  export RTE_SDK=$CUR_PATH"/mtcp-server/dpdk"
elif [ "$server" == "lines" ]; then
  export RTE_SDK=$CUR_PATH"/mtcp-client/dpdk"
else
  echo "$server is not configured for mtcp"
  exit
fi
echo "RTE_TARGET:"$RTE_TARGET
echo "RTE_SDK:"$RTE_SDK

if [ $# -eq 1 ] && [ $1 -eq 1 ] ; then
  setup_huge_pages
  echo "Binding ports to dpdk"
  if [ "$server" == "frames" ]; then
    bind_dpdk_frames
  elif [ "$server" == "lines" ]; then
    bind_dpdk_lines
  fi
elif [ $# -eq 1 ] && [ $1 -eq 0 ] ; then
  echo "Unbinding ports from dpdk"
  if [ "$server" == "frames" ]; then
    unbind_frames
  elif [ "$server" == "lines" ]; then
    unbind_lines
  fi
fi
