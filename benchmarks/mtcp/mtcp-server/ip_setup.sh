#!/bin/bash

unbind_frames() {
  ifconfig dpdk0 down
  ifconfig dpdk0 0.0.0.0
  ifconfig enp196s0f0 131.193.34.60 netmask 255.255.255.0 up
}

add_dpdk_frames() {
  ifconfig dpdk0 131.193.34.60 netmask 255.255.255.0 up
}

deactivate_before_bind_frames() {
  ifconfig enp196s0f0 down
}

unbind_lines() {
  ifconfig dpdk0 down
  ifconfig dpdk0 0.0.0.0
  ifconfig enp3s0f0 131.193.34.70 netmask 255.255.255.0 up
}

add_dpdk_lines() {
  ifconfig dpdk0 131.193.34.70 netmask 255.255.255.0 up
}

deactivate_before_bind_lines() {
  ifconfig enp3s0f0 down
}

if [ $# -ne 1 ]; then
  echo "Option not specified"
  exit
fi

case $1 in
  1) unbind_frames
  ;;
  2) deactivate_before_bind_frames
  ;;
  3) add_dpdk_frames
  ;;
  4) unbind_lines
  ;;
  5) deactivate_before_bind_lines
  ;;
  6) add_dpdk_lines
  ;;
esac
