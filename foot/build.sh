#!/bin/sh

set -eux

repository_url="https://gitlab.com/dnkl/foot.git"

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  git \
  libegl-dev \
  libffi-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libgl-dev \
  libpixman-1-dev \
  libwayland-dev \
  libwayland-egl-backend-dev \
  libxkbcommon-dev \
  meson \
  scdoc \
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

mkdir -p /build/repository/subprojects
if ! git ls-remote /build/repository/subprojects/tllist -q >/dev/null 2>&1; then
  git clone https://codeberg.org/dnkl/tllist.git /build/repository/subprojects/tllist
  git -C /build/repository/subprojects/tllist submodule update --init --recursive
else
  git --work-tree=/build/repository/subprojects/tllist --git-dir=/build/repository/subprojects/tllist/.git checkout .
  git --work-tree=/build/repository/subprojects/tllist --git-dir=/build/repository/subprojects/tllist/.git pull
  git -C /build/repository/subprojects/tllist submodule update --init --recursive
fi
if ! git ls-remote /build/repository/subprojects/fcft -q >/dev/null 2>&1; then
  git clone https://codeberg.org/dnkl/fcft.git /build/repository/subprojects/fcft
  git -C /build/repository/subprojects/fcft submodule update --init --recursive
else
  git --work-tree=/build/repository/subprojects/fcft --git-dir=/build/repository/subprojects/fcft/.git checkout .
  git --work-tree=/build/repository/subprojects/fcft --git-dir=/build/repository/subprojects/fcft/.git pull
  git -C /build/repository/subprojects/fcft submodule update --init --recursive
fi

cd /build/repository
export CFLAGS="-O3 -march=native -fno-plt"
meson --buildtype=release -Db_lto=true . build
ninja -C build

DESTDIR=/build/dist-inst ninja -C build install

for b in foot footclient; do
  objcopy --only-keep-debug \
    /build/dist-inst/usr/local/bin/$b \
    /build/dist-inst/usr/local/bin/$b.dbg

  objcopy --strip-unneeded \
    /build/dist-inst/usr/local/bin/$b
done
