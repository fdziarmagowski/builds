#!/bin/sh

set -eux

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  cmake \
  git \
  i3-wm \
  libasound2-dev \
  libcairo2-dev \
  libcurl4-openssl-dev \
  libiw-dev \
  libjsoncpp-dev \
  libmpdclient-dev \
  libpulse-dev \
  libxcb-composite0-dev \
  libxcb-cursor-dev \
  libxcb-ewmh-dev \
  libxcb-icccm4-dev \
  libxcb-image0-dev \
  libxcb-randr0-dev \
  libxcb-util0-dev \
  libxcb-xkb-dev \
  libxcb-xrm-dev \
  libxcb1-dev \
  pkg-config \
  python3-sphinx \
  python3-xcbgen \
  xcb-proto

rm -rf /build/dist-inst

if ! git ls-remote /build/repository -q >/dev/null 2>&1; then
  git clone https://github.com/polybar/polybar.git /build/repository
  git -C /build/repository submodule update --init --recursive
else
  git --work-tree=/build/repository --git-dir=/build/repository/.git checkout .
  git --work-tree=/build/repository --git-dir=/build/repository/.git pull
  git -C /build/repository submodule update --init --recursive
fi

cd /build/repository || exit

mkdir -p build
cd build
cmake \
  -DCMAKE_INSTALL_PREFIX=/opt/polybar \
  ..
make -j$(getconf _NPROCESSORS_ONLN)
make DESTDIR=/build/dist-inst install
