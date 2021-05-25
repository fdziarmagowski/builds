#!/bin/bash

set -u

# Set directory variables
SRC_DIR=`pwd`
CIRCLE_HOME="$SRC_DIR/third_party/circle-stdlib"
COMMON_HOME="$SRC_DIR/third_party/common"

if [ -f sdcard/config.txt ]
then
  echo Making everything...
else
  echo Must be run from BMC64 root dir.
  exit
fi

# Vice
cd $SRC_DIR/third_party/vice-3.5

export LDFLAGS="-L$CIRCLE_HOME/install/arm-none-circle/lib"
export CXXFLAGS="-O3 -std=c++11 -fno-exceptions -march=armv8-a -mtune=cortex-a53 -marm -mfpu=neon-fp-armv8 -mfloat-abi=hard -ffreestanding -nostdlib"
export CFLAGS="-O3 -I$COMMON_HOME -I$CIRCLE_HOME/install/arm-none-circle/include/ -I$CIRCLE_HOME/libs/circle/addon/fatfs -I$ARM_HOME/lib/gcc/arm-none-eabi/$ARM_VERSION/include-fixed -I$ARM_HOME/lib/gcc/arm-none-eabi/$ARM_VERSION/include -fno-exceptions -march=armv8-a -mtune=cortex-a53 -marm -mfpu=neon-fp-armv8 -mfloat-abi=hard -ffreestanding -nostdlib"
./configure --host=arm-none-eabi \
  --disable-ahi \
  --disable-bundle \
  --disable-catweasel \
  --disable-hardsid \
  --disable-hidmgr \
  --disable-hidutils \
  --disable-ipv6 \
  --disable-lame \
  --disable-midi \
  --disable-parsid \
  --disable-pdf-docs \
  --disable-portaudio \
  --disable-realdevice \
  --disable-rs232 \
  --disable-sdlui \
  --disable-sdlui2 \
  --disable-ssi2001 \
  --enable-headlessui \
  --without-png \
  --without-alsa \
  --without-oss \
  --without-pulse \
  --without-zlib

cd src
make libarchdep
make libhvsc
cd ..

make x64
make x128
make xvic
make xplus4
make xpet

echo ==============================================================
echo Link errors above are expected
echo ==============================================================

cd $SRC_DIR
make clean
BOARD=$BOARD make -f Makefile-C64
