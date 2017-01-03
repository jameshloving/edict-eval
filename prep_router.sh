#!/bin/ash

################################################################################
#
#   Name:        prep_router.sh
#   Authors:     James H. Loving
#   Description: This script is used to prepare the router for testing. Run it
#                once prior to executing test_client.sh.
#
#                Note: This script is designed to work for an Asus N66u
#                router running on a MIPS 74k processor. Modify it if the
#                test hardware differs.
#
################################################################################

PKG_VMSTAT='procps-ng-vmstat_3.3.11-3_mipsel_74kc.ipk'

ssh -i ~/.ssh/id_edict root@192.168.1.1 "wget https://downloads.lede-project.org/snapshots/packages/mipsel_74kc/packages/$PKG_VMSTAT"
ssh -i ~/.ssh/id_edict root@192.168.1.1 "opkg install $PKG_VMSTAT"
