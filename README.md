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
- D言語(DMD/DUB)を公式install.shでインストール、neovim LSPはserve-dに対応
- 【NEW】Rustをrustupでインストール
- 【NEW】Dockerをget.docker.comからインストール
- 【NEW】tmuxをパッケージマネージャーからインストール
- 設定ファイルを自動配置

その後nvimを開くことにより、プラグインは自動DL

## nvimプラグイン キーバインド

`<leader>` は **Space** 

### 通常モード：基本操作

| キー                    | 説明                 |
| --------------------- | ------------------ |
| `Ctrl+h`              | 左のウィンドウへ移動         |
| `Ctrl+j`              | 下のウィンドウへ移動         |
| `Ctrl+k`              | 上のウィンドウへ移動         |
| `Ctrl+l`              | 右のウィンドウへ移動         |
| `Space n`             | 次のバッファへ移動          |
| `Space p`             | 前のバッファへ移動          |
| `Space 1` ～ `Space 9` | 番号のバッファを表示         |
| `Alt+F`               | Conformで現在のファイルを整形 |

### ファイル・検索

| キー         | 説明                   |
| ---------- | -------------------- |
| `Space ff` | ファイルを検索              |
| `Space fg` | プロジェクト内を文字列検索        |
| `Space fb` | 開いているバッファを検索         |
| `Space fh` | Neovimのヘルプを検索        |
| `Space o`  | 現在のファイル内の関数・型などを一覧表示 |
| `Space s`  | ワークスペース全体のシンボルを検索    |

### LSP：コード移動

| キー         | 説明                 |
| ---------- | ------------------ |
| `gd`       | 定義へ移動              |
| `Space df` | 定義へ移動。`gd` と同じ     |
| `gD`       | 宣言へ移動              |
| `gr`       | 参照箇所を表示            |
| `Space rf` | 参照箇所をTelescopeで表示  |
| `gi`       | 実装へ移動              |
| `gt`       | 型定義へ移動             |
| `K`        | カーソル位置の型・ドキュメントを表示 |
| `Space h`  | ホバー情報を表示。`K` と同じ   |
| `Space k`  | 関数の引数やシグネチャを表示     |

### LSP：編集・診断

| キー          | 説明               |
| ----------- | ---------------- |
| `Space rn`  | 変数・関数・型などを一括リネーム |
| `Space a`   | コードアクションを表示      |
| `Space fmt` | 現在のファイルを整形       |
| `Space d`   | カーソル位置のエラーや警告を表示 |
| `[d`        | 前の診断へ移動          |
| `]d`        | 次の診断へ移動          |

### Rust専用

| キー         | 説明                     |
| ---------- | ---------------------- |
| `Space th` | 型・引数名などのインレイヒントを表示／非表示 |
| `Space rt` | カーソル位置の型とドキュメントを表示     |
| `Space rT` | カーソル位置の値の型定義へ移動        |
| `Space rm` | カーソル位置のマクロを展開          |
| `Space ra` | Rustのコードアクションを表示       |
| `Space ri` | traitやメソッドの実装へ移動       |


### 挿入モード：補完

| キー           | 説明          |
| ------------ | ----------- |
| `Ctrl+Space` | 補完候補を表示     |
| `Ctrl+n`     | 次の補完候補を選択   |
| `Ctrl+p`     | 前の補完候補を選択   |
| `Tab`        | 表示中の補完候補を確定 |
| `Enter`      | 補完候補を確定     |
| `Ctrl+e`     | 補完メニューを閉じる  |
