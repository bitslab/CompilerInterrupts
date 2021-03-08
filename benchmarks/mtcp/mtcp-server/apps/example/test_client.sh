#!/bin/bash

print_avg() {
  out_file="out_log_${CONCURRENCY}_m$mode"
  echo -n "Average latency over $RUNS runs ($REQUESTS requests, $THREADS threads, $CONCURRENCY concurrency): "
#echo -n "$REQUESTS,$CONCURRENCY," >> $STAT_LOG
  echo -n "$CONCURRENCY " >> $STAT_LOG

  # latency: field 17 - #completes, field 20 - avg response time
  gawk 'BEGIN {sum_prod=0; sum_num=0} /connect:/ {avgi=(substr($20, 1, length($20)-1)); num=$17; prod=avgi*num; sum_num+=num; sum_prod+=prod;} END {avg=sum_prod/sum_num; printf("%0.2f ", avg);}' $out_file | tee -a $STAT_LOG

  # rx throughput
  awk 'BEGIN {sum=0;num=0} /connect:/ {sum+=(substr($26, 1, length($26)-1)); num+=1;} END {avg=sum/num; printf("%0.2f ", avg);}' $out_file | tee -a $STAT_LOG

  # runtime
  awk 'BEGIN {sum=0;num=0} /Program/ {sum+=$4; num+=1} END {avg=sum/num; printf("%d ", avg)}' $out_file | tee -a $STAT_LOG

  # errors & incompletes
  awk 'BEGIN {num_err=0; num_incomplete=0} /connect:/ {num_err+=$13; num_incomplete+=$15} END {printf("%d %d ",num_err,num_incomplete)}' $out_file | tee -a $STAT_LOG

  # Total size read: field 7 - #read
  awk 'BEGIN {sum=0;num=0} /connect:/ {sum+=$7; num+=1} END {avg=sum/num; printf("%d ", avg)}' $out_file | tee -a $STAT_LOG

  # Total requests configured for the experiment
  echo -n "$REQUESTS" | tee -a $STAT_LOG

  # Cumulative bandwidth averaged over time: field 11 - #RxTh, field 14 - #TxTh
  gawk 'BEGIN {countrx=0;counttx=0;sumgbrx=0;sumgbtx=0} /flows/ {
    rx=$11; avggbrx=(substr(rx, 1, length(rx)-7)); sumgbrx+=avggbrx; if((avggbrx+0) != 0) countrx++; 
    tx=$14; avggbtx=(substr(tx, 1, length(tx)-6)); sumgbtx+=avggbtx; if((avggbtx+0) != 0) counttx++;}
  END {avgrx=sumgbrx/countrx;avgtx=sumgbtx/counttx; printf(" %0.2f %0.2f\n",avgrx,avgtx);}' $out_file | tee -a $STAT_LOG
#print rx, countrx, avggbrx, sumgbrx, tx, counttx, avggbtx, sumgbtx};
}

