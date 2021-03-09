#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

server=`hostname`
if [ "$server" != "frames" ]; then
  echo "This script must be run from the 'frames' server. Aborting."
  exit
fi

mnt_hugetlb() {
  server=`hostname`
  echo "Mounting hugetlb on $server"
  ./shenango/scripts/setup_huge_pages.sh

  if [ "$server" == "frames" ]; then
    script_path=`pwd`
    USERNAME=`logname`
    run_str="cd $script_path; sudo ./shenango/scripts/setup_huge_pages.sh"
    sshpass -e ssh ${USERNAME}@lines "$run_str"
    sshpass -e ssh ${USERNAME}@pages "$run_str"
  fi
}

mnt_hugetlb
./build_shenango_components.sh
err_status=`echo $?`
if [ $err_status -ne 0 ]; then
  echo "Something went wrong with the build process. Please check before continuing."
  exit
fi
pushd scripts
./experiments.sh
popd
