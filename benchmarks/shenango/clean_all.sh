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
$ROOTDIR/parsec/bin/parsecmgmt -a fulluninstall
$ROOTDIR/parsec/bin/parsecmgmt -a fullclean

# linux
make -C $ROOTDIR/memcached-linux clean
