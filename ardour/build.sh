#!/bin/sh

set -eux

repository_url="git://git.ardour.org/ardour/ardour.git"

export DEBIAN_FRONTEND="noninteractive"
apt update
apt dist-upgrade -y
apt install -y \
  build-essential \
  git \
  itstool \
  libarchive-dev \
  libasound2-dev \
  libaubio-dev \
  libboost-dev \
  libcppunit-dev \
  libcurl4-gnutls-dev \
  libdbus-1-dev \
  libfftw3-dev \
  libgtkmm-2.4-dev \
  libjack-dev \
  liblilv-dev \
  liblo-dev \
  liblrdf0-dev \
  librubberband-dev \
  libsamplerate0-dev \
  libserd-dev \
  libsndfile1-dev \
  libsord-dev \
  libsratom-dev \
  libsuil-dev \
  libtag1-dev \
  libudev-dev \
  libusb-1.0-0-dev \
  libwebsockets-dev \
  libxml2-dev \
  lv2-dev \
  pkg-config \
  python3 \
  squashfs-tools-ng \
  vamp-plugin-sdk

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

export LDFLAGS="-Wl,-O1,--as-needed,--no-copy-dt-needed-entries -flto"
export CFLAGS="-O2 -pipe -march=x86-64 -mtune=sandybridge"
export CXXFLAGS="-O2 -pipe -march=x86-64 -mtune=sandybridge"
export CPPFLAGS="-Wall"

sed -i -e 's|prepend_opt_flags = True|prepend_opt_flags = False|' wscript

python3 waf configure \
  --prefix=/opt/ardour \
  --with-backends="jack,alsa,dummy" \
  --libjack=weak \
  --nls \
  --optimize \
  --cxx11 \
  --freedesktop \
  --ptformat \
  --lxvst \
  --no-phone-home

python3 waf build -v
python3 waf install --destdir=/build/dist-inst

gensquashfs -D /build/dist-inst/opt/ardour /build/ardour.sqfs
