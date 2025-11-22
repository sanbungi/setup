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

if [ -d "setup" ]; then
    echo "既存の 'setup' ディレクトリが見つかりました。削除して再クローンします。"
    rm -rf setup
fi

git clone https://github.com/Pikka2048/setup
cd setup
echo "クローン OK"

read -p "nvimのLTSをソースからビルドしますか？ (y/N): " CONFIRM
case "$CONFIRM" in
    [yY]*)
        echo "処理を実行します..."
        bash build_nvim_lts.sh
        ;;
    *) 
        echo "実行しません。"
        ;;
esac

read -p "screenをソースからビルドしますか？ (y/N): " CONFIRM
case "$CONFIRM" in
    [yY]*)
        echo "処理を実行します..."
        bash build_screen.sh
        ;;
    *) 
        echo "実行しません。"
        ;;
esac

read -p "nodejsとnpmをnコマンドでインストールしますか？ (y/N): " CONFIRM
case "$CONFIRM" in
    [yY]*)
        echo "処理を実行します..."
        bash install_nodejs.sh
        ;;
    *) 
        echo "実行しません。"
        ;;
esac

read -p "設定ファイルを上書きコピーしますか？ (y/N): " CONFIRM
case "$CONFIRM" in
    [yY]*)
        echo "設定ファイルのコピーを開始します。"
        bash copy_setting.sh
       ;;
    *) 
        echo "実行しません。"
        ;;
esac

echo "作業用ディレクトリをクリーンアップします"
cd ~
rm -rf setup

echo "すべての処理が終了"
