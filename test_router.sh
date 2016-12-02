#!/bin/ash

################################################################################
#
#   Name:        test_router.sh
#   Authors:     James H. Loving
#   Description: This script is used by test_client.sh to test the performance
#                of EDICT as measured by its impact on CPU utilization, memory
#                utilization, and network throughput.
#
#                Note: This script is NOT designed to be run by the user. It
#                is executed via test_client.sh.
#
################################################################################

# get performance metrics once per $2 seconds for $1 seconds
for i in `seq 1 $1`
do
    date +%s
    vmstat
    sleep $2
done
