#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

CUR_PATH=`pwd`
EXP_DIR="${CUR_PATH}/exp_results"
PLOTS_DIR="${CUR_PATH}/plots"
ERROR_LOG="${EXP_DIR}/error_log"

run_command() {
  command=$@
  echo "Command: "$command
  eval $command
  if [ $? -ne 0 ]; then
    error_status=$?
    echo "Command failed with status $error_status. Command: $command"
    exit
    return $?
  fi
}

run_command_no_err() {
  command=$@
  echo "Command: "$command
  eval $command
}

GET_USABLE_CPUS() {
  cpu_list=""

  LAST_CPU=31
  for i in $(seq 24 $LAST_CPU); do
    cpu_list=$cpu_list$i","
  done

  LAST_CPU=63
  for i in $(seq 56 $LAST_CPU); do
    cpu_list=$cpu_list$i","
  done
  cpu_list=`echo $cpu_list | sed 's/.$//'`
  echo $cpu_list
}

kill_server() {
  echo "Killing processes"
  #echo "Process status before killing:"
  #ps -aef | grep -e "mpstat\|cstate\|iokerneld\|memcached\|swaptions" | grep -v "grep"
  cmd="pkill mpstat; \
  pkill cstate; \
  pkill iokerneld; \
  pkill memcached; \
  pkill memcached-debug; \
  pkill swaptions; \
  pkill synthetic; \
  pkill go; \
  pkill rstat;"
  run_command_no_err $cmd

  # Debug print for other users running on lines
  #echo "Is MEMCACHED running??"
  #pgrep memcached
  #echo "Other user's processes that are running:-"
  #top -b -n 1 -i -u '!${USER_NAME}'

  if [ -z "$do_not_kill_cpuminer" ]; then
    pkill cpuminer
  else
    echo "Not Killing CPUMiner"
  fi
  echo "Process status after killing:"
  ps -aef | grep -e "mpstat\|cstate\|iokerneld\|memcached\|swaptions\|cpuminer" | grep -v "grep"

  #CURR_DIR=`pwd`
  #SRC_SCRIPT_DIR="$CURR_DIR/../shenango/scripts"
  #echo "Unbinding IPs & setting up memory huge pages needed by dpdk"
  #$SRC_SCRIPT_DIR/setup_huge_pages.sh

  if [ -z "$do_not_kill_cpuminer" ]; then
    cpuminer_running=`pgrep cpuminer`
  else
    unset cpuminer_running
  fi
  iokerneld_running=`pgrep iokerneld` 
  memcached_running=`pgrep memcached` 
  swaptions_running=`pgrep swaptions` 

  while [ ! -z "$memcached_running" ] || [ ! -z "$iokerneld_running" ] || [ ! -z "$swaptions_running" ] || [ ! -z "$cpuminer_running" ]
  do
    sleep 2
    echo "Some of the programs are still running. Waiting for them to die."
    iokerneld_running=`pgrep iokerneld` 
    memcached_running=`pgrep memcached` 
    swaptions_running=`pgrep swaptions` 
    if [ -z "$do_not_kill_cpuminer" ]; then
      cpuminer_running=`pgrep cpuminer`
    fi
  done
}

unbind_dpdk_ports() {
  server=`hostname`
  if [ "$server" == "cs-pages" ]; then
    server="pages"
  fi
  NETMASK="255.255.255.0"
  if [ "$server" == "frames" ]; then
    NIC_IFNAME="enp196s0f0"
    NIC_PCI="0000:c4:00.0"
    MAC_ADDR="a0:36:9f:17:69:b0"
    IP="192.168.34.1"
  elif [ "$server" == "lines" ]; then
    NIC_IFNAME="enp3s0f0"
    NIC_PCI="0000:03:00.0"
    MAC_ADDR="a0:36:9f:2d:d9:90"
    IP="192.168.34.2"
  elif [ "$server" == "pages" ]; then
    NIC_IFNAME1="enp3s0f1"
    NIC_PCI1="0000:03:00.1"
    MAC_ADDR1="a0:36:9f:25:89:fa"
    IP1="192.168.34.3"

    NIC_IFNAME2="enp3s0f0"
    NIC_PCI2="0000:03:00.0"
    MAC_ADDR2="a0:36:9f:25:89:f8"
    IP2="192.168.34.4"

    CURR_DIR=`pwd`
    SRC_DIR="$CURR_DIR/../shenango"

    cmd="ifconfig dpdk0 down"
    run_command_no_err $cmd
    cmd="ifconfig dpdk1 down"
    run_command_no_err $cmd
    cmd="$SRC_DIR/dpdk/usertools/dpdk-devbind.py -b ixgbe $NIC_PCI1"
    run_command $cmd
    cmd="$SRC_DIR/dpdk/usertools/dpdk-devbind.py -b ixgbe $NIC_PCI2"
    run_command $cmd
    cmd="ifconfig $NIC_IFNAME1 $IP1 netmask $NETMASK up"
    run_command $cmd
    cmd="ifconfig $NIC_IFNAME2 $IP2 netmask $NETMASK up"
    run_command $cmd
    sleep 5

    return
  fi
  CURR_DIR=`pwd`
  SRC_DIR="$CURR_DIR/../shenango"

  cmd="ifconfig dpdk0 down"
  run_command_no_err $cmd
  cmd="$SRC_DIR/dpdk/usertools/dpdk-devbind.py -b ixgbe $NIC_PCI"
  run_command $cmd
  cmd="ifconfig $NIC_IFNAME $IP netmask $NETMASK up"
  run_command $cmd
  sleep 5
}

#unused
create_linux_server_env() {
  CURR_DIR=`pwd`
  SRC_DIR="$CURR_DIR/../shenango"
  USABLE_CPUS=$(GET_USABLE_CPUS)
  echo "CPUs for affinity setting: "$USABLE_CPUS

  echo "Creating linux environment"

  cmd="$SRC_DIR/scripts/setup_machine.sh"
  run_command $cmd
  cmd="modprobe ixgbe"
  run_command $cmd

  unbind_dpdk_ports

  cmd="ethtool -N $NIC_IFNAME rx-flow-hash udp4 sdfn" # configures hashing on udp4 flow
  run_command $cmd
  cmd="$SRC_DIR/scripts/set_irq_affinity $USABLE_CPUS $NIC_IFNAME"
  run_command $cmd
  cmd="sysctl net.ipv4.tcp_syncookies=1"
  run_command $cmd

#cmd="ip addr flush $NIC_IFNAME"
#cmd="ip addr add $IP/24 dev $NIC_IFNAME"
}

