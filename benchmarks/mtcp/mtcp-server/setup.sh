#!/bin/bash

LINES_ADDR="a0:36:9f:2d:d9:90"
LINES_IFACE="enp3s0f0"
LINES_IP="131.193.34.70"
LINES_PCI="0000:03:00.0"

FRAMES_ADDR="a0:36:9f:17:69:b0"
FRAMES_IFACE="enp196s0f0"
FRAMES_IP="131.193.34.60"
FRAMES_PCI="0000:c4:00.0"

NETMASK="255.255.255.0"

unbind_frames() {
  ifconfig dpdk0 down
  ./dpdk/usertools/dpdk-devbind.py -b ixgbe $FRAMES_PCI
  ifconfig $FRAMES_IFACE $FRAMES_IP netmask $NETMASK up
}

bind_dpdk_frames() {
  ifconfig $FRAMES_IFACE down
  ./dpdk/usertools/dpdk-devbind.py --b igb_uio $FRAMES_PCI
  ifconfig dpdk0 $FRAMES_IP netmask $NETMASK up
}

unbind_lines() {
  ifconfig dpdk0 down
  ./dpdk/usertools/dpdk-devbind.py -b ixgbe $LINES_PCI
  ifconfig $LINES_IFACE $LINES_IP netmask $NETMASK up
}

bind_dpdk_lines() {
  ifconfig $LINES_IFACE down
  ./dpdk/usertools/dpdk-devbind.py --b igb_uio $LINES_PCI
  ifconfig dpdk0 $LINES_IP netmask $NETMASK up
}

if [ $# -ne 1 ]; then
  echo "Option not specified"
  exit
fi

CUR_PATH=`pwd`
server=`hostname`
export RTE_TARGET="x86_64-native-linuxapp-gcc-$server"
export RTE_SDK=$CUR_PATH"/dpdk"

echo "RTE_TARGET:"$RTE_TARGET
echo "RTE_SDK:"$RTE_SDK

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

rmmod igb_uio
insmod $RTE_SDK/$RTE_TARGET/kmod/igb_uio.ko
lsmod | grep igb_uio

if [ $# -eq 1 ]; then
  if [ $1 -eq 1 ]; then
    echo "Binding ports to dpdk"
    if [ "$server" == "frames" ]; then
      bind_dpdk_frames
    elif [ "$server" == "lines" ]; then
      bind_dpdk_lines
    fi
  else
    echo "Unbinding ports to dpdk"
    if [ "$server" == "frames" ]; then
      unbind_frames
    elif [ "$server" == "lines" ]; then
      unbind_lines
    fi
  fi
fi
