#!/bin/sh

set -eux

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  git \
  libcairo2-dev \
  libgtk2.0-dev \
  libx11-dev \
  libxcomposite-dev \
  libxext-dev \
  libxfixes-dev \
  pkg-config

rm -rf /build/dist-inst

if ! git ls-remote /build/repository -q >/dev/null 2>&1; then
  git clone https://github.com/Jack12816/colorpicker.git /build/repository
  git -C /build/repository submodule update --init --recursive
else
  git --work-tree=/build/repository --git-dir=/build/repository/.git checkout .
  git --work-tree=/build/repository --git-dir=/build/repository/.git pull
  git -C /build/repository submodule update --init --recursive
fi

cd /build/repository || exit
make -j$(getconf _NPROCESSORS_ONLN)