bind_dpdk_port() {
  server=`hostname`
  if [ "$server" == "cs-pages" ]; then
    server="pages"
  fi
  if [ "$server" == "frames" ]; then
    NIC_IFNAME="enp196s0f0"
    NIC_PCI="0000:c4:00.0"
  elif [ "$server" == "lines" ]; then
    NIC_IFNAME="enp3s0f0"
    NIC_PCI="0000:03:00.0"
  elif [ "$server" == "pages" ]; then
    NIC_IFNAME1="enp3s0f1"
    NIC_PCI1="0000:03:00.1"
    NIC_IFNAME2="enp3s0f0"
    NIC_PCI2="0000:03:00.0"

    CURR_DIR=`pwd`
    SRC_DIR="$CURR_DIR/../shenango"

    if [ 1 -eq 1 ]; then
      cmd="ifconfig $NIC_IFNAME1 down"
      run_command_no_err $cmd
      cmd="modprobe uio"
      run_command $cmd
      cmd="(lsmod | grep -q igb_uio) || insmod $SRC_DIR/dpdk/build/kmod/igb_uio.ko"
      run_command $cmd
      cmd="$SRC_DIR/dpdk/usertools/dpdk-devbind.py -b igb_uio $NIC_PCI1"
      run_command $cmd
    fi

    echo "Interface $NIC_IFNAME2($NIC_PCI2), $NIC_IFNAME1($NIC_PCI1)"
    cmd="ifconfig $NIC_IFNAME2 down"
    run_command_no_err $cmd
    cmd="modprobe uio"
    run_command $cmd
    cmd="(lsmod | grep -q igb_uio) || insmod $SRC_DIR/dpdk/build/kmod/igb_uio.ko"
    run_command $cmd
    cmd="$SRC_DIR/dpdk/usertools/dpdk-devbind.py -b igb_uio $NIC_PCI2"
    run_command $cmd

    return
  fi
  CURR_DIR=`pwd`
  SRC_DIR="$CURR_DIR/../shenango"

  cmd="ifconfig $NIC_IFNAME down"
  run_command_no_err $cmd
  cmd="modprobe uio"
  run_command $cmd
  cmd="(lsmod | grep -q igb_uio) || insmod $SRC_DIR/dpdk/build/kmod/igb_uio.ko"
  run_command $cmd
  cmd="$SRC_DIR/dpdk/usertools/dpdk-devbind.py -b igb_uio $NIC_PCI"
  run_command $cmd
}

create_shenango_env() {
  CURR_DIR=`pwd`
  SRC_DIR="$CURR_DIR/../shenango"
  server=`hostname`
#if [ "$server" == "cs-pages" ]; then
#server="pages"
#fi

  kill_server
  #sleep 5 

#cmd="time $SRC_DIR/scripts/setup_huge_pages.sh"
#run_command $cmd
  cmd="$SRC_DIR/scripts/setup_machine.sh"
  run_command $cmd
  cmd="rm -f *stats.${server}.*"
  run_command $cmd

  bind_dpdk_port
}

run_swaptions_iokernel_memcached()
{
  run_iokernel_preload $@
  sleep 10

  # shmget fails when run in non-superuser mode. Therefore, superuser check is commented out in memcached code.
  #cmd="sudo -H -u ${USER_NAME} bash -c 'numactl -N 3 -m 3 -C 25-31,57-63 ${CUR_PATH}/../memcached/memcached memcached.config -t 12 -U 5215 -p 5215 -c 32768 -m 32000 -b 32768 -o hashpower=28,no_hashexpand,lru_crawler,lru_maintainer,idle_timeout=0 2>&1 | tee memcached.out &'"
  cmd="numactl -N 3 -m 3 -C 25-31,57-63 ${CUR_PATH}/../memcached/memcached memcached.config -t 12 -U 5215 -p 5215 -c 32768 -m 32000 -b 32768 -o hashpower=28,no_hashexpand,lru_crawler,lru_maintainer,idle_timeout=0 2>&1 | tee memcached.out &"
  run_command $cmd
  sleep 20

  swaptions_exec="swaptions"
  swaptions_path="${CUR_PATH}/../parsec/pkgs/apps/swaptions/inst/amd64-linux.gcc-pthreads/bin/"
  if [ $1 -eq 0 ]; then
    swaptions_log="swaptions-iokerneld-memcached.out"
  else
    swaptions_log="swaptions-cpuminer-memcached.out"
  fi
  pushd $swaptions_path
  curr=`pwd`
  if [ ! -f "$swaptions_exec" ]; then
    echo "$swaptions_exec is not present at $curr!!"
    exit
  fi
  cmd="timeout 30s numactl -N 3 -m 3 -C 25-31,57-63 ./$swaptions_exec -ns 14 -sm 40000 -nt 14 2>&1 | tee $swaptions_log"
  run_command $cmd
  if [ ! -f $swaptions_log ]; then
    echo "Swaptions log file $swaptions_log is not present at $curr!!"
    exit
  fi
  popd
  mv $swaptions_path/$swaptions_log .

  kill_server
}

run_swaptions_shenango() {
  case $1 in
  0)
    swaptions_log="swaptions-shenango-iokerneld.out"
    run_iokernel_preload 0
    ;;
  1)
    swaptions_log="swaptions-shenango-cpuminer.out"
    run_iokernel_preload 1
    ;;
  2)
    swaptions_log="swaptions-shenango-iokerneld-memcached.out"
    run_iokernel_preload 0
    ;;
  3)
    swaptions_log="swaptions-shenango-cpuminer-memcached.out"
    run_iokernel_preload 1
    ;;
  esac
  sleep 20
  run_shenango_swaptions
  if [ $1 -eq 2 ] || [ $1 -eq 3 ]; then
    run_shenango_memcached
  fi
  sleep 40

  pkill swaptions
  mv swaptions.out $swaptions_log
  awk '!/Swaption per second/ {print} /Swaption per second/ {$1="";print $0}' $swaptions_log > tmp; mv tmp $swaptions_log
}

run_swaptions_iokernel()
{
  run_iokernel_preload $@
  swaptions_exec="swaptions"
  swaptions_path="${CUR_PATH}/../parsec/pkgs/apps/swaptions/inst/amd64-linux.gcc-pthreads/bin/"
  if [ $1 -eq 0 ]; then
    swaptions_log="swaptions-iokerneld.out"
  else
    swaptions_log="swaptions-cpuminer.out"
  fi
  pushd $swaptions_path
  curr=`pwd`
  if [ ! -f "$swaptions_exec" ]; then
    echo "$swaptions_exec is not present at $curr!!"
    exit
  fi

  # No running on iokerneld core or hyperthread
  cmd="timeout 30s numactl -N 3 -m 3 -C 25-31,57-63 ./$swaptions_exec -ns 14 -sm 40000 -nt 14 2>&1 | tee $swaptions_log"
  run_command $cmd
  if [ ! -f $swaptions_log ]; then
    echo "Swaptions log file $swaptions_log is not present at $curr!!"
    exit
  fi
  popd
  mv $swaptions_path/$swaptions_log .

  kill_server
}

run_swaptions_orig()
{
  if [ $# -lt 1 ]; then
    echo "Usage: run_swaptions_orig <0: no-ht, 1:ht-no-single-node-pinning, 2:ht-single-node-pinning> <timeout disabled: optional>"
    exit
  fi

  # not used - for parsec from a different path
  #swaptions_exec="swaptions_llvm"
  #pushd $swaptions_path
  #make clean -f Makefile.shenango
  #make -f Makefile.shenango
  pushd swaptions/src

  if [ $1 -le 2 ]; then
    kill_server
  fi

  swaptions_exec="swaptions"
  swaptions_path="${CUR_PATH}/../parsec/pkgs/apps/swaptions/inst/amd64-linux.gcc-pthreads/bin/"
  pushd $swaptions_path
  curr=`pwd`
  if [ ! -f "$swaptions_exec" ]; then
    echo "$swaptions_exec is not present at $curr!!"
    exit
  fi
  #cmd="timeout 30s ./swaptions_llvm -ns 16 -sm 40000 -nt 16 2>&1 | tee $swaptions_log"

  case $1 in
  0) 
    echo "Turning off Hyperthreading"
    echo "off" > /sys/devices/system/cpu/smt/control
    cat /sys/devices/system/cpu/smt/active
    swaptions_log="swaptions-orig-noht.out"
    cmd="timeout 30s ./$swaptions_exec -ns 8 -sm 40000 -nt 8 > $swaptions_log 2>&1 &" # since hyperthreads are disabled, 8 full cores are used
    run_command $cmd
    sleep 35
    ;;
  1)
    swaptions_log="swaptions-orig-ht-no-pinning.out"
    cmd="timeout 30s ./$swaptions_exec -ns 16 -sm 40000 -nt 16 > $swaptions_log 2>&1 &"
    run_command $cmd
    sleep 35
    ;;
  2)
    swaptions_log="swaptions-orig-ht.out"
    cmd="timeout 30s numactl -N 3 -m 3 ./$swaptions_exec -ns 16 -sm 40000 -nt 16 > $swaptions_log 2>&1 &"
    run_command $cmd
    sleep 35
    ;;
  3)
    swaptions_log="swaptions.out"
    cmd="numactl -N 3 -m 3 ./$swaptions_exec -ns 16 -sm 40000 -nt 16 > $swaptions_log 2>&1 &"
    run_command $cmd
    ;;
  esac

  popd

  if [ $1 -le 2 ]; then
    if [ ! -f $swaptions_path/$swaptions_log ]; then
      echo "Swaptions log file $swaptions_path/$swaptions_log!!"
      exit
    fi
    mv $swaptions_path/$swaptions_log .
  fi
  #mv $swaptions_path/swaptions/src/$swaptions_log .

  if [ $1 -eq 0 ]; then
    echo "Turning on Hyperthreading"
    echo "on" > /sys/devices/system/cpu/smt/control
    cat /sys/devices/system/cpu/smt/active
  fi
}

