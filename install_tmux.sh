#!/bin/bash
set -e

if command -v apt &> /dev/null; then
  sudo apt update -y
  sudo apt install -y tmux
elif command -v dnf &> /dev/null; then
  sudo dnf install -y tmux
else
  echo "apt または dnf が見つかりません。"
  exit 1
fi

tmux -V
