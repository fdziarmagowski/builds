#!/bin/sh

set -eux

repository_url="https://github.com/randyrossi/bmc64.git"

rm -rf /build/dist-inst

export DEBIAN_FRONTEND="noninteractive"
apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  autoconf \
  autoconf-archive \
  automake \
  autotools-dev \
  bison \
  build-essential \
  ca-certificates \
  flex \
  gcc-arm-none-eabi \
  git \
  libtool \
  pkg-config \
  xa65

if ! git ls-remote /build/repository -q >/dev/null 2>&1; then
  git clone $repository_url /build/repository
  git -C /build/repository submodule update --init --recursive
else
  git --work-tree=/build/repository --git-dir=/build/repository/.git checkout .
  git --work-tree=/build/repository --git-dir=/build/repository/.git pull
  git -C /build/repository submodule update --init --recursive
fi

cd /build/repository || exit

git clean -f -d -x -q

export ARM_HOME=/usr
export ARM_VERSION=$(ls /usr/lib/gcc/arm-none-eabi)

./make_all.sh pi3
