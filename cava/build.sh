#!/bin/sh

set -eux

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  automake \
  build-essential \
  ca-certificates \
  cmake \
  git \
  libasound2-dev \
  libfftw3-dev \
  libiniparser-dev \
  libncursesw5-dev \
  libpulse-dev \
  libtool \
  pkg-config

rm -rf /build/dist-inst

if ! git ls-remote /build/repository -q >/dev/null 2>&1; then
  git clone https://github.com/karlstav/cava.git /build/repository
  git -C /build/repository submodule update --init --recursive
else
  git --work-tree=/build/repository --git-dir=/build/repository/.git checkout .
  git --work-tree=/build/repository --git-dir=/build/repository/.git pull
  git -C /build/repository submodule update --init --recursive
fi

cd /build/repository || exit

./autogen.sh
./configure
make -j$(getconf _NPROCESSORS_ONLN)
make DESTDIR=/build/dist-inst install
