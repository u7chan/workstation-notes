# yazi の導入

Last reviewed: 2026-07-02

## 概要

[yazi](https://github.com/sxyazi/yazi) は Rust 製のターミナルファイルマネージャ。非同期 I/O ベースで高速に動作し、画像プレビュー、シンタックスハイライト、Vim 風キーバインドを備える。

## 背景

ターミナル上でファイル操作を行う際、`ls` / `cd` の繰り返しより効率的なファイルブラウザが欲しかった。WSL 環境では GUI ファイルマネージャの起動が遅いため、ターミナル完結の yazi でカバーする。

`sftp` 経由やリモートマウント先のファイル操作でも使えるため、1つ入れておくと汎用性が高い。

## 前提

- Ubuntu 24.04 LTS
- WSL2
- `~/.local/bin` が PATH に含まれていること

## インストール

Ubuntu 24.04 の apt リポジトリには含まれていない。snap でも提供されているが classic モードのため `sudo` が必要。

ここでは sudo 不要な GitHub Releases からの prebuilt binary を使う。

```bash
# アーキテクチャを確認（x86_64 想定）
uname -m

# 最新版をダウンロードして展開
VERSION=26.5.6
curl -sL "https://github.com/sxyazi/yazi/releases/download/v${VERSION}/yazi-x86_64-unknown-linux-gnu.zip" \
  -o /tmp/yazi.zip

unzip -o /tmp/yazi.zip -d /tmp/yazi

# ~/.local/bin に配置
cp /tmp/yazi/yazi-x86_64-unknown-linux-gnu/yazi ~/.local/bin/
cp /tmp/yazi/yazi-x86_64-unknown-linux-gnu/ya ~/.local/bin/
chmod +x ~/.local/bin/yazi ~/.local/bin/ya
```

`ya` は yazi の CLI ユーティリティ（プラグイン管理などに使う）。

## インストール後の確認

```bash
yazi --version
ya --version
```

## 設定

設定ファイルのデフォルトは `~/.config/yazi/` に置く。

このリポジトリでは chezmoi で管理している。実体は `chezmoi/dot_config/yazi/` 配下。

| ファイル | 役割 |
|----------|------|
| `yazi.toml` | 一般設定（レイアウト、ソート、隠しファイル表示など） |
| `keymap.toml` | キーバインド |
| `theme.toml` | カラースキーム（Catppuccin Mocha / Latte） |
| `vfs.toml` | 仮想ファイルシステム設定 |
| `package.toml` | パッケージ管理（`ya pkg install` で復元） |

デフォルト設定ファイルは設定を上書きしたい部分だけ書けばよい。keymap の `prepend_keymap` / `append_keymap` を使えば、デフォルトキーバインドを維持したまま追加できる。

### テーマ

ターミナルの背景色に応じて、yazi がダーク/ライトを自動判定する。ダーク背景なら `[flavor] dark`、ライト背景なら `[flavor] light` のテーマが適用される。

```toml
# ~/.config/yazi/theme.toml
[flavor]
dark = "catppuccin-mocha"
light = "catppuccin-latte"
```

Catppuccin シリーズは [yazi-rs/flavors](https://github.com/yazi-rs/flavors) のテーマで、`ya pkg` でインストールする:

```bash
ya pkg add yazi-rs/flavors:catppuccin-mocha
ya pkg add yazi-rs/flavors:catppuccin-latte
```

`ya pkg` で入れたパッケージは `package.toml` に記録される。このファイルを chezmoi で管理しておけば、新環境では `ya pkg install` で一括復元できる。

設定の適用:

```bash
chezmoi apply
ya pkg install
```

アイコンの追加や色のカスタマイズについては [yazi のテーマカスタマイズ](../yazi-theme-customize/README.md) を参照。

## 簡単な使い方

| キー | 操作 |
|------|------|
| `j` / `k` | 上下移動 |
| `h` / `l` | 親ディレクトリ / 子ディレクトリ |
| `Enter` | ディレクトリに入る / ファイルを開く |
| `q` | 終了 |
| `Space` | 選択トグル |
| `y` | コピー |
| `x` | カット |
| `p` | ペースト |
| `r` | リネーム |
| `/` | 検索 |
| `g h` | ホームディレクトリへ |
| `H` | 前のディレクトリへ戻る |

## 実行ログ

2026-07-02 に Ubuntu 24.04.4 LTS (WSL2) 環境で確認した。

```text
$ yazi --version
Yazi 26.5.6 (aa52643 2026-05-05)

$ ya --version
Ya 26.5.6 (aa52643 2026-05-05)
```

`~/.local/bin/yazi` として配置し、PATH 経由で起動できることを確認。

## 補足

- yazi は `ripgrep`、`fd`、`fzf`、`zoxide` と統合できる。各ツールがインストール済みであれば、yazi 内の検索が強化される
- 画像プレビューを使うには、別途 `Überzug++` や `chafa` などのバックエンドが必要
- テーマは `theme.toml` を差し替えるか、[Flavors](https://yazi-rs.github.io/docs/flavors/overview) で変更できる

## 関連ドキュメント

- 公式: https://yazi-rs.github.io/
- 設定リファレンス: https://yazi-rs.github.io/docs/configuration/overview
