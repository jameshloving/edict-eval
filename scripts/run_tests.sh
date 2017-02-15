#!/bin/bash

################################################################################
#
#   Name:        run_test.sh
#   Authors:     James H. Loving
#   Description: This script is used to execute multiple full rounds of testing.
#
################################################################################

SERVER_IP=192.168.0.138
EDICT_USERNAME=root
EDICT_IP=192.168.1.1
EDICT_SSH_KEY=~/.ssh/id_edict

# ensure directory has finishing "/"
MAIN_DIR=$1
MAIN_DIR_LAST="${MAIN_DIR: -1}"
if [ "$MAIN_DIR_LAST" != "/" ]
then
   MAIN_DIR="$MAIN_DIR/" 
fi 

# check if directory exists
if [ ! -d $MAIN_DIR ]
then
    echo "Directory $MAIN_DIR did not exist. Creating..."
    mkdir $MAIN_DIR
fi

# run test rounds
for i in {1..2}
do
    echo "***Starting round $i***"
    TEST_TYPE="-no-limit"

    # EDICT disabled, no portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep bloomd|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep edict|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep server.js|head -n 1|cut -c 1-5`'
    DIR=$MAIN_DIR"edict-off-noScan-wired$TEST_TYPE$i"
    sleep 5
    ./test_client.sh $DIR $SERVER_IP

    # EDICT disabled, yes portscan
    DIR=$MAIN_DIR"edict-off-yesScan-wired$TEST_TYPE$i"
    sleep 5
    ./test_client.sh $DIR $SERVER_IP --portscan

    # EDICT enabled, no UI, no portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'rm -f /var/lib/edict/device_log.txt'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'bloomd -f ~/edict/bloomd.conf &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP '~/edict/edict start edict &'
    DIR=$MAIN_DIR"edict-on-noUI-noScan-wired$TEST_TYPE$i"
    sleep 5
    ./test_client.sh $DIR $SERVER_IP
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep bloomd|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep edict|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep server.js|head -n 1|cut -c 1-5`'

    # EDICT enabled, no UI, yes portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'rm -f /var/lib/edict/device_log.txt'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'bloomd -f ~/edict/bloomd.conf &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP '~/edict/edict start edict &'
    DIR=$MAIN_DIR"edict-on-noUI-yesScan-wired$TEST_TYPE$i"
    sleep 5
    ./test_client.sh $DIR $SERVER_IP --portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep bloomd|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep edict|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep server.js|head -n 1|cut -c 1-5`'

    # EDICT enabled, yes UI, no portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'rm -f /var/lib/edict/device_log.txt'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'bloomd -f ~/edict/bloomd.conf &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP '~/edict/edict start edict &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'node ~/edict/server.js &'
    DIR=$MAIN_DIR"edict-on-yesUI-noScan-wired$TEST_TYPE$i"
    sleep 5
    ./test_client.sh $DIR $SERVER_IP
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep bloomd|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep edict|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep server.js|head -n 1|cut -c 1-5`'

    # EDICT enabled, yes UI, yes portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'rm -f /var/lib/edict/device_log.txt'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'bloomd -f ~/edict/bloomd.conf &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP '~/edict/edict start edict &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'node ~/edict/server.js &'
    DIR=$MAIN_DIR"edict-on-yesUI-yesScan-wired$TEST_TYPE$i"
    sleep 5
    ./test_client.sh $DIR $SERVER_IP --portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep bloomd|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep edict|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep server.js|head -n 1|cut -c 1-5`'
done

for i in {1..2}
do
    echo "***Starting round $i***"
    TEST_TYPE="-500M-limit"

    # EDICT disabled, no portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep bloomd|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep edict|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep server.js|head -n 1|cut -c 1-5`'
    DIR=$MAIN_DIR"edict-off-noScan-wired$TEST_TYPE$i"
    sleep 5
    ./test_client_limited.sh $DIR $SERVER_IP

    # EDICT disabled, yes portscan
    DIR=$MAIN_DIR"edict-off-yesScan-wired$TEST_TYPE$i"
    sleep 5
    ./test_client_limited.sh $DIR $SERVER_IP --portscan

    # EDICT enabled, no UI, no portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'rm -f /var/lib/edict/device_log.txt'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'bloomd -f ~/edict/bloomd.conf &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP '~/edict/edict start edict &'
    DIR=$MAIN_DIR"edict-on-noUI-noScan-wired$TEST_TYPE$i"
    sleep 5
    ./test_client_limited.sh $DIR $SERVER_IP
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep bloomd|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep edict|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep server.js|head -n 1|cut -c 1-5`'

    # EDICT enabled, no UI, yes portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'rm -f /var/lib/edict/device_log.txt'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'bloomd -f ~/edict/bloomd.conf &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP '~/edict/edict start edict &'
    DIR=$MAIN_DIR"edict-on-noUI-yesScan-wired$TEST_TYPE$i"
    sleep 5
    ./test_client_limited.sh $DIR $SERVER_IP --portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep bloomd|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep edict|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep server.js|head -n 1|cut -c 1-5`'

    # EDICT enabled, yes UI, no portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'rm -f /var/lib/edict/device_log.txt'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'bloomd -f ~/edict/bloomd.conf &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP '~/edict/edict start edict &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'node ~/edict/server.js &'
    DIR=$MAIN_DIR"edict-on-yesUI-noScan-wired$TEST_TYPE$i"
    sleep 5
    ./test_client_limited.sh $DIR $SERVER_IP
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep bloomd|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep edict|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep server.js|head -n 1|cut -c 1-5`'

    # EDICT enabled, yes UI, yes portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'rm -f /var/lib/edict/device_log.txt'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'bloomd -f ~/edict/bloomd.conf &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP '~/edict/edict start edict &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'node ~/edict/server.js &'
    DIR=$MAIN_DIR"edict-on-yesUI-yesScan-wired$TEST_TYPE$i"
    sleep 5
    ./test_client_limited.sh $DIR $SERVER_IP --portscan
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep bloomd|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep edict|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep server.js|head -n 1|cut -c 1-5`'
done
