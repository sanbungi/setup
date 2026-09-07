#!/bin/bash
set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/preflight.sh"
if preflight_requested "$@"; then
  preflight_package_manager
  preflight_commands git sudo
  preflight_git https://github.com/rbenv/rbenv.git
  preflight_git https://github.com/rbenv/ruby-build.git
  exit 0
fi

if command -v apt &> /dev/null; then
  sudo apt update
  sudo apt install -y libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev
elif command -v dnf &> /dev/null; then
  sudo dnf install -y openssl-devel readline-devel zlib-devel autoconf bison gcc gcc-c++ make libyaml-devel ncurses-devel libffi-devel gdbm-devel
else
  echo "apt または dnf が見つかりません。"
  exit 1
fi

if [ ! -d "$HOME/.rbenv" ]; then
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
else
  echo "rbenv is already installed."
fi

mkdir -p ~/.rbenv/plugins
if [ ! -d "$HOME/.rbenv/plugins/ruby-build" ]; then
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
fi

# .bashrcに過剰な追記防止
if ! grep -q "rbenv init" ~/.bashrc; then
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
fi

# .profileにも同じ内容を書く（nvim用)
if ! grep -q "rbenv init" ~/.profile; then
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
  echo 'eval "$(rbenv init -)"' >> ~/.profile
fi

# 直接PATHを通して rbenv を有効化
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# 最新のRubyを選ぶ
LATEST_RUBY=$(rbenv install -l | grep -v - | tail -1)
# 既にあるならスキップ
if ! rbenv versions | grep -q "$LATEST_RUBY"; then
  rbenv install "$LATEST_RUBY"
fi

rbenv global "$LATEST_RUBY"

gem install solargraph

ruby -v
