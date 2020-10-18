#!/bin/sh

set -eux

repository_url="https://github.com/91861/wayst.git"

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  git \
  libegl-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libgl-dev \
  libutf8proc-dev \
  libwayland-dev \
  libwayland-egl-backend-dev \
  libxkbcommon-dev \
  wayland-protocols

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

make window_protocol=wayland -j$(getconf _NPROCESSORS_ONLN)
make DESTDIR=/build/dist-inst install

#objcopy --only-keep-debug mt940-ledger mt940-ledger.dbg
#objcopy --strip-unneeded mt940-ledger
