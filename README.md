# setup

```
curl -fsSL https://raw.githubusercontent.com/Pikka2048/setup/refs/heads/main/setup.sh | bash
```

※ Debian系環境のみ対応

## セットアップ出来るもの

- neovimのLTSをソースからビルド
- screenコマンドをソースからビルド（neovim色バグ対策）
- Node.jsとnpmをnコマンドでLTSをインストール（coc-nvim用）
- 設定ファイルを自動配置

その後nvimを開くことにより、プラグインは自動DL
