#!/bin/sh

set -eux

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  curl \
  git \
  libncurses-dev \
  libsqlite3-dev \
  libssl-dev \
  pkg-config

rm -rf /build/repository/target/*

if ! git ls-remote /build/repository -q >/dev/null 2>&1; then
  git clone https://github.com/jansc/ncgopher.git /build/repository
else
  git --work-tree=/build/repository --git-dir=/build/repository/.git checkout .
  git --work-tree=/build/repository --git-dir=/build/repository/.git pull
fi

cd /build/repository || exit

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. $HOME/.cargo/env
rustup override set stable
rustup update stable

env CARGO_INCREMENTAL=0 cargo build --release
env CARGO_INCREMENTAL=0 cargo test --release

objcopy --only-keep-debug \
  /build/repository/target/release/ncgopher \
  /build/repository/target/release/ncgopher.dbg

objcopy --strip-unneeded \
  /build/repository/target/release/ncgopher
