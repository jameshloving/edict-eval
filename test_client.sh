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
if [ -z "$2" ]
then
    echo "Usage: $0 <output directory> <iperf server IP> --portscan[optional]"
    exit
fi

TEST_DURATION=5
TEST_FREQ=1

# check time offset
SERVER_TIME=`ssh -i ~/.ssh/id_edict root@192.168.1.1 'date +%s'`
CLIENT_TIME=`date +%s`
((OFFSET_TIME = $SERVER_TIME - $CLIENT_TIME))
echo "[`date +%s`]: Current server time = $SERVER_TIME (difference = $OFFSET_TIME)"

echo ""
echo "[`date +%s`]: Writing results to directory $1"

# start port scanning test, if selected
if ([ -n "$3" ] && [ $3 == "--portscan" ])
then
    echo "[`date +%s`]: Starting port scan"
    nmap -T5 -p- 192.168.0.0/16 &
    NMAP_PID=$!
fi

# start CPU/memory utilization logging on router
echo ""
echo "[`date +%s`]: Pushing slave script to router for utilization test"
scp -i ~/.ssh/id_edict test_router.sh root@192.168.1.1:~/
echo "[`date +%s`]: Starting CPU and memory utilization logging"
ssh -i ~/.ssh/id_edict root@192.168.1.1 "./test_router.sh $TEST_DURATION $TEST_FREQ > test.out" &

# start throughput test
echo ""
echo "[`date +%s`]: Starting throughput logging (IPv4 and IPv6)"
iperf -c $2 -P 10 -t $TEST_DURATION -i $TEST_FREQ -w 16m -M 536 > $1/iperf4.txt &
iperf -c $2 -P 10 -t $TEST_DURATION -i $TEST_FREQ -w 16m -M 536 > $1/iperf6.txt &

# run test
echo ""
echo "[`date +%s`]: Running test for $TEST_DURATION seconds"
END_TIME=`date +%s`
END_TIME=$((END_TIME + TEST_DURATION - 1))
CURR_TIME=`date +%s`
while [ $CURR_TIME -lt $END_TIME ]
do
    if ps -p $NMAP_PID > /dev/null
    then
        :
    else
        nmap -T5 -p- 192.168.0.0/16 &
        NMAP_PID=$!
    fi
    CURR_TIME=`date +%s`
    sleep 1    
done

# finish test and collect garbage
echo ""
echo "[`date +%s`]: Test complete"
pkill nmap
echo "[`date +%s`]: Fetching results from router"
scp -i ~/.ssh/id_edict root@192.168.1.1:~/test.out $1/vmstat.txt
ssh -i ~/.ssh/id_edict root@192.168.1.1 'rm ~/test.out'

# check time offset again
SERVER_TIME=`ssh -i ~/.ssh/id_edict root@192.168.1.1 'date +%s'`
CLIENT_TIME=`date +%s`
((OFFSET_TIME = $SERVER_TIME - $CLIENT_TIME))
echo ""
echo "[`date +%s`]: Current server time = $SERVER_TIME (difference = $OFFSET_TIME)"
