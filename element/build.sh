#!/bin/sh

set -eux

repository_url="https://github.com/kushview/element.git"

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  clang \
  git \
  ladspa-sdk \
  libasound2-dev \
  libboost-dev \
  libcurl4-openssl-dev \
  libfreetype6-dev \
  libgtk2.0-dev \
  liblilv-dev \
  libreadline-dev \
  libjack-jackd2-dev \
  libsuil-dev \
  libx11-dev \
  libxcomposite-dev \
  libxcursor-dev \
  libxext-dev \
  libxinerama-dev \
  libxrandr-dev \
  lv2-dev \
  pkg-config \
  python

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

./waf configure
./waf build
./waf check
