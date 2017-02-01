#!/bin/bash

################################################################################
#
#   Name:        run_graphs.sh
#   Authors:     James H. Loving
#   Description: This script is used to graph the results of run_test.sh
#
################################################################################

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
    echo "Directory $MAIN_DIR did not exist!"
    exit 0
fi

for i in {1..2}
do
    DIR=$MAIN_DIR"edict-off-noScan-wired$i"
    python3 graph_iperf.py $DIR
    python3 graph_vmstat.py $DIR
    DIR=$MAIN_DIR"edict-off-yesScan-wired$i"
    python3 graph_iperf.py $DIR
    python3 graph_vmstat.py $DIR

    DIR=$MAIN_DIR"edict-on-noUI-noScan-wired$i"
    python3 graph_iperf.py $DIR
    python3 graph_vmstat.py $DIR
    DIR=$MAIN_DIR"edict-on-noUI-yesScan-wired$i"
    python3 graph_iperf.py $DIR
    python3 graph_vmstat.py $DIR

    DIR=$MAIN_DIR"edict-on-yesUI-noScan-wired$i"
    python3 graph_iperf.py $DIR
    python3 graph_vmstat.py $DIR
    DIR=$MAIN_DIR"edict-on-yesUI-yesScan-wired$i"
    python3 graph_iperf.py $DIR
    python3 graph_vmstat.py $DIR
done
