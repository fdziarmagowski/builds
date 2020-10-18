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
  libsdl2-mixer-dev \
  libsdl2-ttf-dev \
  libsodium-dev \
  wget

rm -rf /build/dist-inst

if ! git ls-remote /build/repository -q >/dev/null 2>&1; then
  git clone https://github.com/diasurgical/devilutionX.git /build/repository
else
  git --work-tree=/build/repository --git-dir=/build/repository/.git checkout .
  git --work-tree=/build/repository --git-dir=/build/repository/.git pull
fi

cd /build/repository || exit
mkdir -p build

cd build
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/opt/devilutionX \
  -DBINARY_PACKAGE_BUILD=1 \
  ..
make -j$(getconf _NPROCESSORS_ONLN)
make DESTDIR=/build/dist-inst install

objcopy --only-keep-debug \
  /build/dist-inst/opt/devilutionX/devilutionx \
  /build/dist-inst/opt/devilutionX/devilutionx.dbg

objcopy --strip-unneeded \
  /build/dist-inst/opt/devilutionX/devilutionx
