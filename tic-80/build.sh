#!/bin/sh

set -eux

repository_url="https://github.com/nesbox/TIC-80.git"

if [ -f /etc/debian_version ]; then
  export DEBIAN_FRONTEND="noninteractive"
  apt update
  apt dist-upgrade -y
  apt install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    freeglut3-dev \
    git \
    libasound2-dev\
    libdrm-dev \
    libgbm-dev \
    libglu1-mesa-dev \
    libglvnd-dev \
    libgtk-3-dev \
    libpulse-dev
elif [ -f /etc/arch-release ]; then
  pacman --noconfirm --needed -Syu \
    alsa-lib \
    cmake \
    freeglut \
    git \
    glu \
    gtk3 \
    libglvnd \
    libpulse
else
  echo "Build not supported"
  exit 1
fi
rm -rf /build/dist-inst

if ! git ls-remote /build/repository -q >/dev/null 2>&1; then
  git clone $repository_url /build/repository
  git -C /build/repository submodule update --init --recursive
else
  git --work-tree=/build/repository --git-dir=/build/repository/.git checkout .
  git --work-tree=/build/repository --git-dir=/build/repository/.git pull
  git -C /build/repository submodule update --init --recursive
fi

cd /build/repository || exit

cd build
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/opt/tic-80 \
  ..
make -j$(getconf _NPROCESSORS_ONLN)
make DESTDIR=/build/dist-inst install
