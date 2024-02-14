#!/usr/bin/bash

# Note: This script should run on the clinet host

SSHPASS="pwd"
TEST_CASE="name_of_test"

REPO_DIR_CLI="/home/path_of_COAT_repository" # path of COAT repository on client host
REPO_DIR_SRC="/home/path_of_COAT_repository" # path of COAT repository on on migration srouce host
REPO_DIR_DST="/home/path_of_COAT_repository" # path of COAT repository on on migration destination host

SRC_HOST="" # Migration source host name
DST_HOST=""  # Migration destination host name

initHeaderCSV_ckp () {
  echo "container_id,iter,podman_checkpoint_duration,runtime_checkpoint_duration,freezing_time,frozen_time,memdump_time,memwrite_time,pages_scanned,pages_written,filesize" > $1
}

initHeaderCSV_restore () {
  echo "container_id,iter,podman_restore_duration,runtime_restore_duration,forking_time,restore_time,pages_restored" > $1
}

initHeaderCSV_iperf () {
    echo "iter,packet_id,start,end,latency" > $1
}

initHeaderCSV_time () {
    echo "iter,scenario,elapsed,user,sys,CPU" > $1
}

initHeaderCSV_states () {
    echo "iter,container_id,memory_MB,CPU" > $1
}

fromJSONtoCSV_ckp () {
  container_id_t=$(sudo cat $1 | grep Id | awk '{print $2}' | sed 's/[^a-zA-Z0-9]//g')
  iter=$3
  podman_checkpoint_duration_t=$(sudo cat $1 | grep podman_checkpoint_duration | awk '{print $2}'| sed 's/[^0-9]*//g')
  runtime_checkpoint_duration_t=$(sudo cat $1 | grep runtime_checkpoint_duration | awk '{print $2}'| sed 's/[^0-9]*//g')
  freezing_time_t=$(sudo cat $1 | grep freezing_time | awk '{print $2}'| sed 's/[^0-9]*//g')
  frozen_time_t=$(sudo cat $1 | grep frozen_time | awk '{print $2}'| sed 's/[^0-9]*//g')
  memdump_time_t=$(sudo cat $1 | grep memdump_time | awk '{print $2}'| sed 's/[^0-9]*//g')
  memwrite_time_t=$(sudo cat $1 | grep memwrite_time | awk '{print $2}'| sed 's/[^0-9]*//g')
  pages_scanned_t=$(sudo cat $1 | grep pages_scanned | awk '{print $2}'| sed 's/[^0-9]*//g')
  pages_written_t=$(sudo cat $1 | grep pages_written | awk '{print $2}'| sed 's/[^0-9]*//g')
  filesize_t=$4
  echo "$container_id_t,$iter,$podman_checkpoint_duration_t,$runtime_checkpoint_duration_t,$freezing_time_t,$frozen_time_t,$memdump_time_t,$memwrite_time_t,$pages_scanned_t,$pages_written_t,$filesize_t" >> $2
}

fromJSONtoCSV_restore () {
  container_id_t=$(sudo cat $1 | grep Id | awk '{print $2}' | sed 's/[^a-zA-Z0-9]//g')
  size_t=$3
  podman_restore_duration_t=$(sudo cat $1 | grep podman_restore_duration | awk '{print $2}'| sed 's/[^0-9]*//g')
  runtime_restore_duration_t=$(sudo cat $1 | grep runtime_restore_duration | awk '{print $2}'| sed 's/[^0-9]*//g')
  forking_time_t=$(sudo cat $1 | grep forking_time | awk '{print $2}'| sed 's/[^0-9]*//g')
  restore_time_t=$(sudo cat $1 | grep restore_time | awk '{print $2}'| sed 's/[^0-9]*//g')
  pages_restored_t=$(sudo cat $1 | grep pages_restored | awk '{print $2}'| sed 's/[^0-9]*//g')
  echo "$container_id_t,$size_t,$podman_restore_duration_t,$runtime_restore_duration_t,$forking_time_t,$restore_time_t,$pages_restored_t" >> $2
}

