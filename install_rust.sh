#!/bin/bash
set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/preflight.sh"
if preflight_requested "$@"; then
  preflight_http https://sh.rustup.rs
  exit 0
fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# .profileに追記して nvim でも使えるようにする
if ! grep -q "\.cargo/env" ~/.profile; then
  echo 'source "$HOME/.cargo/env"' >> ~/.profile
fi

source "$HOME/.cargo/env"

rustup component add rustfmt

rustc --version
cargo --version
