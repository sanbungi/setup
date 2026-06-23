#!/bin/bash
set -e

if command -v apt &> /dev/null; then
  sudo apt update -y
  sudo apt install -y jq
elif command -v dnf &> /dev/null; then
  sudo dnf install -y jq
else
  echo "apt または dnf が見つかりません。"
  exit 1
fi

jq --version
