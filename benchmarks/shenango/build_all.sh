#!/bin/bash
set -e
set -x

ROOTDIR=`pwd`

if [ 1 -eq 1 ]; then

shenango_dirs="shenango shenango/shim shenango/bindings/cc shenango/apps/bench"
for d in $shenango_dirs; do
  make clean -j20 -C $ROOTDIR/$d
done

for d in $shenango_dirs; do
  #DEBUG=1 make -j20 -C $ROOTDIR/$d
  make -j20 -C $ROOTDIR/$d
done
fi

#exit

if [ 1 -eq 1 ]; then
pushd $ROOTDIR/memcached
./autogen.sh
./configure --with-shenango=$PWD/../shenango/
make clean
make -j20
#make memcached-debug
#make memcached
popd

rm -rf $ROOTDIR/parsec/pkgs/apps/swaptions/inst
rm -rf $ROOTDIR/parsec/pkgs/apps/swaptions/obj
SHENANGODIR=$ROOTDIR/shenango $ROOTDIR/parsec/bin/parsecmgmt -a clean -p swaptions -c gcc-shenango
SHENANGODIR=$ROOTDIR/shenango $ROOTDIR/parsec/bin/parsecmgmt -a build -p swaptions -c gcc-shenango
SHENANGODIR=$ROOTDIR/shenango $ROOTDIR/parsec/bin/parsecmgmt -a clean -p swaptions -c gcc-pthreads
SHENANGODIR=$ROOTDIR/shenango $ROOTDIR/parsec/bin/parsecmgmt -a build -p swaptions -c gcc-pthreads
fi
exit


# shenango
pushd shenango

pushd dpdk
git apply ../ixgbe_18_11.patch || true

if lspci | grep -q 'ConnectX-3'; then
    git apply ../mlx4_18_11.patch || true
    sed -i 's/CONFIG_RTE_LIBRTE_MLX4_PMD=n/CONFIG_RTE_LIBRTE_MLX4_PMD=y/g' config/common_base
fi

# Configure/compile dpdk
make config T=x86_64-native-linuxapp-gcc
make

popd
git apply ../shenango_16_ht.patch || true # restrict to 16 hyperthreads
popd

shenango_dirs="shenango shenango/shim shenango/bindings/cc shenango/apps/bench"
for d in $shenango_dirs; do
  DEBUG=1 make -C $ROOTDIR/$d
  #make -C $ROOTDIR/$d
done

pushd $ROOTDIR/shenango/apps/synthetic/
cargo build --release
popd

pushd $ROOTDIR/memcached
./autogen.sh
./configure --with-shenango=$PWD/../shenango/
make
popd

SHENANGODIR=$ROOTDIR/shenango $ROOTDIR/parsec/bin/parsecmgmt -a build -p swaptions -c gcc-shenango

# linux
pushd $ROOTDIR/memcached-linux
./autogen.sh
./configure
make
popd
$ROOTDIR/parsec/bin/parsecmgmt -a build -p swaptions -c gcc-pthreads
