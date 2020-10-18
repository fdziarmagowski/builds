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
  libcairo2-dev \
  libgsl-dev

rm -rf /build/dist-inst

if ! git ls-remote /build/repository -q >/dev/null 2>&1; then
  git clone https://github.com/dcf21/star-charter.git /build/repository
else
  git --work-tree=/build/repository --git-dir=/build/repository/.git checkout .
  git --work-tree=/build/repository --git-dir=/build/repository/.git pull
fi

cd /build/repository || exit
mkdir -p build

cd build
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  ..
make -j$(getconf _NPROCESSORS_ONLN)
