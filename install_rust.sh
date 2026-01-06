#!/bin/bash
set -e

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# .profileに追記して nvim でも使えるようにする
if ! grep -q "\.cargo/env" ~/.profile; then
  echo 'source "$HOME/.cargo/env"' >> ~/.profile
fi

# 現在のシェルでも使えるように
source "$HOME/.cargo/env"

rustc --version
cargo --version
