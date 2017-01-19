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
#                Note: This script requires `vmstat` be installed on the
#                router. To install:
#                   `./prep_router.sh`
#
################################################################################

# get performance metrics once per $2 seconds for $1 seconds
date +%s
top|head -n 4
vmstat $2 $1 --unit K --timestamp --one-header
