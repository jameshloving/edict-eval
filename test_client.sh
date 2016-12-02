#!/bin/bash

################################################################################
#
#   Name:        test_client.sh
#   Authors:     James H. Loving
#   Description: This script is used to test the performance of EDICT, as
#                measured by its impact on CPU utilization, memory utilization,
#                and network throughput.
#
#                Note: run `iperf -s -w 16m` on SERVER machine prior to
#                execution.
#
################################################################################

# check for correct number of arguments
if [ -z "$3" ]; then
    echo "Usage: $0 <output directory> <duration in seconds> <iperf server IP> --portscan[optional]"
    exit
fi

SERVER_TIME=`ssh -i ~/.ssh/id_edict root@192.168.1.1 'date +%s'`
CLIENT_TIME=`date +%s`
echo "Current server time: $SERVER_TIME"
echo "Current client time: $CLIENT_TIME"
((OFFSET_TIME = $SERVER_TIME - $CLIENT_TIME))
echo "Difference = $OFFSET_TIME"

echo ""
echo "Writing results to directory $1"

# start CPU/memory utilization logging on router
echo "Starting CPU and memory utilization logging"
#ssh -i ~/.ssh/id_edict root@192.168.1.1 'watch -n 1 "top|head -n 2 >> ~/top.txt"'

# start throughput test
echo "Starting throughput logging"
iperf -c $3 -P 10 -t $2 -i 1 -w 16m -M 536 > $1/iperf.txt &

# start port scanning test, if selected

# run test
echo "Running test for $2 seconds"
sleep $2

# finish test and collect garbage
echo "Test complete"
scp -i ~/.ssh/id_edict root@192.168.1.1:~/top.txt $1/top.txt
ssh -i ~/.ssh/id_edict root@192.168.1.1 'rm ~/top.txt'
