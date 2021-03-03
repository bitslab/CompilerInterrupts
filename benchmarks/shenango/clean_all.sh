#!/bin/bash
set -e
set -x

ROOTDIR=`pwd`

# shenango
pushd shenango/dpdk
#git checkout .
rm -fr build
popd

shenango_dirs="shenango shenango/shim shenango/bindings/cc shenango/apps/bench"
for d in $shenango_dirs; do
    make -C $ROOTDIR/$d clean
done

pushd $ROOTDIR/shenango/apps/synthetic/
cargo clean
popd

make -C $ROOTDIR/memcached clean

# parsec (shenango and linux)
rm -rf $ROOTDIR/parsec/pkgs/apps/swaptions/inst
rm -rf $ROOTDIR/parsec/pkgs/apps/swaptions/obj
SHENANGODIR=$ROOTDIR/shenango $ROOTDIR/parsec/bin/parsecmgmt -a clean -p swaptions -c gcc-shenango
SHENANGODIR=$ROOTDIR/shenango $ROOTDIR/parsec/bin/parsecmgmt -a build -p swaptions -c gcc-shenango

# linux
pushd $ROOTDIR/memcached-linux
./autogen.sh
./configure
make
popd
$ROOTDIR/parsec/bin/parsecmgmt -a build -p swaptions -c gcc-pthreads
$ROOTDIR/parsec/bin/parsecmgmt -a fulluninstall
$ROOTDIR/parsec/bin/parsecmgmt -a fullclean

# linux
make -C $ROOTDIR/memcached-linux clean
