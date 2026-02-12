# 自分用環境構築セットアップウイザード

[おすすめエイリアス](https://github.com/Pikka2048/setup/blob/main/.bash_aliases)
[地味に便利な関数](https://github.com/Pikka2048/setup/blob/main/.bash_functions)


```
wget -q https://github.com/Pikka2048/setup/releases/download/latest/setup_tool && chmod +x setup_tool && ./setup_tool
```

https://github.com/user-attachments/assets/88591fe0-68d1-47ab-b0bc-ef55b4f6b1c6

※ Debian/Ubuntu と Fedora(dnf) 環境に対応

## セットアップ出来るもの

- neovimのLTSをソースからビルド
- screenコマンドをソースからビルド（neovim色バグ対策）
- Node.jsとnpmをnコマンドでLTSをインストール（coc-nvim用）
- RubyとGemをrbenvで最新バージョンをインストール、solargraph言語サーバーもインストール
- GolangをAPTリポジトリからインストール、gopls言語サーバーもインストール
- 【NEW】Rustをrustupでインストール
- 【NEW】Dockerをget.docker.comからインストール
- 【NEW】tmuxをパッケージマネージャーからインストール
- 設定ファイルを自動配置

その後nvimを開くことにより、プラグインは自動DL
