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

add_kernel_module() {
  pushd $CUR_PATH/dpdk-iface-kmod
  make
  rmmod dpdk_iface
  insmod ./dpdk_iface.ko
  popd
}

remove_kernel_module() {
  rmmod dpdk_iface
}

unbind_frames() {
  ifconfig dpdk0 down
  ./dpdk/usertools/dpdk-devbind.py -b ixgbe $FRAMES_PCI
  ifconfig $FRAMES_IFACE $FRAMES_IP netmask $NETMASK up
  ifconfig $FRAMES_IFACE
  remove_kernel_module
}

bind_dpdk_frames() {
  ifconfig $FRAMES_IFACE down
  ./dpdk/usertools/dpdk-devbind.py --b igb_uio $FRAMES_PCI
  add_kernel_module
  ifconfig dpdk0 $FRAMES_IP netmask $NETMASK up
}

unbind_lines() {
  ifconfig dpdk0 down
  ./dpdk/usertools/dpdk-devbind.py -b ixgbe $LINES_PCI
  ifconfig $LINES_IFACE $LINES_IP netmask $NETMASK up
  ifconfig $LINES_IFACE
  remove_kernel_module
}

bind_dpdk_lines() {
  ifconfig $LINES_IFACE down
  add_kernel_module
  ./dpdk/usertools/dpdk-devbind.py --b igb_uio $LINES_PCI
  ifconfig dpdk0 $LINES_IP netmask $NETMASK up
}

export RTE_TARGET="x86_64-native-linuxapp-gcc-$server"
export RTE_SDK=$CUR_PATH"/dpdk"

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

#if grep "ldflags.txt" $RTE_SDK/mk/rte.app.mk
#then
#    :
#else
#	echo "Changing $RTE_SDK/mk/rte.app.mk"
#    sed -i -e 's/O_TO_EXE_STR =/\$(shell if [ \! -d \${RTE_SDK}\/\${RTE_TARGET}\/lib ]\; then mkdir \${RTE_SDK}\/\${RTE_TARGET}\/lib\; fi)\nLINKER_FLAGS = \$(call linkerprefix,\$(LDLIBS))\n\$(shell echo \${LINKER_FLAGS} \> \${RTE_SDK}\/\${RTE_TARGET}\/lib\/ldflags\.txt)\nO_TO_EXE_STR =/g' $RTE_SDK/mk/rte.app.mk
#fi

#echo "RTE_TARGET afterwards:"$RTE_TARGET
#echo "RTE_SDK afterwards:"$RTE_SDK

rmmod igb_uio
insmod $RTE_SDK/$RTE_TARGET/kmod/igb_uio.ko
lsmod | grep igb_uio

echo "RTE_TARGET after insmod:"$RTE_TARGET
echo "RTE_SDK after insmod:"$RTE_SDK

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

echo "RTE_TARGET at last:"$RTE_TARGET
echo "RTE_SDK at last:"$RTE_SDK
