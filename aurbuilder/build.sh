#!/bin/sh

set -eux

aur_url="https://aur.archlinux.org/$aurpkg.git"

pacman --noconfirm --needed -Syu \
  base-devel \
  git

useradd -d /build  builder
passwd -d builder
printf 'builder ALL=(ALL) ALL\n' | tee -a /etc/sudoers

mkdir -p /build/$aurpkg
chown builder:builder /build/$aurpkg

sudo -i -u builder sh << EOF

if ! git ls-remote /build/$aurpkg -q >/dev/null 2>&1; then
  git clone $aur_url /build/$aurpkg
  git -C /build/$aurpkg submodule update --init --recursive
else
  git --work-tree=/build/$aurpkg --git-dir=/build/$aurpkg/.git checkout .
  git --work-tree=/build/$aurpkg --git-dir=/build/$aurpkg/.git pull
  git -C /build/$aurpkg submodule update --init --recursive
fi

cd /build/$aurpkg
makepkg -si --noconfirm
EOF
