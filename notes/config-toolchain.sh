STAGING_DIR='/home/ubuntu/lede-sdk-brcm47xx-mips74k_gcc-5.4.0_musl-1.1.15.Linux-x86_64/staging_dir'
TOOLCHAIN_DIR='toolchain-mipsel_74kc_gcc-5.4.0_musl-1.1.15'

export AR=$STAGING_DIR/$TOOLCHAIN_DIR/bin/your-architecture-ar
export CC=$STAGING_DIR/$TOOLCHAIN_DIR/bin/your-architecture-gcc
export CXX=$STAGING_DIR/$TOOLCHAIN_DIR/bin/your-architecture-g++
export LINK=$STAGING_DIR/$TOOLCHAIN_DIR/bin/your-architecture-g++
export RANLIB=$STAGING_DIR/$TOOLCHAIN_DIR/bin/your-architecture-ranlib
export STAGING_DIR=$STAGING_DIR
export LIBPATH=$STAGING_DIR/$TOOLCHAIN_DIR/lib
export LDFLAGS='-Wl,-rpath-link '${LIBPATH}
