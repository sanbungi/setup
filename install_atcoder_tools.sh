#!/bin/bash
set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/preflight.sh"
if preflight_requested "$@"; then
  preflight_package_manager
  preflight_commands node npm python3

  CHECK_ROOT="$(mktemp -d /tmp/atcoder-tools-check.XXXXXX)"
  trap 'rm -rf "$CHECK_ROOT"' EXIT
  mkdir -p "$CHECK_ROOT/home"
  HOME="$CHECK_ROOT/home" npm_config_cache="$CHECK_ROOT/npm-cache" \
    npm install --silent --prefix "$CHECK_ROOT/npm" atcoder-cli
  python3 -m venv "$CHECK_ROOT/oj"
  HOME="$CHECK_ROOT/home" PIP_CACHE_DIR="$CHECK_ROOT/pip-cache" \
    "$CHECK_ROOT/oj/bin/python" -m pip install --quiet --upgrade pip setuptools online-judge-tools
  HOME="$CHECK_ROOT/home" "$CHECK_ROOT/npm/node_modules/.bin/acc" --version
  HOME="$CHECK_ROOT/home" "$CHECK_ROOT/oj/bin/oj" --version
  exit 0
fi

INSTALL_ROOT="$HOME/.local/share/atcoder-tools"
NPM_ROOT="$INSTALL_ROOT/npm"
OJ_VENV="$INSTALL_ROOT/oj"

if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
  echo "エラー: Node.js と npm が必要です。先に install_nodejs.sh を実行してください。"
  exit 1
fi

if command -v apt &> /dev/null; then
  sudo apt update
  sudo apt install -y python3 python3-venv
elif command -v dnf &> /dev/null; then
  sudo dnf install -y python3
else
  echo "apt または dnf が見つかりません。"
  exit 1
fi

mkdir -p "$NPM_ROOT"
npm install --prefix "$NPM_ROOT" atcoder-cli

python3 -m venv "$OJ_VENV"
"$OJ_VENV/bin/python" -m pip install --upgrade pip setuptools online-judge-tools

PATH_LINE='export PATH="$HOME/.local/share/atcoder-tools/npm/node_modules/.bin:$HOME/.local/share/atcoder-tools/oj/bin:$PATH"'
touch "$HOME/.bashrc"
if ! grep -Fq "$PATH_LINE" "$HOME/.bashrc"; then
  {
    echo ""
    echo "# AtCoder CLI tools (acc + oj)"
    echo "$PATH_LINE"
  } >> "$HOME/.bashrc"
fi

export PATH="$NPM_ROOT/node_modules/.bin:$OJ_VENV/bin:$PATH"

acc --version
oj --version
acc check-oj
