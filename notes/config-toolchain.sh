#!/bin/bash

################################################################################
#
#   Name:        config-toolchain.sh
#   Authors:     James H. Loving
#   Description: This script is used to configure the environment variables
#                to allow for the LEDE SDK toolchain to cross-compile.
#
#                This script is currently configured for:
#                Linksys WRT1200AC
#
################################################################################

STAGING_DIR='/home/ubuntu/github/lede/staging_dir'
TOOLCHAIN_DIR='toolchain-arm_cortex-a9+vfpv3_gcc-5.4.0_musl-1.1.16_eabi'
ARCH='arm-openwrt-linux'

export AR=$STAGING_DIR/$TOOLCHAIN_DIR/bin/$ARCH-ar
export CC=$STAGING_DIR/$TOOLCHAIN_DIR/bin/$ARCH-gcc
export CXX=$STAGING_DIR/$TOOLCHAIN_DIR/bin/$ARCH-g++
export LINK=$STAGING_DIR/$TOOLCHAIN_DIR/bin/$ARCH-g++
export RANLIB=$STAGING_DIR/$TOOLCHAIN_DIR/bin/$ARCH-ranlib
export STAGING_DIR=$STAGING_DIR
export LIBPATH=$STAGING_DIR/$TOOLCHAIN_DIR/lib
export LDFLAGS='-Wl,-rpath-link '${LIBPATH}
