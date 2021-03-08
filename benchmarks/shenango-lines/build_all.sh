#!/bin/bash
set -e
set -x

ROOTDIR=`pwd`

CLEAN_SHENANGO=1
BUILD_SHENANGO=1
BUILD_SYNTHETIC_CLIENT=1

clean_all() {
  shenango_dirs="shenango shenango/shim shenango/bindings/cc shenango/apps/bench"
  for d in $shenango_dirs; do
    make clean -j20 -C $ROOTDIR/$d
  done

  pushd $ROOTDIR/shenango/apps/synthetic/
  cargo clean --release
  popd
  rm -f scripts/synthetic
}

if [ $# -eq 1 ]; then
  echo "Cleaning shenango"
  clean_all
  exit
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

if [ $BUILD_SYNTHETIC_CLIENT -eq 1 ]; then
  pushd $ROOTDIR/shenango/apps/synthetic/
  cargo clean --release
  cargo build --release
  popd
  cp shenango/apps/synthetic/target/release/synthetic scripts/
fi
