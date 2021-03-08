#!/bin/bash

print_avg() {
  #conc
  echo -n "$1 " | tee -a $STAT_LOG
  #latency
  awk 'BEGIN {sum=0;num=0} /connect:/ {loc_avg=(substr($16, 1, length($16)-1)); loc_num=$13; prod=loc_avg*loc_num; sum+=prod; num+=loc_num;} END {avg=sum/num; printf("%0.2f ", avg)}' $file | tee -a $STAT_LOG
  #rx th
#awk 'BEGIN {sum=0;num=0} /connect:/ {loc_avg=(substr($22, 1, length($22)-1)); loc_num=$13; prod=loc_avg*loc_num; sum+=prod; num+=loc_num;} END {avg=sum/num; printf("%d ", avg)}' $file | tee -a $STAT_LOG
  awk 'BEGIN {sum=0;num=0} /connect:/ {sum+=(substr($22, 1, length($22)-1)); num+=1;} END {avg=sum/num; printf("%0.2f ", avg)}' $file | tee -a $STAT_LOG
  #runtime
  awk 'BEGIN {sum=0;num=0} /Program/ {sum+=$4; num+=1} END {avg=sum/num; printf("%d ", avg)}' $file | tee -a $STAT_LOG
  #incompletes
  awk 'BEGIN {sum=0;num=0} /timeouts:/ {sum+=(substr($7, 1, length($7)-1)); num+=1;} END {avg=sum/num; printf("%d ", avg)}' $file | tee -a $STAT_LOG
  #errors
  awk 'BEGIN {sum=0;num=0} /timeouts:/ {sum+=(substr($9, 1, length($9)-1)); num+=1;} END {avg=sum/num; printf("%d ", avg)}' $file | tee -a $STAT_LOG

  # Total size read
  awk 'BEGIN {sum=0;num=0} /connect:/ {sum+=$7; num+=1} END {avg=sum/num; printf("%d ", avg)}' $file | tee -a $STAT_LOG

  echo "$REQUESTS" | tee -a $STAT_LOG
}

kill_existing_server() {
  # For precaution, kill any existing running process
  sshpass -e ssh ${USERNAME}@$server "pgrep -x epserver | awk '{print \"sudo kill -s KILL \" \$1}' | sh"
  #sshpass -e ssh ${USERNAME}@$server "pgrep -x epserver | awk '{print \"sudo kill -s INT \" \$1}' | sh"
  pid_present=`sshpass -e ssh ${USERNAME}@$server "pgrep -x epserver"`
  if [ ! -z $pid_present ]; then
    echo "Could not kill epserver. Exiting."
    exit
  fi
}

run_client() {
  rm -f tmp
  echo "Running server for mode $2, conc $1"
  for i in `seq 1 $RUNS`; do
    command="./epwget $server_ip/NOTES $REQUESTS -c $1 -N $THREADS > $file"
    echo $command
    sleep 5
    eval $command
    grep -e "connect:\|Program\|timeouts:" $file >> tmp
  done
  mv tmp $file
  print_avg $1
}

run_server() {
  echo "Running server for mode $1"
  run_str="cd $server_app_path; sudo nohup ./run_server.sh $THREADS"
  echo $run_str
  sshpass -e ssh ${USERNAME}@$server "$run_str" &
  sleep_time=15
  echo "Will sleep for $sleep_time sec for server to start running"
  sleep $sleep_time
}

build_server() {
  echo "Building server for mode $1"
  build_str="cd $server_app_path; sudo nohup ./build.sh $1"
  echo $build_str
  sshpass -e ssh ${USERNAME}@$server "$build_str"
}

build_client() {
  echo "Building client"
  make epwget-clean
  make epwget
}

if [ $# -ne 0 ]; then
  echo "Usage: ./run_client.sh"
  exit
fi

USERNAME=`logname`
if [ -z "$USERNAME" ]; then 
  echo "User name of sudo user is not found. Aborting."
  exit
fi

if [ -z "$SSHPASS" ]; then 
  echo "User $USERNAME's password is not set in SSHPASS variable. E.g. export SSHPASS=\"password\". Aborting."
  exit
fi

RUNS="${RUNS:-10}"
EXP_DIR="${PWD}/../exp_results/"
echo "Running mtcp experiment for $RUNS runs & results will be exported in $EXP_DIR"

client=`hostname`
if [ "$client" == "lines" ]; then
  server="frames"
  server_ip="131.193.34.60"
elif [ "$client" == "quads2" ]; then
  server="quads1"
  server_ip="192.168.1.1"
else
  echo "$client is not configured as an mtcp client!"
  exit
fi

sshpass -e ssh ${USERNAME}@${server} "pwd" > /dev/null
cmd_status=`echo $?`
if [ $cmd_status -ne 0 ]; then
  echo "Remote access to server $server is not setup for user $USERNAME. Aborting."
  exit
fi

# since they are on NFS
server_app_path=`pwd`

pushd ../
# unbinding dpdk-ports at client
./setup.sh 0
if [ $? -ne 0 ]; then 
  echo "Could not unbind dpdk ports!"
  exit
fi
# unbinding dpdk-ports at server
run_str="cd $server_app_path/../; sudo ./setup.sh 0"
sshpass -e ssh ${USERNAME}@$server "$run_str"
popd

CONCURRENCY="16 32 64 128 256 512"
MODES="0 1" # 0 - unmod, 1 - mod
THREADS=16

build_client

for mode in $MODES
do
  if [ $mode -eq 1 ]; then
    mode_str="mod"
    REQUESTS=100000
  else
    mode_str="unmod"
    REQUESTS=500000
  fi

  STAT_LOG="all_log_native_$mode_str"
  if [ "$client" == "quads2" ]; then
    STAT_LOG=$STAT_LOG"_mlx"
  fi
  echo -e "Concurrency\tLatency(us)\tRxTh(Mbps)\tRuntime(sec)\t#Errors\t#Incompletes\tReadSize(MB)\tRequests" | tee $STAT_LOG

  build_server $mode
  kill_existing_server
  run_server $mode_str

  for conc in $CONCURRENCY
  do

    file="out_${mode_str}_${conc}"
    if [ "$client" == "quads2" ]; then
      file=$file"_mlx"
    fi

    echo "Running for conc $conc with $REQUESTS requests"
    run_client $conc $mode_str # $3 - conc, $2 - mode string
  done
  kill_existing_server
  cp $STAT_LOG $EXP_DIR
done
