#!/bin/sh

set -eux

repository_url="https://github.com/AndresNavarro82/vt52-fpga.git"

export DEBIAN_FRONTEND="noninteractive"
apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  fpga-icestorm \
  git \
  nextpnr-ice40 \
  yosys

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
