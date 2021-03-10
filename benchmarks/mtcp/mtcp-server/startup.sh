#!/bin/bash
server=`hostname`
echo "export RTE_TARGET=x86_64-native-linuxapp-gcc"
echo "export RTE_SDK=$PWD/dpdk"
