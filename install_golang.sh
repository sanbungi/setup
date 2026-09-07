#!/bin/bash
set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/preflight.sh"
if preflight_requested "$@"; then
  preflight_package_manager
  preflight_commands sudo
  exit 0
fi

if command -v apt &> /dev/null; then
  sudo apt update -y
  sudo apt install -y golang
elif command -v dnf &> /dev/null; then
  sudo dnf install -y golang
else
  echo "apt または dnf が見つかりません。"
  exit 1
fi

go install golang.org/x/tools/gopls@latest

go version
