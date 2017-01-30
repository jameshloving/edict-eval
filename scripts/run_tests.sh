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

    echo "Disabling EDICT"
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep bloomd|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep edict|head -n 1|cut -c 1-5`'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep server.js|head -n 1|cut -c 1-5`'

    DIR=$MAIN_DIR+"edict-off-noScan-wired$i"
    sleep 5
    ./test_client.sh $DIR $SERVER_IP
    DIR=$MAIN_DIR+"edict-off-yesScan-wired$i"
    sleep 5
    ./test_client.sh $DIR $SERVER_IP --portscan

    echo "Enabling EDICT (no UI)"
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP '~/edict/bloomd -f ~/edict/bloomd.conf &'
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP '~/edict/edict &'

    DIR=$MAIN_DIR+"edict-on-noUI-noScan-wired$i"
    sleep 5
    ./test_client.sh $DIR $SERVER_IP
    DIR=$MAIN_DIR+"edict-on-noUI-yesScan-wired$i"
    sleep 5
    ./test_client.sh $DIR $SERVER_IP --portscan

    echo "Enabling EDICT UI"
    ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'node ~/edict/server.js &'

    DIR=$MAIN_DIR+"edict-on-yesUI-noScan-wired$i"
    sleep 5
    ./test_client.sh $DIR $SERVER_IP
    DIR=$MAIN_DIR+"edict-on-yesUI-yesScan-wired$i"
    sleep 5
    ./test_client.sh $DIR $SERVER_IP --portscan
done

echo "Disabling EDICT"
ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep bloomd|head -n 1|cut -c 1-5`'
ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep edict|head -n 1|cut -c 1-5`'
ssh -i $EDICT_SSH_KEY $EDICT_USERNAME@$EDICT_IP 'kill `ps|grep server.js|head -n 1|cut -c 1-5`'
