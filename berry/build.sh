#!/bin/sh

set -eux

repository_url="https://github.com/JLErvin/berry.git"

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  git \
  libx11-dev \
  libxft-dev \
  libxinerama-dev

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

make clean
make -j$(getconf _NPROCESSORS_ONLN) APP_PATH=/opt/caprice32
#make DESTDIR=/build/dist-inst install

#objcopy --only-keep-debug mt940-ledger mt940-ledger.dbg
#objcopy --strip-unneeded mt940-ledger
