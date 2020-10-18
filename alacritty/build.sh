#!/bin/sh

set -eux

repository_url="https://github.com/alacritty/alacritty.git"
branch="v0.5.0"

export DEBIAN_FRONTEND="noninteractive"

apt update
apt dist-upgrade -y
apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  cmake \
  curl \
  git \
  libfontconfig1-dev \
  libfreetype6-dev \
  libxcb-xfixes0-dev \
  pkg-config \
  python3

rm -rf /build/repository/target/*

if ! git ls-remote /build/repository -q >/dev/null 2>&1; then
  git clone -b $branch $repository_url /build/repository
  git -C /build/repository submodule update --init --recursive
else
  git --work-tree=/build/repository --git-dir=/build/repository/.git checkout .
  git --work-tree=/build/repository --git-dir=/build/repository/.git pull
  git -C /build/repository submodule update --init --recursive
fi

cd /build/repository || exit

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. $HOME/.cargo/env
rustup override set stable
rustup update stable

env CARGO_INCREMENTAL=0 cargo build --release --locked
env CARGO_INCREMENTAL=0 cargo test --release

objcopy --only-keep-debug \
  /build/repository/target/release/alacritty \
  /build/repository/target/release/alacritty.dbg

objcopy --strip-unneeded \
  /build/repository/target/release/alacritty
