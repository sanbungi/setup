#!/bin/bash
set -e

if command -v apt &> /dev/null; then
  sudo apt update
  sudo apt install -y curl ca-certificates xz-utils unzip
elif command -v dnf &> /dev/null; then
  sudo dnf install -y curl ca-certificates xz unzip
else
  echo "apt または dnf が見つかりません。"
  exit 1
fi

mkdir -p "$HOME/dlang"
curl -fsS https://dlang.org/install.sh -o "$HOME/dlang/install.sh"
chmod +x "$HOME/dlang/install.sh"

ACTIVATE_SCRIPT="$("$HOME/dlang/install.sh" install dmd -a | tail -n 1)"
if [ ! -f "$ACTIVATE_SCRIPT" ]; then
  echo "エラー: DMD の activate スクリプトが見つかりません: $ACTIVATE_SCRIPT"
  exit 1
fi

add_dlang_activation() {
  local rc_file="$1"
  touch "$rc_file"

  if grep -Fq "# Load D language compiler" "$rc_file"; then
    echo "$rc_file already loads D language compiler. (Skipping append)"
    return
  fi

  cat >> "$rc_file" <<'EOF'

# Load D language compiler
DLANG_ACTIVATE="$(ls -d "$HOME"/dlang/dmd-*/activate 2>/dev/null | sort -V | tail -n 1)"
if [ -n "$DLANG_ACTIVATE" ] && [ -f "$DLANG_ACTIVATE" ]; then
  . "$DLANG_ACTIVATE"
fi
unset DLANG_ACTIVATE
EOF
}

add_dlang_activation "$HOME/.profile"
add_dlang_activation "$HOME/.bashrc"

. "$ACTIVATE_SCRIPT"

dmd --version
dub --version