fromTimeLogstoCSV () {
    ns_clear_elapsed=$(cat $REPO_DIR_CLI/logs/ns_clear.log | grep elapsed | awk '{print $1}' | sed 's/,/./')
    ns_clear_user=$(cat $REPO_DIR_CLI/logs/ns_clear.log | grep user | awk '{print $1}' | sed 's/,/./')
    ns_clear_sys=$(cat $REPO_DIR_CLI/logs/ns_clear.log | grep sys | awk '{print $1}' | sed 's/,/./')
    ns_clear_cpu=$(cat $REPO_DIR_CLI/logs/ns_clear.log | grep CPUs | awk '{print $5}' | sed 's/,/./')
    echo "$2,ns_clear,$ns_clear_elapsed,$ns_clear_user,$ns_clear_sys,$ns_clear_cpu" >> $1
    scp_ckpt_elapsed=$(cat $REPO_DIR_CLI/logs/scp_ckpt.log | grep elapsed | awk '{print $1}' | sed 's/,/./')
    scp_ckpt_user=$(cat $REPO_DIR_CLI/logs/scp_ckpt.log | grep user | awk '{print $1}' | sed 's/,/./')
    scp_ckpt_sys=$(cat $REPO_DIR_CLI/logs/scp_ckpt.log | grep sys | awk '{print $1}' | sed 's/,/./')
    scp_ckpt_cpu=$(cat $REPO_DIR_CLI/logs/scp_ckpt.log | grep CPUs | awk '{print $5}' | sed 's/,/./')
    echo "$2,scp_ckpt,$scp_ckpt_elapsed,$scp_ckpt_user,$scp_ckpt_sys,$scp_ckpt_cpu" >> $1
    create_ns_elapsed=$(cat $REPO_DIR_CLI/logs/create_ns.log | grep elapsed | awk '{print $1}' | sed 's/,/./')
    create_ns_user=$(cat $REPO_DIR_CLI/logs/create_ns.log | grep user | awk '{print $1}' | sed 's/,/./')
    create_ns_sys=$(cat $REPO_DIR_CLI/logs/create_ns.log | grep sys | awk '{print $1}' | sed 's/,/./')
    create_ns_cpu=$(cat $REPO_DIR_CLI/logs/create_ns.log | grep CPUs | awk '{print $5}' | sed 's/,/./')
    echo "$2,create_ns,$create_ns_elapsed,$create_ns_user,$create_ns_sys,$create_ns_cpu" >> $1
    clear_arp_elapsed=$(cat $REPO_DIR_CLI/logs/clear_arp.log | grep elapsed | awk '{print $1}' | sed 's/,/./')
    clear_arp_user=$(cat $REPO_DIR_CLI/logs/clear_arp.log | grep user | awk '{print $1}' | sed 's/,/./')
    clear_arp_sys=$(cat $REPO_DIR_CLI/logs/clear_arp.log | grep sys | awk '{print $1}' | sed 's/,/./')
    clear_arp_cpu=$(cat $REPO_DIR_CLI/logs/clear_arp.log | grep CPUs | awk '{print $5}' | sed 's/,/./')
    echo "$2,clear_arp,$clear_arp_elapsed,$clear_arp_user,$clear_arp_sys,$clear_arp_cpu" >> $1

    ns_clear_elapsed_real=$(cat $REPO_DIR_CLI/logs/ns_clear_real.log | grep elapsed | awk '{print $1}' | sed 's/,/./')
    ns_clear_user_real=$(cat $REPO_DIR_CLI/logs/ns_clear_real.log | grep user | awk '{print $1}' | sed 's/,/./')
    ns_clear_sys_real=$(cat $REPO_DIR_CLI/logs/ns_clear_real.log | grep sys | awk '{print $1}' | sed 's/,/./')
    ns_clear_cpu_real=$(cat $REPO_DIR_CLI/logs/ns_clear_real.log | grep CPUs | awk '{print $5}' | sed 's/,/./')
    echo "$2,ns_clear_real,$ns_clear_elapsed_real,$ns_clear_user_real,$ns_clear_sys_real,$ns_clear_cpu_real" >> $1
    scp_ckpt_elapsed_real=$(cat $REPO_DIR_CLI/logs/scp_real.log | grep elapsed | awk '{print $1}' | sed 's/,/./')
    scp_ckpt_user_real=$(cat $REPO_DIR_CLI/logs/scp_real.log | grep user | awk '{print $1}' | sed 's/,/./')
    scp_ckpt_sys_real=$(cat $REPO_DIR_CLI/logs/scp_real.log | grep sys | awk '{print $1}' | sed 's/,/./')
    scp_ckpt_cpu_real=$(cat $REPO_DIR_CLI/logs/scp_real.log | grep CPUs | awk '{print $5}' | sed 's/,/./')
    echo "$2,scp_ckpt_real,$scp_ckpt_elapsed_real,$scp_ckpt_user_real,$scp_ckpt_sys_real,$scp_ckpt_cpu_real" >> $1
    create_ns_elapsed_real=$(cat $REPO_DIR_CLI/logs/create_ns_real.log | grep elapsed | awk '{print $1}' | sed 's/,/./')
    create_ns_user_real=$(cat $REPO_DIR_CLI/logs/create_ns_real.log | grep user | awk '{print $1}' | sed 's/,/./')
    create_ns_sys_real=$(cat $REPO_DIR_CLI/logs/create_ns_real.log | grep sys | awk '{print $1}' | sed 's/,/./')
    create_ns_cpu_real=$(cat $REPO_DIR_CLI/logs/create_ns_real.log | grep CPUs | awk '{print $5}' | sed 's/,/./')
    echo "$2,create_ns_real,$create_ns_elapsed_real,$create_ns_user_real,$create_ns_sys_real,$create_ns_cpu_real" >> $1
    
    ckpt_elapsed=$(cat $REPO_DIR_CLI/logs/perf_ckpt.log | grep elapsed | awk '{print $1}' | sed 's/,/./')
    ckpt_user=$(cat $REPO_DIR_CLI/logs/perf_ckpt.log | grep user | awk '{print $1}' | sed 's/,/./')
    ckpt_sys=$(cat $REPO_DIR_CLI/logs/perf_ckpt.log | grep sys | awk '{print $1}' | sed 's/,/./')
    ckpt_cpu=$(cat $REPO_DIR_CLI/logs/perf_ckpt.log | grep CPUs | awk '{print $5}' | sed 's/,/./')
    echo "$2,perf_ckpt,$ckpt_elapsed,$ckpt_user,$ckpt_sys,$ckpt_cpu" >> $1
    rst_elapsed=$(cat $REPO_DIR_CLI/logs/perf_restore.log | grep elapsed | awk '{print $1}' | sed 's/,/./')
    rst_user=$(cat $REPO_DIR_CLI/logs/perf_restore.log | grep user | awk '{print $1}' | sed 's/,/./')
    rst_sys=$(cat $REPO_DIR_CLI/logs/perf_restore.log | grep sys | awk '{print $1}' | sed 's/,/./')
    rst_cpu=$(cat $REPO_DIR_CLI/logs/perf_restore.log | grep CPUs | awk '{print $5}' | sed 's/,/./')
    echo "$2,perf_restore,$rst_elapsed,$rst_user,$rst_sys,$rst_cpu" >> $1

}

