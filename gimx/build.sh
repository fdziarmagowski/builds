#!/bin/sh

set -eux

repository_url="https://github.com/matlo/GIMX.git"

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  gettext \
  git \
  libbluetooth-dev \
  libcurl4-gnutls-dev \
  libmhash-dev \
  libncursesw5-dev \
  libusb-1.0-0-dev \
  libwxgtk3.0-gtk3-dev \
  libxi-dev \
  libxml2-dev

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

make -j$(getconf _NPROCESSORS_ONLN)
make -j1 DESTDIR=/build/dist-inst install
#objcopy --only-keep-debug mt940-ledger mt940-ledger.dbg
#objcopy --strip-unneeded mt940-ledger
