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

clean_all() {
  shenango_dirs="shenango shenango/shim shenango/bindings/cc shenango/apps/bench"
  for d in $shenango_dirs; do
    make clean -j20 -C $ROOTDIR/$d
  done

  pushd $ROOTDIR/memcached
  make clean
  popd

  pushd $ROOTDIR/memcached-linux
  make clean
  popd

  pushd $ROOTDIR/shenango/apps/synthetic/
  cargo clean --release
  popd
  rm -f scripts/synthetic

  rm -rf $ROOTDIR/parsec/pkgs/apps/swaptions/inst
  rm -rf $ROOTDIR/parsec/pkgs/apps/swaptions/obj
  SHENANGODIR=$ROOTDIR/shenango $ROOTDIR/parsec/bin/parsecmgmt -a clean -p swaptions -c gcc-shenango
  $ROOTDIR/parsec/bin/parsecmgmt -a clean -p swaptions -c gcc-pthreads
}

if [ $# -eq 1 ]; then
  echo "Cleaning shenango"
  clean_all
  exit
fi

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
  ./autogen.sh
  ./configure --with-shenango=${ROOTDIR}/shenango
  make clean
  make -j20
  err_status=`echo $?`
  if [ $err_status -ne 0 ]; then
    echo "Shenango based memcached failed to compile. Aborting."
    exit
  fi
  #make memcached-debug
  popd
fi

if [ $BUILD_SWAPTIONS -eq 1 ]; then
  rm -rf $ROOTDIR/parsec/pkgs/apps/swaptions/inst
  rm -rf $ROOTDIR/parsec/pkgs/apps/swaptions/obj
  SHENANGODIR=$ROOTDIR/shenango $ROOTDIR/parsec/bin/parsecmgmt -a clean -p swaptions -c gcc-shenango
  SHENANGODIR=$ROOTDIR/shenango $ROOTDIR/parsec/bin/parsecmgmt -a build -p swaptions -c gcc-shenango
  $ROOTDIR/parsec/bin/parsecmgmt -a clean -p swaptions -c gcc-pthreads
  $ROOTDIR/parsec/bin/parsecmgmt -a build -p swaptions -c gcc-pthreads
  err_status=`echo $?`
  if [ $err_status -ne 0 ]; then
    echo "Shenango based swaptions failed to compile. Aborting."
    exit
  fi
fi

if [ $BUILD_SYNTHETIC_CLIENT -eq 1 ]; then
  pushd $ROOTDIR/shenango/apps/synthetic/
  cargo clean --release
  cargo build --release
  err_status=`echo $?`
  if [ $err_status -ne 0 ]; then
    echo "Shenango based rust synthetic client failed to compile. Aborting."
    exit
  fi
  popd
  cp shenango/apps/synthetic/target/release/synthetic scripts/
fi

if [ $BUILD_MEMCACHED_LINUX -eq 1 ]; then
  pushd $ROOTDIR/memcached-linux
  ./autogen.sh
  ./configure
  make 2>&1 | tee -a make_log_memcached
  err_status=`echo $?`
  if [ $err_status -ne 0 ]; then
    echo "Pthreads based memcached failed to compile. Aborting."
    exit
  fi
  popd
fi