cpuminer_orig_experiment()
{
  kill_server
  cpuminer_path="${CUR_PATH}/../../cpuminer-multi/"
  swaptions_exec="${CUR_PATH}/../parsec/pkgs/apps/swaptions/inst/amd64-linux.gcc-pthreads/bin/swaptions"

  # to make the environment similar to shenango
  CURR_DIR=`pwd`
  SRC_DIR="$CURR_DIR/../shenango"
  cmd="$SRC_DIR/scripts/setup_machine.sh"
  run_command $cmd

  # To make the background similar to cpuminer-shenango experiment
  # (Disabling the power saving more seemed to have a negative impact on original cpuminer hash-rate)
  # Using 14 threads for swaptions, leaving the cpuminer-iokerneld core (24) & its hyperthread (56)
  cmd="${CUR_PATH}/../shenango//scripts/cstate 0 &"
  run_command $cmd
  sleep 10

  if [ $# -eq 1 ]; then
    cmd="numactl -N 3 -m 3 -C 25-31,57,63 $swaptions_exec -ns 14 -sm 40000 -nt 14 > swaptions.out 2>&1 &"
    run_command $cmd
    sleep 10
  fi

#cmd="./cpuminer-orig -t 1 -a sha256d -o stratum+tcp://connect.pool.bitcoin.com:3333 -u 15dFNAbSnC7MngwHjoM2gZSuCEg5mmAEKc -p c=BTC > cpuminer-iokernel.frames.out 2>&1 &"
  cmd="numactl -N 3 -m 3 -C 24 ./cpuminer-orig -t 1 -a sha256d -o stratum+tcp://connect.pool.bitcoin.com:3333 -u 15dFNAbSnC7MngwHjoM2gZSuCEg5mmAEKc -p c=BTC > cpuminer-iokernel.frames.log 2>&1 &" # -N should come before -C option for numactl

  pushd $cpuminer_path
  pkill cpuminer

  run_command $cmd
  sleep 10

  #renice 0 -p `pgrep cpuminer`
  echo "cpuminer status: "
  ps -l `pgrep cpuminer`
  popd

  send_usr_sig_local 20
  send_usr_sig_local 20

  export do_not_kill_cpuminer=1

  # run other applications with cpuminer
  if [ $# -eq 0 ]; then
    pwd
    run_iokernel_preload 0
    sleep 10

    send_usr_sig_local 20
    send_usr_sig_local 20

    run_shenango_swaptions
    sleep 10

    send_usr_sig_local 20
    send_usr_sig_local 20

    run_shenango_memcached
    sleep 10

    send_usr_sig_local 20
    send_usr_sig_local 20
  fi

  echo "cpuminer status:"
  ps -l `pgrep cpuminer`
  echo "iokerneld status:"
  ps -l `pgrep iokerneld`
  echo "swaptions status:"
  ps -l `pgrep swaptions`
  echo "memcached status:"
  ps -l `pgrep memcached`

  unset do_not_kill_cpuminer

#read -p "Started cpuminer?" ans

  send_int_sig_local "cpuminer"
  mkdir -p ${EXP_DIR}/orig_files/
  mv $cpuminer_path/cpuminer-hashrate ${EXP_DIR}/orig_files/cpuminer-orig.out 
  cat orig_files/cpuminer-orig.out

  kill_server
}

run_iokernel_preload() {
  create_shenango_env

  cmd=" mpstat 1 -N 0-3 -P 24-31,56-63 2>&1| ts %s > mpstat.frames.log &"; 
  run_command $cmd
  sleep 1
  cmd="${CUR_PATH}/../shenango/scripts/cstate 0 &"
  run_command $cmd
  sleep 1
  if [ $1 -eq 0 ]; then
    cmd="${CUR_PATH}/../shenango//iokerneld 2>&1 | ts %s > iokernel.frames.log &"
#cmd="perf record --call-graph=dwarf -o perf_iokernel ${CUR_PATH}/../shenango//iokerneld 2>&1 | ts %s > iokernel.frames.log &"
#perf probe -d probe_iokerneld:congestion
#cmd="perf probe -x ${CUR_PATH}/../shenango//iokerneld --add congestion=cores.c:753"
#run_command $cmd
    if [ $# -ne 2 ]; then
      run_command $cmd
      sleep 10
    else
      run_command $cmd
      sleep 10
#cmd="${CUR_PATH}/../shenango//iokerneld 2>&1 | ts %s"
#echo $cmd
#read -p "Started iokerneld? " ans
    fi
  else
    pushd ${CUR_PATH}/../../cpuminer-multi/
    # Names of the log files are used elsewhere. Do not change them without changing everywhere else.
    cmd="./cpuminer -t 1 -a sha256d -o stratum+tcp://connect.pool.bitcoin.com:3333 -u 15dFNAbSnC7MngwHjoM2gZSuCEg5mmAEKc -p c=BTC 2>&1 | ts %s > cpuminer-iokernel.frames.log &"
    if [ $# -ne 2 ]; then
      run_command $cmd
      sleep 10
    else
      echo $cmd
      read -p "Started cpuminer? " ans
    fi
    popd
  fi
}

run_shenango_swaptions() {
  cmd="numactl -N 3 -m 3 ${CUR_PATH}/../parsec/pkgs/apps/swaptions/inst/amd64-linux.gcc-shenango/bin/swaptions swaptions.config -ns 16 -sm 40000 -nt 16 2>&1 | ts %s > swaptions.out 2> swaptions.err &"
  run_command $cmd
}

run_shenango_memcached() {
  #sleep 5
  #read -p "Run memcached? " ans
  
  if [ 0 -eq 1 ]; then
    perf probe -d probe_memcached:force_preempt*
    perf probe -d probe_memcached:yield_*
    perf probe -d probe_memcached:test_probe*
    perf probe -d probe_memcached:schedule
    perf probe -x ${CUR_PATH}/../memcached/memcached --add force_preempt=sched.c:286
    perf probe -x ${CUR_PATH}/../memcached/memcached --add yield_first=memcached.c:5499
    perf probe -x ${CUR_PATH}/../memcached/memcached --add yield_second=memcached.c:5670
    perf probe -x ${CUR_PATH}/../memcached/memcached --add schedule=schedule
    perf probe -x ${CUR_PATH}/../memcached/memcached --add test_probe=memcached.c:7647

    perf record -e probe_memcached:yield_first -o first.data -aR sleep 5m &
    perf record -e probe_memcached:yield_second -o second.data -aR sleep 5m &
    perf record -e probe_memcached:force_preempt -o force_preempt.data -aR sleep 5m &
    perf record -e probe_memcached:schedule -o schedule.data -aR sleep 5m &
    perf record -e probe_memcached:test_probe -o test_probe.data -aR sleep 5m &
  fi
  cmd="numactl -N 3 -m 3 ${CUR_PATH}/../memcached/memcached memcached.config -t 12 -U 5215 -p 5215 -c 32768 -m 32000 -b 32768 -o hashpower=28,no_hashexpand,lru_crawler,lru_maintainer,idle_timeout=0 2>&1 | tee memcached.out &"
  echo $cmd
#read -p "ran it?" ans
#return
# cmd="numactl -N 3 -m 3 perf record -e probe_memcached:schedule -e probe_memcached:test_probe -e probe_memcached:force_preempt -e probe_memcached:force_preempt_1 -e probe_memcached:yield_first -e probe_memcached:yield_second --call-graph=dwarf -o perf_memcached ${CUR_PATH}/../memcached/memcached memcached.config -t 12 -U 5215 -p 5215 -c 32768 -m 32000 -b 32768 -o hashpower=28,no_hashexpand,lru_crawler,lru_maintainer,idle_timeout=0 2>&1 | tee memcached.out &"
#cmd="numactl -N 3 -m 3 perf record --call-graph=dwarf -o perf_memcached_new ${CUR_PATH}/../memcached/memcached memcached.config -t 12 -U 5215 -p 5215 -c 32768 -m 32000 -b 32768 -o hashpower=28,no_hashexpand,lru_crawler,lru_maintainer,idle_timeout=0 2>&1 | tee memcached.out &"
#echo $cmd
#read -p "Stalled." ans
  run_command $cmd
}

run_memcached_orig() {
  #sleep 5
  #read -p "Run memcached? " ans
  if [ $# -ne 0 ]; then
    memcached_path="${CUR_PATH}/../memcached-linux/memcached"
  else
    memcached_path="${CUR_PATH}/../../memcached/memcached-1.5.6/memcached"
    echo "The experiment with memcached downloaded from source is not supported here. Aborting."
    exit
  fi
  cmd="sudo -H -u ${USER_NAME} bash -c 'numactl -N 3 -m 3 $memcached_path -l 192.168.34.1 -t 16 -U 5215 -p 5215 -c 32768 -m 32000 -b 32768 -o hashpower=28,no_hashexpand,lru_crawler,lru_maintainer,idle_timeout=0 2>&1 | tee memcached.out' &"
  run_command $cmd
  cmd="sleep 10"
  run_command $cmd
  #cmd="renice -n -20 -p `pgrep memcached`"
  memc_pid=`pgrep memcached`
  cmd="ls /proc/$memc_pid/task | xargs renice -20"
  run_command $cmd
}

cpuminer_shenango_experiment()
{
#read -p "cpuminer_shenango_experiment needs to be fixed. The logs should be taken care of. The processing of data needs to be changed. Done yet?" ans
#intervals="500 1000 2000 5000 10000 20000"
  intervals="1000 2000 4000 8000 16000 32000 64000"
  CPUMINER_PATH="${CUR_PATH}/../../cpuminer-multi"

  if [ 0 -eq 1 ]; then
    echo "Building cpuminer for various CI intervals $intervals"
    pushd $CPUMINER_PATH
    intervals="$intervals" ./build_shenango.sh
    popd
  else
    #read -p "Are the cpuminer executables already compiled? " ans
    echo "The cpuminer executables should be compiled & available by now!!"
  fi

  kill_server

  for intv in $intervals; do
    echo "Running cpuminer-shenango (interval:$intv) with swaptions & memcached without data transfer"

    cmd="cp $CPUMINER_PATH/cpuminer-${intv} $CPUMINER_PATH/cpuminer"
    run_command $cmd

    run_iokernel_preload 1

    sleep 5
    start_time_cpuminer=`date +%s`
    sleep 20
    end_time_cpuminer=`date +%s`

    #send_usr_sig_local 20
    #send_usr_sig_local 20

    #read -p "Checked hashrate??" ans

    run_shenango_swaptions

    sleep 5
    start_time_swaptions=`date +%s`
    sleep 20
    end_time_swaptions=`date +%s`

    #send_usr_sig_local 20
    #send_usr_sig_local 20

    run_shenango_memcached

    sleep 5
    start_time_memcached=`date +%s`
    sleep 20
    end_time_memcached=`date +%s`

    #send_usr_sig_local 20
    #send_usr_sig_local 20

    sleep 5

    send_int_sig_local "cpuminer"

    outfile="cpuminer$intv-shenango.out"
    cmd="mv ../../cpuminer-multi/cpuminer-iokernel.frames.log $outfile"
    run_command $cmd

    echo -e "app_time\tstart_timestamp\tend_timestamp" | tee -ai $outfile
    echo -e "cpuminer_time\t$start_time_cpuminer\t$end_time_cpuminer" | tee -a $outfile
    echo -e "swaptions_time\t$start_time_swaptions\t$end_time_swaptions" | tee -a $outfile
    echo -e "memcached_time\t$start_time_memcached\t$end_time_memcached" | tee -a $outfile

    kill_server
  done
  unbind_dpdk_ports
}

run_server()
{
  echo "Running server"
  run_iokernel_preload $@

  run_shenango_swaptions

  cmd="sleep 10"; run_command $cmd

  run_shenango_memcached

  cmd="sleep 10"; run_command $cmd

  if [ $# -eq 2 ]; then
    read -p "done?? " ans
  fi

  #sleep 5
}

copy_files_after_process_over() {
  cpuminer_running=`pgrep cpuminer`
  iokerneld_running=`pgrep iokerneld` 
  memcached_running=`pgrep memcached` 
  swaptions_running=`pgrep swaptions` 

  #while [ ! -z "$cpuminer_running" ] || [ ! -z "$iokerneld_running" ] || 
  while [ ! -z "$memcached_running" ]
  do
    sleep 2
    memcached_running=`pgrep memcached` 
  done

  if [ $# -eq 0 ]; then
    copy_files "temporary"
  else
    copy_files $1
  fi
}

create_linux_client_env() {
  CURR_DIR=`pwd`
  SRC_DIR="$CURR_DIR/../shenango"

  cmd="$SRC_DIR/scripts/setup_machine.sh"
  run_command $cmd
  cmd="modprobe ixgbe"
  run_command $cmd

  unbind_dpdk_ports
}

send_usr_sig_local() {
  cpuminer_server=`pgrep -x cpuminer`
  if [ ! -z $cpuminer_server ]; then
    cmd="sleep $1"
    run_command $cmd
    pgrep -x cpuminer | awk '{print "sudo kill -s USR2 " $1 }' | sh
    echo "Sent user signal locally to cpuminer"
    #sudo bash
  fi
}

send_int_sig_local() {
  app=$1
  pgrep -x $app | awk '{print "sudo kill -s INT " $1}' | sh
  echo "Sent int signal to $app"
}

#send_usr_sig() {
  #ssh ${USER_NAME}@frames "pgrep -x cpuminer | awk '{print \"sudo kill -s USR2 \" \$1}' | sh"
#sudo -H -u ${USER_NAME} ssh ${USER_NAME}@frames "pgrep -x cpuminer | awk '{print \"sudo kill -s USR2 \" \$1}' | sh"
#echo "Sent user signal to cpuminer"
  #sudo bash
#}

#send_kill_sig() {
#app=$1
  #su ${USER_NAME} 
  #ssh ${USER_NAME}@frames "pgrep -x cpuminer | awk '{print \"sudo kill -s USR1 \" \$1}' | sh"
#sudo -H -u ${USER_NAME} ssh ${USER_NAME}@frames "pgrep -x $app | awk '{print \"sudo kill -s KILL \" \$1}' | sh"
#echo "Sent kill signal to $app"
  #sudo bash
#}

#send_int_sig() {
#app=$1
  #ssh ${USER_NAME}@frames "pgrep -x cpuminer | awk '{print \"sudo kill -s USR1 \" \$1}' | sh"
#sudo -H -u ${USER_NAME} ssh ${USER_NAME}@frames "pgrep -x $app | awk '{print \"sudo kill -s INT \" \$1}' | sh"
#echo "Sent int signal to $app"
  #sudo bash
#}

run_client_for_orig()
{
  echo "Running client"
  BARRIER_LEADER_IP="10.193.34.70"
  server_name=`hostname`
  if [ "$server_name" == "cs-pages" ]; then
    server_name="pages"
    leader=$BARRIER_LEADER_IP
  elif [ "$server_name" == "lines" ]; then
    server_name="lines"
    leader="lines"
  else
    leader=$BARRIER_LEADER_IP
  fi

  if [ $# -lt 2 ]; then
    echo "Usage: run_client_for_orig <start mpps> <target mpps>"
    exit
  fi
  start_mpps="$1"
  mpps="$2"
  if [ $# -ge 3 ]; then
    samples=$3
  else
    samples=1
  fi
  echo "Run client with start: $start_mpps mpps, target: $mpps mpps"

  if [ $# -ge 4 ]; then
    SSHPASS="$4"
  fi
  create_shenango_env
  #read -p "Done??" ans

  threads=70
  runtime=60
  # copying latest executables 
  cmd="cp ../shenango/apps/synthetic/target/release/synthetic ."
  run_command $cmd
  cmd="sudo ${CUR_PATH}/../../shenango-${server_name}/shenango//iokerneld 2>&1 | ts %s > iokernel.$server_name.log &"
  run_command $cmd

#echo $cmd
#read -p "Started iokerneld? " ans
  cmd="sleep 5"
  run_command $cmd

#send_usr_sig
#send_usr_sig
  echo -n "IOKernel PID: "
  pgrep iokerneld

  if [ $# -lt 5 ]; then
    SSHPASS="$4"
    server=`hostname`
    cmd="export RUST_BACKTRACE=full; time numactl -N 0 -m 0 ./synthetic --config $server_name.memcached.config 192.168.34.1:5215 --warmup --output=buckets --protocol memcached --mode runtime-client --threads $threads --runtime $runtime --barrier-peers 1 --barrier-leader $server --mean=842 --distribution=zero --mpps=$mpps --samples=$samples --transport tcp --start_mpps=$start_mpps | tee $server_name.memcached.out 2>$server_name.memcached.err"
  else
    cmd="export RUST_BACKTRACE=full; time numactl -N 0 -m 0 ./synthetic --config $server_name.memcached.config 192.168.34.1:5215 --warmup --output=buckets --protocol memcached --mode runtime-client --threads $threads --runtime $runtime --barrier-peers 2 --barrier-leader $leader --mean=842 --distribution=zero --mpps=$mpps --samples=$samples --transport tcp --start_mpps=$start_mpps | tee $server_name.memcached.out 2>$server_name.memcached.err"
  fi
  #echo $cmd
  #read -p "Started synthetic client? " ans
  run_command $cmd

  echo "Done with $server_name client!!!"

#send_int_sig "memcached"
#send_kill_sig "swaptions"
  pkill iokerneld
  pkill cstate
  pkill mpstat
  pkill synthetic
}

run_client()
{
  echo "Running client"
  BARRIER_LEADER_IP="10.193.34.70"
  server_name=`hostname`
  if [ "$server_name" == "cs-pages" ]; then
    server_name="pages"
    leader=$BARRIER_LEADER_IP
  elif [ "$server_name" == "lines" ]; then
    server_name="lines"
    leader="lines"
  else
    leader=$BARRIER_LEADER_IP
  fi

  if [ $# -lt 2 ]; then
    echo "Usage: run_client <start mpps> <target mpps>"
    exit
  fi
  start_mpps="$1"
  mpps="$2"
  if [ $# -ge 3 ]; then
    samples=$3
  else
    samples=1
  fi
  echo "Run client with start: $start_mpps mpps, target: $mpps mpps"

  if [ $# -ge 4 ]; then
    SSHPASS="$4"
  fi
  cpuminer_server=`sudo -H -u ${USER_NAME} ssh ${USER_NAME}@frames "pgrep -x cpuminer"`

  if [ ! -z $cpuminer_server ]; then
    if [ 1 -eq 0 ]; then
      sleeptime="60"
      echo "Sleeping for ${sleeptime}s for adequate hashrate computation before starting client"
      sleep ${sleeptime}
    fi
  fi

  create_shenango_env
  #read -p "Done??" ans

  threads=70
  runtime=60
  # copying latest executables 
  cmd="cp ../shenango/apps/synthetic/target/release/synthetic ."
  run_command $cmd
  cmd="sudo ${CUR_PATH}/../../shenango-${server_name}/shenango//iokerneld 2>&1 | ts %s > iokernel.$server_name.log &"
  #echo $cmd
  #read -p "Started iokerneld? " ans
  run_command $cmd
  cmd="sleep 5"
  run_command $cmd

  #send_usr_sig
  #send_usr_sig
  echo -n "IOKernel PID: "
  pgrep iokerneld

  if [ $# -lt 5 ]; then
    SSHPASS="$4"
    server=`hostname`
    cmd="export RUST_BACKTRACE=full; time numactl -N 0 -m 0 ./synthetic --config $server_name.memcached.config 192.168.34.100:5215 --warmup --output=buckets --protocol memcached --mode runtime-client --threads $threads --runtime $runtime --barrier-peers 1 --barrier-leader $server --mean=842 --distribution=zero --mpps=$mpps --samples=$samples --transport tcp --start_mpps=$start_mpps | tee $server_name.memcached.out 2>$server_name.memcached.err"
  else
    cmd="export RUST_BACKTRACE=full; time numactl -N 0 -m 0 ./synthetic --config $server_name.memcached.config 192.168.34.100:5215 --warmup --output=buckets --protocol memcached --mode runtime-client --threads $threads --runtime $runtime --barrier-peers 2 --barrier-leader $leader --mean=842 --distribution=zero --mpps=$mpps --samples=$samples --transport tcp --start_mpps=$start_mpps | tee $server_name.memcached.out 2>$server_name.memcached.err"
  fi
  echo $cmd
  #read -p "Started synthetic client? " ans
  run_command $cmd
  #send_usr_sig

  if [ ! -z $cpuminer_server ]; then
    if [ 1 -eq 0 ]; then
      sleeptime="60"
      echo "Sleeping for ${sleeptime}s for adequate hashrate computation"
      sleep ${sleeptime}
      send_usr_sig
      sleeptime="120"
      echo "Sleeping for ${sleeptime}s for adequate hashrate computation"
      sleep ${sleeptime}
      #send_usr_sig # for multiple clients, this signal should be sent from the server script
    fi
  fi

  echo "Done with $server_name client!!!"

  #send_int_sig "swaptions"
  #send_int_sig "memcached"
  #send_int_sig "cpuminer"
  #send_int_sig "iokerneld"
  pkill iokerneld
  pkill cstate
  pkill mpstat
  pkill synthetic

#kill_server
}

run_observer()
{
  echo "Running observer"
  pkill rstat
  pkill go
  cmd="cp ../shenango/scripts/rstat.go ."
  run_command $cmd
  cmd="sudo arp -d 192.168.34.100 || true; go run rstat.go 192.168.34.100 1 | ts %s > rstat.memcached.log 2>&1 &"
  run_command $cmd
  cmd="sudo arp -d 192.168.34.101 || true; go run rstat.go 192.168.34.101 1 | ts %s > rstat.swaptions.log 2>&1 &"
  run_command $cmd
  cmd="sudo arp -d 192.168.34.102 || true; go run rstat.go 192.168.34.102 1 | ts %s > rstat.synthetic.log 2>&1 &"
  run_command $cmd
  #sudo arp -d 192.168.34.102 || true; go run rstat.go 192.168.34.102 1 | ts %s > rstat.0-lines.memcached.log
}

run_remote_client_deprecated()
{
  echo "Running remote client"
  parallel  "ssh ${USER_NAME}@{}.cs.uic.edu 'mkdir -p $CURR_DIR/scripts-{}'" ::: lines frames
  parallel  "scp experiment.py ${USER_NAME}@{}.cs.uic.edu:$CURR_DIR/scripts-{}/" ::: lines frames
  parallel  "scp $CURR_DIR/shenango/apps/synthetic/target/release/synthetic ${USER_NAME}@{}.cs.uic.edu:$CURR_DIR/scripts-{}/" ::: lines frames
  parallel  "scp $CURR_DIR/config.json ${USER_NAME}@{}.cs.uic.edu:$CURR_DIR/scripts-{}/" ::: lines frames
  parallel  "scp $CURR_DIR/shenango/scripts/rstat.go ${USER_NAME}@{}.cs.uic.edu:$CURR_DIR/scripts-{}/" ::: lines frames

  echo "Starting client on lines"
  parallel --halt now,fail=1 "ssh ${USER_NAME}@{}.cs.uic.edu 'ulimit -S -c unlimited; python $CURR_DIR/scripts-{}/experiment.py client $CURR_DIR/scripts-{} > $CURR_DIR/scripts-{}/py.{}.log 2>&1'" ::: lines

  echo "Starting local observer"
  python scripts/experiment.py observer scripts/ > ./py.frames.log 2>&1

  cp $CURR_DIR/scripts-lines/*.log $CURR_DIR/scripts-frames/
  cp $CURR_DIR/scripts-lines/*.out $CURR_DIR/scripts-frames/
  cp $CURR_DIR/scripts-lines/*.err $CURR_DIR/scripts-frames/
#rm -rf $CURR_DIR/scripts-lines
  #parallel "ssh ${USER_NAME}@{}.cs.uic.edu 'date +%s'" ::: lines frames
}

run_remote_client()
{
  if [ $# -lt 3 ]; then
    echo "Usage: run_remote_client <start mpps> <target mpps> <samples>"
    exit
  fi
  start_mpps=$1
  target_mpps=$2
  samples=$3
  client_opt=$4
#return

  if [ $# -lt 5 ]; then
    # run single client
    client="lines"
    #client="pages"
    echo "Running remote client $client with start mpps: $start_mpps, target mpps: $target_mpps, samples: $samples"
    sudo -H -u ${USER_NAME} ssh ${USER_NAME}@$client "cd ${CUR_PATH}/../../shenango-${client}/scripts; sudo ./experiments.sh $client_opt '$start_mpps' '$target_mpps' '$samples' '$SSHPASS'"
    sleep 5
  else
    # run multiple clients
    client="lines"
    echo "Running remote client $client with start mpps: $start_mpps, target mpps: $target_mpps, samples: $samples"
    sudo -H -u ${USER_NAME} ssh ${USER_NAME}@$client "cd ${CUR_PATH}/../../shenango-${client}/scripts; sudo ./experiments.sh $client_opt '$start_mpps' '$target_mpps' '$samples' '$SSHPASS' 1" &
    sleep 5

    client="pages"
    echo "Running remote client $client with start mpps: $start_mpps, target mpps: $target_mpps, samples: $samples"
    sudo -H -u ${USER_NAME} ssh ${USER_NAME}@$client "cd ${CUR_PATH}/../../shenango-${client}/scripts; sudo ./experiments.sh $client_opt '$start_mpps' '$target_mpps' '$samples' '$SSHPASS' 1"

#echo "Running remote client $client with start mpps: $start_mpps, target mpps: 0.5, samples: $samples"
#sudo -H -u ${USER_NAME} ssh ${USER_NAME}@$client "cd ${CUR_PATH}/../../shenango-${client}/scripts; sudo ./experiments.sh $client_opt '$start_mpps' '0.5' '$samples' '$SSHPASS' 1"
  fi

  echo "Done with clients"
#send_usr_sig_local 0 # send user signal to cpuminer after all clients are done

#sudo -H -u ${USER_NAME} ssh ${USER_NAME}@lines "cd ${CUR_PATH}/../../shenango-lines/scripts; sudo ./experiments.sh 3 '$start_mpps' '$target_mpps' '$samples' '$SSHPASS'"
}

copy_files() {
  DIR="$1"
  echo "Copying files to $DIR"
  cmd="rm -rf $DIR"
  run_command $cmd
  cmd="mkdir -p $DIR"
  run_command $cmd
  cmd="mv mpstat.frames.log $DIR"
  run_command_no_err $cmd
  cmd="mv iokernel.frames.log $DIR"
  run_command_no_err $cmd
  cmd="mv swaptions.out $DIR"
  run_command_no_err $cmd
  cmd="mv swaptions.err $DIR"
  run_command_no_err $cmd
  cmd="mv memcached.out $DIR"
  run_command_no_err $cmd
  cmd="mv ../../shenango-lines/scripts/iokernel.lines.log $DIR"
  run_command_no_err $cmd
  cmd="mv ../../shenango-lines/scripts/lines.memcached.out $DIR"
  run_command_no_err $cmd
  cmd="mv ../../shenango-lines/scripts/lines.memcached.err $DIR"
  run_command_no_err $cmd
  cmd="mv ../../shenango-pages/scripts/iokernel.pages.log $DIR"
  run_command_no_err $cmd
  cmd="mv ../../shenango-pages/scripts/pages.memcached.out $DIR"
  run_command_no_err $cmd
  cmd="mv ../../shenango-pages/scripts/pages.memcached.err $DIR"
  run_command_no_err $cmd
  cmd="mv ../../cpuminer-multi/cpuminer-iokernel.frames.log $DIR"
  run_command_no_err $cmd
  cmd="mv ../../cpuminer-multi/cpuminer-hashrate $DIR"
  run_command_no_err $cmd

  cmd="cp *stats.frames.* $DIR" # memcached runtime log
  run_command_no_err $cmd
  cmd="cp ../../shenango-lines/scripts/*stats.lines.* $DIR"
  run_command_no_err $cmd
  cmd="cp ../../shenango-pages/scripts/*stats.*pages.* $DIR"
  run_command_no_err $cmd
  cmd="cp experiments.sh $DIR" # memcached runtime log
  run_command $cmd
  #cmd="cp config.json $DIR" # memcached runtime log
  #run_command $cmd
  cmd="cp *.config $DIR" # memcached runtime log
  run_command $cmd

  cpuminer_pid=`pgrep cpuminer`
  echo "CPU miner pid: $cpuminer_pid"
}

run_experiment_combined() {
  # runs experiment for different throughput using one run of the client
  if [ $# -ne 1 ]; then
    echo "Usage: run_experiment_combined <0:standalone server/1:cpuminer server>"
    exit
  fi
  date_at_start=`date`

  total_points=1
  start_point="0.0"
  end_point="1.5"
  samples=15
  curr=$start_point
  i=0

  for i in $(seq 1 $total_points); do
    #target=`echo "$curr 0.1" | awk '{printf "%.1f\n", $1 + $2}'`
    target=$i
    if [ $1 -eq 0 ]; then
      dir="${EXP_DIR}/standalone/$target"
      echo "Running experiment for client with standalone iokernel, start_mpps $start_point, target_mpps $end_point, samples: $samples"
    else
      dir="${EXP_DIR}/cpuminer/$target"
      echo "Running experiment for client with cpuminer based iokernel, start_mpps $start_point, target_mpps $end_point, samples: $samples"
    fi
    run_server $1
    sleep 5

    #run_remote_client $curr $target
    run_remote_client $start_point $end_point $samples 3
    
    pkill swaptions
    send_int_sig_local "memcached"
    send_int_sig_local "cpuminer"
    send_int_sig_local "iokerneld"
    sleep 5

    copy_files_after_process_over $dir
    lines_out=`grep "Latencies" "$DIR/lines.memcached.out"`
    pages_out=`grep "Latencies" "$DIR/pages.memcached.out"`
    if [ -z "$lines_out" ]; then
      printf "${RED}Lines-based client failed to complete for target $target mpps for combined experiment${NC}\n" | tee -a $ERROR_LOG
    fi
    if [ -z "$pages_out" ]; then
      printf "${RED}Pages-based client failed to complete for target $target mpps for combined experiment${NC}\n" | tee -a $ERROR_LOG
    fi
  done
  date_at_end=`date`
  echo "Start time: $date_at_start"
  echo "End time: $date_at_end"
  kill_server
}

run_experiment_orig() {
  # runs experiment for each throughput using a separate run of the client
  date_at_start=`date`

  kill_server
  create_linux_server_env

  cmd="${CUR_PATH}/../shenango//scripts/cstate 0 &"
  run_command $cmd

  if [ $1 -eq 1 ]; then
    # program takes unreasonable time to finish creating outliers, for more than 0.7 bidirectional load (in million requests/sec)
    total_points=10
  else
    total_points=16
  fi
  start_point="0.0"
  samples=1
  curr=$start_point
#start_point="0.0"
#total_points=1
#curr="1.4"
  i=0

  for i in $(seq 1 $total_points); do
    if [ "$curr" == "0.0" ]; then
      target="0.01"
    elif [ "$curr" == "0.01" ]; then 
      target="0.025"
    elif [ "$curr" == "0.025" ]; then 
      target="0.05"
    elif [ "$curr" == "0.05" ]; then 
      target="0.075"
    elif [ "$curr" == "0.075" ]; then 
      target="0.1"
    else
      #target=`echo "$curr 0.1" | awk '{printf "%.1f\n", $1 + $2}'`
      target=`echo "$curr 0.05" | awk '{printf "%.2f\n", $1 + $2}'`
    fi

    if [ $1 -eq 0 ]; then
      dir="${EXP_DIR}/pthread-memcached/$target"
    elif [ $1 -eq 1 ]; then
      dir="${EXP_DIR}/pthread-memcached-swaptions/$target"
    else
      dir="${EXP_DIR}/pthread-memcached-1.5.6/$target"
    fi
    echo "Running experiment for client with pthread for directory $dir, start_mpps $start_point, target_mpps $target, samples: $samples"

    if [ $1 -eq 1 ]; then
      swaptions_exec="${CUR_PATH}/../parsec/pkgs/apps/swaptions/inst/amd64-linux.gcc-pthreads/bin/swaptions"
      cmd="numactl -N 3 -m 3 $swaptions_exec -ns 16 -sm 40000 -nt 16 2>&1 | ts %s > swaptions.out &"
      run_command $cmd
      while [ -z `pgrep swaptions` ]; do
        echo "Waiting for swaptions to start!"
        sleep 2
      done
      #cmd="chrt -i -p `pgrep swaptions`"
      #cmd="renice -n 19 -p `pgrep swaptions`"
      memc_pid=`pgrep swaptions`
      cmd="ls /proc/$memc_pid/task | xargs renice 19"
      run_command $cmd
      cmd="sleep 10"
      run_command $cmd
    fi

    run_memcached_orig $1

    #run_remote_client $curr $target
    run_remote_client $start_point $target $samples 16 1
    
    pkill swaptions
    send_int_sig_local "memcached"
    send_int_sig_local "cpuminer"
    send_int_sig_local "iokerneld"

    swaptions_running=`pgrep swaptions` 
    while [ ! -z $swaptions_running ]; do
      sleep 2
      echo "Waiting for swaptions to die."
      swaptions_running=`pgrep swaptions` 
    done

    copy_files_after_process_over $dir
    lines_out=`grep "Latencies" "$DIR/lines.memcached.out"`
    pages_out=`grep "Latencies" "$DIR/pages.memcached.out"`
    if [ -z "$lines_out" ]; then
      printf "${RED}Lines-based client failed to complete for target $target mpps for experiments with pthread based memcached${NC}\n" | tee -a $ERROR_LOG
    fi
    if [ -z "$pages_out" ]; then
      printf "${RED}Pages-based client failed to complete for target $target mpps for experiments with pthread based memcached${NC}\n" | tee -a $ERROR_LOG
    fi
    curr=$target
  done
  date_at_end=`date`
  echo "Start time: $date_at_start"
  echo "End time: $date_at_end"
  kill_server
}

run_experiment_over_ci() {
#intervals="500 1000 2000 5000 10000 20000"
#intervals="1000 2000 4000 8000 16000 32000 64000"
  intervals="8000 4000 16000 2000 32000 1000 64000"
  CPUMINER_PATH="${CUR_PATH}/../../cpuminer-multi"

  if [ 0 -eq 1 ]; then
    echo "Building cpuminer for various CI intervals $intervals"
    pushd $CPUMINER_PATH
    intervals="$intervals" ./build_shenango.sh
    popd
  else
#read -p "Are the cpuminer executables already compiled? " ans
    echo "The cpuminer executables should be compiled & available by now!!"
  fi
#run_experiment 1

  for intv in $intervals; do
    echo "Running experiment for CI Interval $intv"

    date_at_start=`date`
    total_points=16
    start_point="0.0"
    samples=1
    curr=$start_point

#total_points=6
#curr="0.9"

    i=0

    for i in $(seq 1 $total_points); do
      if [ "$curr" == "0.0" ]; then
        target="0.01"
      elif [ "$curr" == "0.01" ]; then 
        target="0.1"
      else
        #target=`echo "$curr 0.1" | awk '{printf "%.1f\n", $1 + $2}'`
        target=`echo "$curr 0.1" | awk '{printf "%.1f\n", $1 + $2}'`
      fi

      dir="${EXP_DIR}/cpuminer${intv}/$target"
      echo "Running experiment for client with cpuminer based iokernel, start_mpps $start_point, target_mpps $target, samples: $samples"

      cmd="cp $CPUMINER_PATH/cpuminer-${intv} $CPUMINER_PATH/cpuminer"
      run_command $cmd
      run_server 1

      sleep 5

      #run_remote_client $curr $target
      #run_remote_client $start_point $target $samples 3 # run single client
      run_remote_client $start_point $target $samples 3 1 # run multiple client
    
      pkill swaptions
      send_int_sig_local "memcached"
      send_int_sig_local "cpuminer"
      send_int_sig_local "iokerneld"
      sleep 5
      
      copy_files_after_process_over $dir
      lines_out=`grep "Latencies" "$DIR/lines.memcached.out"`
      pages_out=`grep "Latencies" "$DIR/pages.memcached.out"`
      if [ -z "$lines_out" ]; then
        printf "${RED}Lines-based client failed to complete for target $target mpps for experiments with cpuminer-iokernel based memcached${NC}\n" | tee -a $ERROR_LOG
      fi
      if [ -z "$pages_out" ]; then
        printf "${RED}Pages-based client failed to complete for target $target mpps for experiments with cpuminer-iokernel based memcached${NC}\n" | tee -a $ERROR_LOG
      fi
      curr=$target
    done
    date_at_end=`date`
    echo "Start time: $date_at_start"
    echo "End time: $date_at_end"
  done
  kill_server
}

run_experiment() {

  # runs experiment for each throughput using a separate run of the client
  if [ $# -ne 1 ]; then
    echo "Usage: run_experiment <0:standalone server/1:cpuminer server>"
    exit
  fi

  date_at_start=`date`
  total_points=16
  start_point="0.0"
  samples=1
  curr=$start_point
  intv=""

#total_points=1
#curr="1.1"

  i=0
  for i in $(seq 1 $total_points); do
    if [ "$curr" == "0.0" ]; then
      target="0.01"
    elif [ "$curr" == "0.01" ]; then 
      target="0.1"
    else
      #target=`echo "$curr 0.1" | awk '{printf "%.1f\n", $1 + $2}'`
      target=`echo "$curr 0.1" | awk '{printf "%.1f\n", $1 + $2}'`
    fi
    if [ $1 -eq 0 ]; then
      dir="${EXP_DIR}/standalone/$target"
      echo "Running experiment for client with standalone iokernel, start_mpps $start_point, target_mpps $target, samples: $samples"
    else
      dir="${EXP_DIR}/cpuminer$intv/$target"
      echo "Running experiment for client with cpuminer based iokernel, start_mpps $start_point, target_mpps $target, samples: $samples"
    fi
    run_server $1

    sleep 5

    #run_remote_client $curr $target
    #run_remote_client $start_point $target $samples 3 # run single client
    run_remote_client $start_point $target $samples 3 1 # run multiple client
    
    pkill swaptions
    send_int_sig_local "memcached"
    send_int_sig_local "cpuminer"
    send_int_sig_local "iokerneld"

    copy_files_after_process_over $dir
    lines_out=`grep "Latencies" "$DIR/lines.memcached.out"`
    pages_out=`grep "Latencies" "$DIR/pages.memcached.out"`
    if [ -z "$lines_out" ]; then
      printf "${RED}Lines-based client failed to complete for target $target mpps for experiments with standalone iokernel based memcached${NC}\n" | tee -a $ERROR_LOG
    fi
    if [ -z "$pages_out" ]; then
      printf "${RED}Pages-based client failed to complete for target $target mpps for experiments with standalone iokernel based memcached${NC}\n" | tee -a $ERROR_LOG
    fi
    curr=$target
  done
  date_at_end=`date`
  echo "Start time: $date_at_start"
  echo "End time: $date_at_end"
  kill_server
}

swaptions_orig_experiment() {
  if [ $# -eq 0 ]; then
    run_swaptions_orig 0 # no ht
    sleep 5
    run_swaptions_orig 1 # ht no-single-node-pinning
    sleep 5
    run_swaptions_orig 2 # ht single node
    sleep 5
    run_swaptions_iokernel 0 # iokerneld
    sleep 5
    run_swaptions_iokernel 1 # cpuminer
    sleep 5
    run_swaptions_iokernel_memcached 0 # iokerneld-memcached
    sleep 5
    run_swaptions_iokernel_memcached 1 # cpuminer-memcached
  else
    case $1 in
    0) run_swaptions_orig 0 # no ht
      ;;
    1) run_swaptions_orig 1 # ht no-single-node-pinning
      ;;
    2) run_swaptions_orig 2 # ht single node
      ;;
    3) run_swaptions_iokernel 0 # iokerneld
      ;;
    4) run_swaptions_iokernel 1 # cpuminer
      ;;
    5) run_swaptions_iokernel_memcached 0 # iokerneld-memcached
      ;;
    6) run_swaptions_iokernel_memcached 1 # cpuminer-memcached
      ;;
    esac
  fi
}

swaptions_shenango_experiment() {
  if [ $# -eq 0 ]; then
    run_swaptions_shenango 0 # iokerneld
    sleep 5
    run_swaptions_shenango 1 # cpuminer
    sleep 5
    run_swaptions_shenango 2 # iokerneld-memcached
    sleep 5
    run_swaptions_shenango 3 # cpuminer-memcached
  else
    case $1 in
    0) run_swaptions_shenango 0 # iokerneld
      ;;
    1) run_swaptions_shenango 1 # cpuminer
      ;;
    2) run_swaptions_shenango 2 # iokerneld-memcached
      ;;
    3) run_swaptions_shenango 3 # cpuminer-memcached
      ;;
    esac
  fi
}

plot_shenango() {
  mkdir -p $PLOTS_DIR
  cp process_data.sh $EXP_DIR/
  cp plot_shenango_latency.gp plot_cpuminer_hashrate.gp $EXP_DIR/
  pushd $EXP_DIR
  dir_set="cpuminer1000 cpuminer16000 cpuminer2000 cpuminer32000 cpuminer4000	cpuminer64000 cpuminer8000 orig_files pthread-memcached pthread-memcached-swaptions standalone"
  for d in $dir_set; do
    if [ ! -d $d ]; then
      echo "$d is not found. Aborting."
    fi
  done
  ./process_data.sh
  mv *.pdf $PLOTS_DIR
  popd
}

build_shenango_iokernel() {
  iokernel_build_path=$CUR_PATH"/../"
  echo "Building iokerneld"
  pushd $iokernel_build_path
    ./build_all.sh
  popd
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

rm -f $ERROR_LOG

USER_NAME=`logname`

#top -b -n 1 -i -u '!${USER_NAME}'
#top -b -n 1 -i

#run_shenango_swaptions
#exit

if [ $# -eq 0 ]; then
  echo "Running entire set of experiments for shenango"
  cpuminer_orig_experiment # stock cpuminer's performance with other jobs running
  run_experiment 0 # for standalone-iokernel
  run_experiment_over_ci # for cpuminer-iokernel for different intervals of CI
  run_experiment_orig 0 # memcached (shenango's version) with pthreads
  run_experiment_orig 1 # memcached (shenango's version) with pthreads + swaptions 
  plot_shenango
else
  echo "Usage: ./experiments.sh <option: 0-kill the server, 1-run server, 2-run server with cpuminer, 3-run client, 4-create client env, 5-create server env, 6-copy stats files 7-create linux server env>"
  case $1 in
  0) kill_server;;
  1) run_server 0 # using shenango-iokerneld
     #run_server 0 1 # for debug mode where iokernel runs in foreground
    ;;

  2) run_server 1 1;; # using cpuminer-iokerneld
  3) run_client ${@:2};;
  4) unbind_dpdk_ports;;
  5) create_shenango_env;;
  6) if [ $# -ne 2 ]; then
      echo "Usage: ./experiments.sh 6 <name of directory (e.g. 1mpps)>"
      exit
     fi
    copy_files $2
    ;;
  7) cpuminer_shenango_experiment
    ;;
  8) run_observer;;
  9) run_experiment_combined ${@:2}
    ;;
  10) run_experiment ${@:2}
    ;;
  11) swaptions_orig_experiment # swaptions-orig with other apps; 0-6 for individual types
    ;;
  12) swaptions_shenango_experiment # swaptions-shenango with other apps; 0-3 for individual types
    ;;
  13) cpuminer_orig_experiment # run cpuminer-orig with iokerneld & swaptions & memcached separately
      #cpuminer_orig_experiment 1 # run cpuminer-orig alone
    ;;
  14) run_experiment_over_ci
    ;;
  15) 
    run_experiment_orig 0 # schenango's version of memcached
    run_experiment_orig 1 # schenango's version of memcached + swaptions 
    #run_experiment_orig 2 # original memcached
    ;;
  16) run_client_for_orig ${@:2}
    ;;
  17) create_linux_server_env; sleep 5
      run_memcached_orig
    ;;
  18) create_linux_client_env
    ;;
  19) plot_shenango
    ;;
  *)
    # full set
    cpuminer_orig_experiment
    run_experiment 0 # for standalone-iokernel
    run_experiment_over_ci # for cpuminer-iokernel for different intervals of CI
    run_experiment_orig 0 # memcached (shenango's version) with pthreads
    run_experiment_orig 1 # memcached (shenango's version) with pthreads + swaptions 
    ;;
  esac
fi

#kill_server
#unbind_dpdk_ports
