#!/bin/bash

################################################################################
#
#   Name:        run_graphs.sh
#   Authors:     James H. Loving
#   Description: This script is used to graph the results of run_test.sh
#
################################################################################

for i in {1..2}
do
    DIR="edict-off-noScan-wired$i"
    python graph_iperf.py $DIR
    python graph_vmstat.py $DIR
    DIR="edict-off-yesScan-wired$i"
    python graph_iperf.py $DIR
    python graph_vmstat.py $DIR

    DIR="edict-on-noUI-noScan-wired$i"
    python graph_iperf.py $DIR
    python graph_vmstat.py $DIR
    DIR="edict-on-noUI-yesScan-wired$i"
    python graph_iperf.py $DIR
    python graph_vmstat.py $DIR

    DIR="edict-on-yesUI-noScan-wired$i"
    python graph_iperf.py $DIR
    python graph_vmstat.py $DIR
    DIR="edict-on-yesUI-yesScan-wired$i"
    python graph_iperf.py $DIR
    python graph_vmstat.py $DIR
done
