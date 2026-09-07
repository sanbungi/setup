#!/bin/bash
set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/preflight.sh"
if preflight_requested "$@"; then
  preflight_package_manager
  preflight_commands sudo
  exit 0
fi

if command -v apt &> /dev/null; then
  sudo apt update
  sudo apt install -y nodejs npm
  REMOVE_CMD="sudo apt purge -y nodejs npm"
elif command -v dnf &> /dev/null; then
  sudo dnf install -y nodejs npm
  REMOVE_CMD="sudo dnf remove -y nodejs npm"
else
  echo "apt または dnf が見つかりません。"
  exit 1
fi

sudo npm install -g n

sudo n lts

${REMOVE_CMD}

node -v
npm -v
