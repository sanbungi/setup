#!/bin/bash
set -e

mkdir -p ~/.config/nvim
cp init.lua ~/.config/nvim/
cp coc-settings.json ~/.config/nvim/
cp .screenrc ~/
cp .bash_aliases ~/

# .bash_funtionを読み込む設定を.bashrcに安全に追記
DEST_FILE="$HOME/.bash_functions" 
RC_FILE="$HOME/.bashrc"
# 検索する文字列（これがあれば追記しない）
SEARCH_STR="source \"$DEST_FILE\""

if grep -Fq "$SEARCH_STR" "$RC_FILE"; then
    echo ".bashrc already sources .bash_functions. (Skipping append)"
else
    echo "Appending source command to $RC_FILE..."
    # 追記実行
    echo "" >> "$RC_FILE"
    echo "# Load My custom bash functions" >> "$RC_FILE"
    echo "[ -f \"$DEST_FILE\" ] && source \"$DEST_FILE\"" >> "$RC_FILE"
    
    cp "./.bash_functions" "$DEST_FILE"
    
    echo "Added source configuration to $RC_FILE"
fi
