#!/bin/bash
set -e

if ! command -v apt &> /dev/null; then
    echo "debian系以外は対応していません。"
    exit 1
fi

echo "gitが使えるか確認します。"
if ! command -v git &> /dev/null; then
    sudo apt update && sudo apt install -y git

    # インストールが成功したか確認
    if command -v git &> /dev/null; then
        echo "gitのインストールが完了しました。"
    else
        echo "エラー: gitのインストールに失敗しました。"
        exit 1
    fi
else
    echo "git OK"
fi

echo "githubからクローン"
cd ~
git clone https://github.com/Pikka2048/setup
cd setup
echo "クローン OK"

read -p "nvimのLTSをソースからビルドしますか？ (y/N): " CONFIRM < /dev/tty
case "$CONFIRM" in
    [yY]*)
        echo "処理を実行します..."
        bash build_nvim_lts.sh
        ;;
    *) 
        echo "実行しません。"
        ;;
esac

read -p "screenをソースからビルドしますか？ (y/N): " CONFIRM < /dev/tty
case "$CONFIRM" in
    [yY]*)
        echo "処理を実行します..."
        bash build_screen.sh
        ;;
    *) 
        echo "実行しません。"
        ;;
esac

read -p "nodejsとnpmをnコマンドでインストールしますか？ (y/N): " CONFIRM < /dev/tty
case "$CONFIRM" in
    [yY]*)
        echo "処理を実行します..."
        bash install_nodejs.sh
        ;;
    *) 
        echo "実行しません。"
        ;;
esac

read -p "設定ファイルを上書きコピーしますか？ (y/N): " CONFIRM < /dev/tty
case "$CONFIRM" in
    [yY]*)
    echo "設定ファイルのコピーを開始します。"
    mkdir -p ~/.config/nvim
    cp init.lua ~/.config/nvim/
    cp coc-settings.json ~/.config/nvim/
    cp .screenrc ~/
    ;;
    *) 
        echo "実行しません。"
        ;;
esac

echo "作業用ディレクトリをクリーンアップします"
cd ~
rm -rf setup

echo "すべての処理が終了"
