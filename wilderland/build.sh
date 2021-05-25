#!/bin/sh

set -eux

repository_url="https://github.com/efa/Wilderland.git"

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  cmake \
  git \
  libsdl2-dev \
  libsdl2-image-dev

rm -rf /build/dist-inst

if ! git ls-remote /build/repository -q >/dev/null 2>&1; then
  git clone $repository_url /build/repository
else
  git --work-tree=/build/repository --git-dir=/build/repository/.git checkout .
  git --work-tree=/build/repository --git-dir=/build/repository/.git pull
fi

cd /build/repository || exit
make clean
make -j1 CFLAGS="-std=c99 -Wall -O2 -fcommon -fno-lto"
