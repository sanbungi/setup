#!/bin/bash
set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/preflight.sh"
if preflight_requested "$@"; then
  preflight_package_manager
  preflight_commands git sudo
  preflight_git https://github.com/neovim/neovim.git refs/tags/stable
  exit 0
fi

if command -v apt &> /dev/null; then
  sudo apt update
  sudo apt install -y ninja-build gettext cmake unzip curl build-essential ripgrep
elif command -v dnf &> /dev/null; then
  sudo dnf install -y ninja-build gettext cmake unzip curl gcc gcc-c++ make
else
  echo "apt または dnf が見つかりません。"
  exit 1
fi

cd /tmp
git clone https://github.com/neovim/neovim
cd neovim

git checkout stable

make distclean
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install

hash -r
which nvim
nvim --version

echo "nvim build success!"
