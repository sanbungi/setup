#!/bin/bash
set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/preflight.sh"
if preflight_requested "$@"; then
  preflight_package_manager
  preflight_commands curl sudo
  preflight_http https://ftp.jaist.ac.jp/pub/GNU/screen/screen-5.0.1.tar.gz
  exit 0
fi

if command -v apt &> /dev/null; then
  sudo apt update
  sudo apt install -y build-essential libncurses-dev libpam0g-dev
elif command -v dnf &> /dev/null; then
  sudo dnf install -y gcc gcc-c++ make ncurses-devel pam-devel wget
else
  echo "apt または dnf が見つかりません。"
  exit 1
fi

cd /tmp
wget https://ftp.jaist.ac.jp/pub/GNU/screen/screen-5.0.1.tar.gz
tar xzf screen-5.0.1.tar.gz
cd screen-5.0.1

./configure --prefix=/usr/local --enable-colors256 --with-pam

make
sudo make install

hash -r

which screen
screen --version

echo "screen build sccess!"
