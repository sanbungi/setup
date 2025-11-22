# 自分用環境構築セットアップウイザード

```
wget -q https://github.com/Pikka2048/setup/releases/download/latest/setup_tool && chmod +x setup_tool && ./setup_tool
```

https://github.com/user-attachments/assets/88591fe0-68d1-47ab-b0bc-ef55b4f6b1c6



※ Debian系環境のみ対応

## セットアップ出来るもの

- neovimのLTSをソースからビルド
- screenコマンドをソースからビルド（neovim色バグ対策）
- Node.jsとnpmをnコマンドでLTSをインストール（coc-nvim用）
- RubyとGemをrbenvで最新バージョンをインストール、solargraph言語サーバーもインストール
- 設定ファイルを自動配置

その後nvimを開くことにより、プラグインは自動DL
