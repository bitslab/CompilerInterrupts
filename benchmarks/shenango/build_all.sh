#!/bin/bash
set -e
set -x

ROOTDIR=`pwd`

CLEAN_SHENANGO=1
BUILD_SHENANGO=1
BUILD_SWAPTIONS=1
BUILD_MEMCACHED=1
BUILD_MEMCACHED_LINUX=1
BUILD_SYNTHETIC_CLIENT=0
PATCH_N_BUILD_DPDK=0
PATCH_SHENANGO=0

if [ $PATCH_N_BUILD_DPDK -eq 1 ]; then
  pushd shenango/dpdk
  git apply ../ixgbe_18_11.patch || true

  if lspci | grep -q 'ConnectX-3'; then
      git apply ../mlx4_18_11.patch || true
      sed -i 's/CONFIG_RTE_LIBRTE_MLX4_PMD=n/CONFIG_RTE_LIBRTE_MLX4_PMD=y/g' config/common_base
  fi

  make config T=x86_64-native-linuxapp-gcc
  make
  popd
fi

if [ $PATCH_SHENANGO -eq 1 ]; then
  pushd shenango
  git apply ../shenango_16_ht.patch || true # restrict to 16 hyperthreads
  popd
fi

if [ $CLEAN_SHENANGO -eq 1 ]; then
  shenango_dirs="shenango shenango/shim shenango/bindings/cc shenango/apps/bench"
  for d in $shenango_dirs; do
    make clean -j20 -C $ROOTDIR/$d
  done
fi

if [ $BUILD_SHENANGO -eq 1 ]; then
  for d in $shenango_dirs; do
    #DEBUG=1 make -j20 -C $ROOTDIR/$d
    make -j20 -C $ROOTDIR/$d
  done
fi

if [ $BUILD_MEMCACHED -eq 1 ]; then
  pushd $ROOTDIR/memcached
  #./autogen.sh
  #./configure --with-shenango=$PWD/../shenango/
  make clean
  make -j20
  #make memcached-debug
  #make memcached
  popd
fi

if [ $BUILD_SWAPTIONS -eq 1 ]; then
  rm -rf $ROOTDIR/parsec/pkgs/apps/swaptions/inst
  rm -rf $ROOTDIR/parsec/pkgs/apps/swaptions/obj
  SHENANGODIR=$ROOTDIR/shenango $ROOTDIR/parsec/bin/parsecmgmt -a clean -p swaptions -c gcc-shenango
  SHENANGODIR=$ROOTDIR/shenango $ROOTDIR/parsec/bin/parsecmgmt -a build -p swaptions -c gcc-shenango
  $ROOTDIR/parsec/bin/parsecmgmt -a clean -p swaptions -c gcc-pthreads
  $ROOTDIR/parsec/bin/parsecmgmt -a build -p swaptions -c gcc-pthreads
fi

if [ $BUILD_SYNTHETIC_CLIENT -eq 1 ]; then
  pushd $ROOTDIR/shenango/apps/synthetic/
  cargo build --release
  popd
fi

if [ $BUILD_MEMCACHED_LINUX -eq 1 ]; then
  pushd $ROOTDIR/memcached-linux
  #./autogen.sh
  #./configure
  make
  popd
fi
