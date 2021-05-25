#!/bin/sh

set -eux

repository_url="https://github.com/johanmalm/labwc.git"

#pacman --noconfirm --needed -Syu \
#    git \
#    meson \
#    pango \
#    wayland \
#    wayland-protocols \
#    wlroots

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  cmake \
  git \
  libcairo2-dev \
  libglib2.0-dev \
  libpango1.0-dev \
  libwayland-dev \
  libwlroots-dev \
  libxml2-dev \
  meson \
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

meson build
ninja -v -C build

#objcopy --only-keep-debug \
#  /builds/dist-inst/opt/polybar/bin/polybar \
#  /builds/dist-inst/opt/polybar/bin/polybar.dbg
#
#objcopy --strip-unneeded \
#  /builds/dist-inst/opt/polybar/bin/polybar
