#!/bin/bash
ROOTDIR=`pwd`
CLIENTS="lines pages"

build_cpuminer() {
  # warning: This cleans files for stock shenango. So remember to build shenango again.
  echo "Building cpuminer"
  pushd ../cpuminer-multi
  ./build_shenango.sh
  popd
}

build_shenango_client() {
  for cl in $CLIENTS; do
    if [ ! -d ../shenango-$cl ]; then
      echo "Client $cl is not configured. Aborting."
      exit
    fi
    echo "Building for client $cl"
    pushd ../shenango-$cl/
    ./build_all.sh
    popd
  done
}

build_shenango_server() {
  ./build_all.sh
}

check_all_builds() {
  rm -f build_err_log
  intervals="8000 4000 16000 2000 32000 1000 64000"
  err=0
  for intv in $intervals; do
    if [ ! -f ../cpuminer-multi/cpuminer-$intv ] ; then
      echo "../cpuminer-multi/cpuminer-$intv not found. Aborting." | tee -a build_err_log
      err=`expr $err + 1`
    fi
  done
  if [ ! -f ../cpuminer-multi/cpuminer-orig ] ; then
    echo "../cpuminer-multi/cpuminer-orig not found. Aborting." | tee -a build_err_log
    err=`expr $err + 1`
  fi
  for cl in $CLIENTS; do
    if [ ! -f ../shenango-$cl/scripts/synthetic ] ; then
      echo "../shenango-$cl/scripts/synthetic not found. Aborting." | tee -a build_err_log
      err=`expr $err + 1`
    fi
    if [ ! -f ../shenango-$cl/shenango/iokerneld ] ; then
      echo "../shenango-$cl/shenango/iokerneld not found. Aborting." | tee -a build_err_log
      err=`expr $err + 1`
    fi
  done
  if [ ! -f shenango/iokerneld ] ; then
    echo "shenango/iokerneld not found. Aborting." | tee -a build_err_log
    err=`expr $err + 1`
  fi
  if [ ! -f memcached-linux/memcached ] ; then
    echo "memcached-linux/memcached not found. Aborting." | tee -a build_err_log
    err=`expr $err + 1`
  fi
  if [ ! -f memcached/memcached ] ; then
    echo "memcached/memcached not found. Aborting." | tee -a build_err_log
    err=`expr $err + 1`
  fi
  if [ ! -f parsec/pkgs/apps/swaptions/inst/amd64-linux.gcc-pthreads/bin/swaptions ] ; then
    echo "parsec/pkgs/apps/swaptions/inst/amd64-linux.gcc-pthreads/bin/swaptions not found. Aborting." | tee -a build_err_log
    err=`expr $err + 1`
  fi
  if [ ! -f parsec/pkgs/apps/swaptions/inst/amd64-linux.gcc-shenango/bin/swaptions ] ; then
    echo "parsec/pkgs/apps/swaptions/inst/amd64-linux.gcc-shenango/bin/swaptions not found. Aborting." | tee -a build_err_log
    err=`expr $err + 1`
  fi
  if [ $err -ne 0 ]; then
    echo "$err number of builds failed. Check build_err_log for details."
    exit
  fi
}

if [ $# -eq 1 ]; then
  echo "Cleaning all components"
  ./build_all.sh 1
  pushd ../cpuminer-multi
  ./build_shenango.sh 1
  popd
  for cl in $CLIENTS; do
    echo "Cleaning shenango-$cl"
    pushd ../shenango-$cl/
    ./build_all.sh 1
    popd
  done
  exit
fi

echo "Building all components"

build_cpuminer
build_shenango_client
build_shenango_server
check_all_builds