fromStateLogstoCSV () {
    state_part1=$(sed -n 2p $REPO_DIR_CLI/logs/stats-container.log | awk '{print $1}' | sed 's/MB//')
    state_part2=$(sed -n 2p $REPO_DIR_CLI/logs/stats-container.log | awk '{print $3}' | sed 's/,/ /' | awk '{print $2}')
    echo "$2,$state_part1,$state_part2" >> $1
}


rm -rf ./log/$TEST_CASE
mkdir -p ./log/$TEST_CASE

initHeaderCSV_ckp ./log/$TEST_CASE/podman_dump.csv
initHeaderCSV_restore ./log/$TEST_CASE/podman_restore.csv
initHeaderCSV_iperf ./log/$TEST_CASE/sockperf.csv
initHeaderCSV_time ./log/$TEST_CASE/sockperf_op_time.csv
initHeaderCSV_states ./log/$TEST_CASE/container_state.csv
# clear old namespaces and old checkpoint images
sudo ./base_scripts/clear_namespace.sh icli
sshpass -p $SSHPASS ssh -t $SRC_HOST "sudo $REPO_DIR_SRC/base_scripts/clear_namespace.sh isrv"
sshpass -p $SSHPASS ssh -t $SRC_HOST "sudo rm $REPO_DIR_SRC/checkpoints/* && sudo rm $REPO_DIR_SRC/logs/*"
sshpass -p $SSHPASS ssh -t $DST_HOST "sudo $REPO_DIR_DST/base_scripts/clear_namespace.sh isrv"
sshpass -p $SSHPASS ssh -t $DST_HOST "sudo rm $REPO_DIR_DST/checkpoints/* && sudo rm $REPO_DIR_DST/logs/*"
sudo rm $REPO_DIR_CLI/checkpoints/*
sudo rm $REPO_DIR_CLI/logs/*

echo "-----------------------Configurate network delay--------------------------------------"
sshpass -p $SSHPASS ssh -t $DST_HOST "sudo tc qdisc ad dev ens3 root netem delay 2ms 10us"
sshpass -p $SSHPASS ssh -t $SRC_HOST "sudo tc qdisc ad dev ens3 root netem delay 20ms 10us"
sudo tc qdisc ad dev ens3 root netem delay 2ms 10us

for iter in {1..50}
do
    echo "---------------iter $iter----------------------"
    # $SRC_HOST: run sockperf server
    sshpass -p $SSHPASS ssh -t $SRC_HOST "sudo $REPO_DIR_SRC/base_scripts/namespace.sh isrv 172.16.0.10/12 && sudo podman run -d --rm --runtime /usr/bin/runc --name=server --network ns:/run/netns/isrv sockperf sr -i 172.16.0.10 --tcp"
    echo "---------------sockperf server container created------------------------------" 
    # Local: run sockperf client
    sudo ./base_scripts/namespace.sh icli 172.16.0.11/12
    sudo ./base_scripts/set_flow.sh 'icli-pod-ovs' 'podvxlanA' 'icli'
    sudo ip netns exec 'icli' ping -c 1 172.16.0.10
    sudo podman run -d --rm -v $REPO_DIR_CLI/logs:/log --name=client --privileged --network ns:/run/netns/icli sockperf pp -i 172.16.0.10 --tcp -t 10 --full-log /log/sockperf.log
    echo "---------------sockperf client container created------------------------------"
    sleep 3
    # $SRC_HOST: Collect container memory usage
    sshpass -p $SSHPASS ssh -t $SRC_HOST "sudo podman stats --no-stream --no-trunc --format "table {{.ID}},{{.MemUsage}},{{.CPU}}" &> $REPO_DIR_SRC/logs/stats-container.log"
    # $SRC_HOST: Checkpoint on sever container
    perf stat -o "$REPO_DIR_CLI/logs/perf_ckpt.log" sshpass -p $SSHPASS ssh -t $SRC_HOST "(taskset -c 1 sudo podman --runtime /usr/bin/runc container checkpoint --compress=none -e $REPO_DIR_SRC/checkpoints/ckpt.tar.gz server --tcp-established --print-stats) &> $REPO_DIR_SRC/logs/stats-ckpt.log"
    # $SRC_HOST: clear isrv namespace 
    echo "------------------migration starts---------------------------------------"
    perf stat -o "$REPO_DIR_CLI/logs/ns_clear.log" sshpass -p $SSHPASS ssh -t $SRC_HOST "perf stat -o $REPO_DIR_SRC/logs/ns_clear_real.log sudo $REPO_DIR_SRC/gitrepos/podman_overlay_performance/base_scripts/clear_namespace.sh isrv && sudo chown cal-admin $REPO_DIR_SRC/checkpoints/ckpt.tar.gz"
    #echo "---------------sockperf server container checkpointed------------------------------"
    
    # $DST_HOST1: copy checkpoint image from $SRC_HOST
    perf stat -o "$REPO_DIR_CLI/logs/scp_ckpt.log" sshpass -p $SSHPASS ssh -t $DST_HOST "perf stat -o $REPO_DIR_DST/logs/scp_real.log sshpass -p $SSHPASS sudo scp $SRC_HOST:$REPO_DIR_SRC/checkpoints/ckpt.tar.gz $REPO_DIR_DST/checkpoints"
    # $DST_HOST1: create new isrv namespace
    perf stat -o "$REPO_DIR_CLI/logs/create_ns.log" sshpass -p $SSHPASS ssh -t $DST_HOST "perf stat -o $REPO_DIR_DST/logs/create_ns_real.log sudo $REPO_DIR_DST/base_scripts/namespace.sh isrv 172.16.0.10/12"
    #echo "---------------sockperf server container checkpoint moved to $DST_HOST1------------------------------"
    
    # Local: manipulate OvS flow and clean the arp table of client namespace
    perf stat -o "$REPO_DIR_CLI/logs/clear_arp.log" sudo ./base_scripts/set_flow.sh 'icli-pod-ovs' 'podvxlanB' 'icli'

    # $DST_HOST1: restore the server container
    perf stat -o "$REPO_DIR_CLI/logs/perf_restore.log" sshpass -p $SSHPASS ssh -t $DST_HOST "(taskset -c 1 sudo podman --runtime /usr/bin/runc container restore -i $REPO_DIR_DST/checkpoints/ckpt.tar.gz --ignore-static-ip --tcp-established --print-stats) &> $REPO_DIR_DST/logs/stats-restore.log"
    
    echo "-------------------migration finished-------------------------------------------------"
    sleep 10
    # $DST_HOST1: stop the server container
    sshpass -p $SSHPASS ssh -t $DST_HOST 'sudo podman stop server'

    # Post procesing
    sshpass -p $SSHPASS ssh -t $SRC_HOST "sudo chown $USER $REPO_DIR_SRC/logs/*"
    sshpass -p $SSHPASS ssh -t $DST_HOST "sudo chown $USER $REPO_DIR_DST/logs/*"
    sshpass -p $SSHPASS ssh -t $SRC_HOST "sudo chown $USER $REPO_DIR_SRC/checkpoints/*"
    sshpass -p $SSHPASS scp $SRC_HOST:$REPO_DIR_SRC/logs/* $REPO_DIR_CLI/logs #gathering restore log
    sshpass -p $SSHPASS scp $DST_HOST:$REPO_DIR_DST/logs/* $REPO_DIR_CLI/logs #gathering restore log
    sshpass -p $SSHPASS scp $SRC_HOST:$REPO_DIR_SRC/checkpoints/* $REPO_DIR_CLI/checkpoints
    dumpFileSize=$(du -b -c $REPO_DIR_CLI/checkpoints/ckpt.tar.gz | grep total | sed 's/[^0-9]*//g')

    fromJSONtoCSV_ckp $REPO_DIR_CLI/logs/stats-ckpt.log ./log/$TEST_CASE/podman_dump.csv $iter $dumpFileSize
    fromJSONtoCSV_restore $REPO_DIR_CLI/logs/stats-restore.log ./log/$TEST_CASE/podman_restore.csv $iter
    fromTimeLogstoCSV ./log/$TEST_CASE/sockperf_op_time.csv $iter
    fromStateLogstoCSV ./log/$TEST_CASE/container_state.csv $iter
    python3 ./sockperf2csv.py $REPO_DIR_CLI/logs/sockperf.log ./log/$TEST_CASE/sockperf.csv $iter

    # Cleaning
    sudo ./base_scripts/clear_namespace.sh icli
    sudo ./base_scripts/clear_namespace.sh isrv
    sshpass -p $SSHPASS ssh -t $SRC_HOST "sudo $REPO_DIR_SRC/base_scripts/clear_namespace.sh isrv"
    sshpass -p $SSHPASS ssh -t $SRC_HOST "sudo rm $REPO_DIR_SRC/checkpoints/* && sudo rm $REPO_DIR_SRC/logs/*"
    sshpass -p $SSHPASS ssh -t $DST_HOST "sudo $REPO_DIR_DST/base_scripts/clear_namespace.sh icli"
    sshpass -p $SSHPASS ssh -t $DST_HOST "sudo $REPO_DIR_DST/base_scripts/clear_namespace.sh isrv"
    sshpass -p $SSHPASS ssh -t $DST_HOST "sudo rm $REPO_DIR_DST/checkpoints/* && sudo rm $REPO_DIR_DST/logs/*"
    sudo rm $REPO_DIR_CLI/checkpoints/*
    sudo rm $REPO_DIR_CLI/logs/*
    sleep 5
done

echo "--------------------clear network setting ---------------------------"
sshpass -p $SSHPASS ssh -t $DST_HOST "sudo tc qdisc del dev ens3 root"
sshpass -p $SSHPASS ssh -t $SRC_HOST "sudo tc qdisc del dev ens3 root"
sudo tc qdisc del dev ens3 root


