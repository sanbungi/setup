#!/bin/bash
set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/preflight.sh"
if preflight_requested "$@"; then
  preflight_package_manager
  preflight_commands curl sudo gpasswd sg
  preflight_http https://get.docker.com
  exit 0
fi

curl -fsSL https://get.docker.com -o get-docker.sh

sudo sh get-docker.sh

rm get-docker.sh

sudo gpasswd -a $USER docker

echo "ユーザーがdockerグループに追加されました。"
echo "グループ変更を反映するには、ログアウト後に再ログインするか、次のコマンドを実行してください: newgrp docker"

# dockerグループを適用して実行
sg docker -c "docker --version"
