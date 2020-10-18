#!/bin/sh

set -eux

DT_VERSION=3.0.2

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  clang \
  cmake \
  git \
  intltool \
  iso-codes \
  libcolord-dev \
  libcolord-gtk-dev \
  libcurl4-gnutls-dev \
  libexiv2-dev \
  libflickcurl-dev \
  libglib2.0-dev \
  libgmic-dev \
  libgphoto2-dev \
  libgraphicsmagick1-dev \
  libgtk-3-dev \
  libjpeg62-turbo-dev \
  libjson-glib-dev \
  liblcms2-dev \
  liblensfun-dev \
  liblua5.3-dev \
  libopenexr-dev \
  libopenjp2-7-dev \
  libosmgpsmap-1.0-dev \
  libpng-dev \
  libpugixml-dev \
  librsvg2-dev \
  libsecret-1-dev \
  libsoup2.4-dev \
  libsqlite3-dev \
  libtiff5-dev \
  libwebp-dev \
  libxml2-dev \
  libxml2-utils \
  llvm \
  po4a \
  python3-jsonschema \
  wget \
  xsltproc \
  zlib1g-dev

rm -rf /build/darktable-${DT_VERSION}
rm -rf /build/dist-inst

cd /build
wget -qN https://github.com/darktable-org/darktable/releases/download/release-${DT_VERSION}/darktable-${DT_VERSION}.tar.xz
tar -xf darktable-${DT_VERSION}.tar.xz

cd darktable-${DT_VERSION}
mkdir build

cd build
cmake \
  -DBUILD_USERMANUAL=False \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/opt/darktable \
  -DRAWSPEED_ENABLE_LTO=ON \
  -DBINARY_PACKAGE_BUILD=1 \
  ..
make -j$(getconf _NPROCESSORS_ONLN)
make DESTDIR=/build/dist-inst install
