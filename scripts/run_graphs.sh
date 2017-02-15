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

for i in $MAIN_DIR/*
do
    python3 graph_iperf.py $i
    python3 graph_vmstat.py $i
done
