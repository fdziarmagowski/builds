#!/bin/sh

set -eux

repository_url="<URL>"

export DEBIAN_FRONTEND="noninteractive"
apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  git \

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

# <build system specific>