run_client_for_conc() {
  out_file="out_log_${CONCURRENCY}_m$mode"
  rm -f out $out_file
  for i in `seq 1 $RUNS`; do
    echo "Run $i with $REQUESTS requests, $THREADS threads, $CONCURRENCY concurrency:-"
    cmd="time ./epwget $server_ip/test_big.txt $REQUESTS -N $THREADS -c $CONCURRENCY -f ${client}_epwget.conf 2>&1 | tee out"
    cmd="time ./epwget $server_ip/test.txt $REQUESTS -N $THREADS -c $CONCURRENCY -f ${client}_epwget.conf 2>&1 | tee out"
    cmd="time ./epwget $server_ip/NOTES_10kb $REQUESTS -N $THREADS -c $CONCURRENCY -f ${client}_epwget.conf 2>&1 | tee out"
    cmd="time ./epwget $server_ip/NOTES_64B $REQUESTS -N $THREADS -c $CONCURRENCY -f ${client}_epwget.conf 2>&1 | tee out"
    cmd="time timeout 5m ./epwget $server_ip/NOTES $REQUESTS -N $THREADS -c $CONCURRENCY -f ${client}_epwget.conf 2>&1 | tee out"
#cmd="time ./epwget $server_ip/NOTES $REQUESTS -N $THREADS -c $CONCURRENCY -f ${client}_epwget.conf | tee out"
#cmd="time ./epwget $server_ip/NOTES $REQUESTS -N $THREADS -c $CONCURRENCY -f ${client}_epwget.conf > out 2>err"
    echo $cmd
    eval $cmd
    grep -w "ALL\|Program" out >> $out_file
    mv out debug_log_${CONCURRENCY}_m$mode # for logs for last run
  done
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

build_client() {
  echo "Building client for version 0 & type 1"
  curr_path=`pwd`
  cd ../../
  #./build.sh $vrsn $type
  #./build.sh $vrsn 1 # do not allow modified code on the client side
  ./build.sh 0 1 # use orig client always, do not allow modified code on the client side
  cd $curr_path
}

build_server() {
  echo "Building server for version $vrsn & type $type"
  build_str="cd $server_path; ./build.sh $vrsn $type"
  #echo "Build string: $build_str"
  sshpass -e ssh ${USERNAME}@$server "$build_str" 
  #sshpass -e ssh ${USERNAME}@$server "$build_str &" 
}

run_server() {
  echo "Running server for version $vrsn & type $type"
  run_str="cd $server_app_path; sudo nohup ./test_server.sh"
  echo $run_str
  sshpass -e ssh ${USERNAME}@$server "$run_str" &

  sleep_time=15
  echo "Will sleep for $sleep_time sec for server to start running"
  sleep $sleep_time
}

run_client() {
  echo -e "Concurrency\tLatency(us)\tRxTh(Mbps)\tRuntime\t#Errors\t#Incompletes\tReadSize(MB)\tRequests\tDPDKRxTh\tDPDKTxTh" | tee $STAT_LOG
  for conc in $CONCURRENCIES;do
    echo "Running clients for concurrency: $conc"
    CONCURRENCY=$conc run_client_for_conc
    CONCURRENCY=$conc print_avg
  done
  kill_existing_server
  sleep 3
}

run_experiment() {
  kill_existing_server
  build_server
  build_client
  #sleep 3 # to allow the server build running in background to finish
  run_server
  run_client
  kill_existing_server
}

#echo "Usage: ./test_client.sh <opt: #requests> <opt: #cores> <opt: #concurrency>"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
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

CUR_PATH=`pwd`
export RTE_TARGET="x86_64-native-linuxapp-gcc"
export RTE_SDK=$CUR_PATH"/../../dpdk"

RUNS="${RUNS:-10}"
EXP_DIR="${CUR_PATH}/../../../exp_results/"
THREADS=16
echo "Running mtcp experiment for $RUNS runs & results will be exported in $EXP_DIR"

client=`hostname`
cur_path=`pwd`
if [ "$client" == "lines" ]; then
  server="frames"
  server_ip="131.193.34.60"
  server_path="$cur_path/../../../mtcp-server/"
elif [ "$client" == "quads2" ]; then
  server="quads1"
  server_ip="192.168.1.1"
  server_path="$cur_path/../../../mtcp-mellanox-server/"
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

server_app_path="$server_path/apps/example"

pushd ../../../
# binding dpdk-ports at client
./setup.sh 1
if [ $? -ne 0 ]; then 
  echo "Could not bind dpdk ports!"
  exit
fi
# binding dpdk-ports at server
run_str="cd $server_app_path/../../../; sudo ./setup.sh 1"
sshpass -e ssh ${USERNAME}@$server "$run_str"
popd

# Parse cmd line parameters
if [ $# -eq 1 ]; then
  REQUESTS=$1
elif [ $# -eq 2 ]; then
  REQUESTS=$1
  THREADS=$2
elif [ $# -eq 3 ]; then
  REQUESTS=$1
  THREADS=$2
  CONCURRENCIES=$3
fi

MODES="2 3 0 1" # 0 - orig mod, 1 - ci mod, 2 - orig unmod, 3 - ci unmod
CONCURRENCIES="16 32 64 128 256 512"
for mode in $MODES; do
  if [ "$client" == "lines" ]; then
    # for ixgbe
    case $mode in
    0)
      REQUESTS=20000 # starts dropping packets & getting errors beyond this
      type_str="orig_mod"
    ;;
    1)
      REQUESTS=100000
      type_str="ci_mod"
    ;;
    2)
      REQUESTS=5000000
      type_str="orig_unmod"
    ;;
    3)
      REQUESTS=5000000
      type_str="ci_unmod"
    ;;
    esac
  else
    # for mellanox
    case $mode in
    0)
      REQUESTS=100000
      type_str="orig_mod"
    ;;
    1)
      REQUESTS=100000
      type_str="ci_mod"
    ;;
    2)
      REQUESTS=50000000
      type_str="orig_unmod"
    ;;
    3)
      REQUESTS=50000000
      type_str="ci_unmod"
    ;;
    esac
  fi
  STAT_LOG="all_log_$type_str"
  STAT_LOG_BACK="backup_all_log_$type_str"
  mv $STAT_LOG $STAT_LOG_BACK

  # orig modes or ci mode
  if [ $mode -eq 0 ] || [ $mode -eq 2 ]; then
    echo -n "Running non-CI-mtcp app "
    vrsn=0
  else
    echo -n "Running CI-mtcp app "
    vrsn=1
  fi
  # unmod or mod
  if [ $mode -eq 0 ] || [ $mode -eq 1 ]; then
    echo "in modified form"
    type=0
  else
    echo "in unmodified form"
    type=1
  fi
  run_experiment
  cp $STAT_LOG $EXP_DIR
done

pushd ../../../
# unbinding dpdk-ports at client
./setup.sh 0
if [ $? -ne 0 ]; then 
  echo "Could not unbind dpdk ports!"
  exit
fi
# unbinding dpdk-ports at server
run_str="cd $server_app_path/../../../; sudo ./setup.sh 0"
sshpass -e ssh ${USERNAME}@$server "$run_str"
popd
