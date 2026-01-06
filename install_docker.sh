#!/bin/bash
set -e

curl -fsSL https://get.docker.com -o get-docker.sh

sudo sh get-docker.sh

rm get-docker.sh

sudo gpasswd -a $USER docker

echo "ユーザーがdockerグループに追加されました。"
echo "グループ変更を反映するには、ログアウト後に再ログインするか、次のコマンドを実行してください: newgrp docker"

# dockerグループを適用して実行
sg docker -c "docker --version"
