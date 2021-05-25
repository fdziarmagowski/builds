#!/bin/sh

set -eux

repository_url="https://github.com/fbergama/pigfx.git"

rm -rf /build/dist-inst

pacman --noconfirm --needed -Syu \
  arm-none-eabi-gcc \
  base-devel \
  ctags \
  git

if ! git ls-remote /build/repository -q >/dev/null 2>&1; then
  git clone $repository_url /build/repository
  git -C /build/repository submodule update --init --recursive
else
  git --work-tree=/build/repository --git-dir=/build/repository/.git checkout .
  git --work-tree=/build/repository --git-dir=/build/repository/.git pull
  git -C /build/repository submodule update --init --recursive
fi

cd /build/repository || exit

mkdir -p build || rm -rf build/*
./makeall
