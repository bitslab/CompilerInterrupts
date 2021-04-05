#!/bin/bash
server=`hostname`
echo "Set the next two environment in your shell"
echo "export RTE_TARGET=x86_64-native-linuxapp-gcc"
echo "export RTE_SDK=$PWD/dpdk"
