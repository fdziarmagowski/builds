#!/bin/sh

set -eux

repository_url="https://github.com/polybar/polybar.git"

if [ -f /etc/debian_version ]; then
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
elif [ -f /etc/arch-release ]; then
  pacman --noconfirm --needed -Syu \
    alsa-lib \
    cairo \
    cmake \
    curl \
    git \
    i3-wm \
    jsoncpp \
    libmpdclient \
    libnl \
    libpulse \
    pkg-config \
    python \
    python-sphinx \
    xcb-util-cursor \
    xcb-util-image \
    xcb-util-wm \
    xcb-util-xrm \
    xorg-fonts-misc
else
  echo "Build not supported"
  exit 1
fi

rm -rf /build/dist-inst

if ! git ls-remote /build/repository -q >/dev/null 2>&1; then
  git clone -b 3.4 $repository_url /build/repository
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
  -DPYTHON_EXECUTABLE=/usr/bin/python3 \
  -DCMAKE_INSTALL_PREFIX=/opt/polybar \
  -DCMAKE_BUILD_TYPE=Debug ..
make -j$(getconf _NPROCESSORS_ONLN)
make DESTDIR=/build/dist-inst install

#objcopy --only-keep-debug \
#  /builds/dist-inst/opt/polybar/bin/polybar \
#  /builds/dist-inst/opt/polybar/bin/polybar.dbg
#
#objcopy --strip-unneeded \
#  /builds/dist-inst/opt/polybar/bin/polybar
