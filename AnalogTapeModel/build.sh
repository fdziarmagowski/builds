#!/bin/sh

set -eux

repository_url="https://github.com/jatinchowdhury18/AnalogTapeModel.git"

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  freeglut3-dev \
  git \
  libasound2-dev \
  libcairo2-dev \
  libcurl4-gnutls-dev \
  libjack-jackd2-dev \
  libx11-dev \
  libxcursor-dev \
  libxinerama-dev \
  libxrandr-dev \
  lv2-dev

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

cd Plugin
bash build_linux.sh

#objcopy --only-keep-debug mt940-ledger mt940-ledger.dbg
#objcopy --strip-unneeded mt940-ledger
