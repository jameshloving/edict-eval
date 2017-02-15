#!/bin/bash

################################################################################
#
#   Name:        test_client.sh
#   Authors:     James H. Loving
#   Description: This script is used to test the performance of EDICT, as
#                measured by its impact on CPU utilization, memory utilization,
#                and network throughput.
#
#                Note: run `./prep_router.sh` prior to FIRST run.
#
#                Note: run `iperf -s` on SERVER machine prior to ALL runs.
#
################################################################################

EDICT_USERNAME=root
EDICT_IP=192.168.1.1
EDICT_SSH_KEY=~/.ssh/id_edict

# check for correct number of arguments
if [ -z "$2" ]
then
    echo "Usage: $0 <output directory> <iperf server IP> --portscan[optional]"
    exit
fi

# check if directory exists
if [ ! -d $1 ]
then
    echo "Directory $1 did not exist. Creating..."
    mkdir $1
fi

# check time offset
SERVER_TIME=`ssh -i ~/.ssh/id_edict $EDICT_USERNAME@$EDICT_IP 'date +%s'`
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

TEST_DURATION=3600
TEST_FREQ=1

# start CPU/memory utilization logging on router
echo ""
echo "[`date +%s`]: Pushing slave script to router for utilization test"
scp -i $EDICT_SSH_KEY test_router.sh $EDICT_USERNAME@$EDICT_IP:~/
echo "[`date +%s`]: Starting CPU and memory utilization logging"
ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP "./test_router.sh $TEST_FREQ $TEST_DURATION > test.out &"

# start throughput test
echo ""
echo "[`date +%s`]: Starting throughput logging (IPv6)"
iperf3 -c $2 -P 10 -t $TEST_DURATION -i $TEST_FREQ > $1/iperf6.txt &
#iperf3 -c $2 -b 50M -t $TEST_DURATION -i $TEST_FREQ > $1/iperf6.txt &
IPERF_PID=$!

# run test
echo ""
echo "[`date +%s`]: Running test for $TEST_DURATION seconds"
END_TIME=`date +%s`
END_TIME=$((END_TIME + TEST_DURATION - 1))
CURR_TIME=`date +%s`
while [ $CURR_TIME -lt $END_TIME ]
do
    # restart nmap if nmap has exited
    if ([ -n "$3" ] && [ $3 == "--portscan" ])
    then
        if ps -p $NMAP_PID > /dev/null
        then
            :
        else
            nmap -T5 -p- 192.168.0.0/16 &
            NMAP_PID=$!
        fi
    fi
    # restart iperf if iperf has exited
    if ps -p $IPERF_PID > /dev/null
    then
        :
    else
        iperf3 -c $2 -P 10 -t $TEST_DURATION -i $TEST_FREQ > $1/iperf6.txt &
        #iperf3 -c $2 -b 50M -t $TEST_DURATION -i $TEST_FREQ > $1/iperf6.txt &
        IPERF_PID=$!
    fi
    # update timing    
    CURR_TIME=`date +%s`
    TIME_REMAINING=`echo $END_TIME-$CURR_TIME|bc`
    if [ `echo $TIME_REMAINING%60|bc` -eq 0 ]
    then
        echo "`echo $TIME_REMAINING/60|bc` minutes remaining"
    fi
    sleep 1
done

# finish test and collect garbage
echo ""
echo "[`date +%s`]: Test complete"
pkill nmap
echo "[`date +%s`]: Fetching results from router"
scp -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP:~/test.out $1/vmstat.txt
ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'rm ~/test.out'

# check time offset again
SERVER_TIME=`ssh -i ~/.ssh/id_edict $EDICT_USERNAME@$EDICT_IP 'date +%s'`
CLIENT_TIME=`date +%s`
((OFFSET_TIME = $SERVER_TIME - $CLIENT_TIME))
echo ""
echo "[`date +%s`]: Current server time = $SERVER_TIME (difference = $OFFSET_TIME)"

# graph results
echo ""
echo "Please reconnect the router to the Internet and run:"
echo "python graph_iperf.py $1"
echo "python graph_vmstat.py $1"
