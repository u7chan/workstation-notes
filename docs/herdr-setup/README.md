# Herdr のセットアップ

Last reviewed: 2026-07-01

## 概要

Herdr は、AI コーディングエージェント向けのターミナルマルチプレクサー。

tmux のようにターミナルを閉じてもプロセスを維持しながら、ワークスペース、タブ、ペインと、各 AI エージェントの `working` / `blocked` / `done` / `idle` をまとめて確認できる。

- 単一の Rust バイナリで動作する
- GUI、Electron、アカウント、テレメトリーは不要
- Linux と macOS は stable、Windows ネイティブ版は preview beta
- Claude Code、Codex、OpenCode などを自動検出する
- CLI とローカル Socket API からペインやエージェントを操作できる
- SSH 先やスマートフォンのターミナルからもセッションへ再接続できる

## 確認環境

- WSL2
- Ubuntu
- Linux x86_64
- Windows Terminal
- Herdr 0.7.1

## インストール前の確認

コマンドがまだ存在しないことを確認する。

```bash
command -v herdr
herdr --version
```

未インストールの場合、1 行目は何も出力せず、2 行目は次のようになる。

```text
herdr: command not found
```

スクリプトの内容を先に確認する場合は、ブラウザーで `https://herdr.dev/install.sh` を開くか、次のように保存して確認する。

```bash
curl -fsSL https://herdr.dev/install.sh -o /tmp/herdr-install.sh
less /tmp/herdr-install.sh
```

2026-07-01 時点のインストーラーは OS と CPU アーキテクチャを判定し、`https://herdr.dev/latest.json` に記載されたバイナリを取得する。既定の配置先は `~/.local/bin/herdr`。

## インストール

公式のインストールコマンドを実行する。

```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

`~/.local/bin` が `PATH` に含まれていないという警告が出た場合は、シェル設定へ追加して新しいシェルを開く。

```bash
export PATH="$HOME/.local/bin:$PATH"
```

この環境では、すでに `~/.local/bin` が `PATH` に含まれていたため追加設定は不要だった。

## インストール後の確認

```bash
command -v herdr
herdr --version
```

今回の結果:

```text
/home/u7dev/.local/bin/herdr
herdr 0.7.1
```

## 初回起動

作業対象のディレクトリで起動する。

```bash
cd ~/workspace/example-project
herdr
```

初回起動時は通知音とトースト通知の設定を選ぶ。ワークスペースが存在しない場合は、現在のディレクトリを起点に自動作成される。

Herdr はバックグラウンドサーバーとクライアントに分かれている。クライアントを閉じても、サーバー上のペインとプロセスは動作し続ける。再度 `herdr` を実行すると既存セッションへ接続する。

## 最小操作

標準 prefix は `Ctrl+b`。同時押しではなく、`Ctrl+b` を押して離してから次のキーを押す。

| 操作 | キー |
| - | - |
| 左右にペインを分割する | `Ctrl+b` → `v` |
| 上下にペインを分割する | `Ctrl+b` → `-` |
| 新しいタブを作る | `Ctrl+b` → `c` |
| 次／前のタブへ移動する | `Ctrl+b` → `n` / `p` |
| ワークスペースを選ぶ | `Ctrl+b` → `w` |
| 新しいワークスペースを作る | `Ctrl+b` → `Shift+n` |
| クライアントを切り離す | `Ctrl+b` → `q` |
| キー一覧を表示する | `Ctrl+b` → `?` |

マウスでもペイン、タブ、ワークスペースの選択、境界のリサイズ、右クリックメニューによる分割を操作できる。

## セッションの確認と終了

状態を確認する。

```bash
herdr status server
herdr session list
```

クライアントだけを切り離す場合は `Ctrl+b` → `q` を使う。既定セッションを完全に終了し、ペイン内のプロセスも停止する場合は次を実行する。

```bash
herdr server stop
```

`herdr server stop` はペイン内のプロセスも終了させるため、単なる detach とは用途が異なる。

## 更新

公式インストーラーで導入した場合は、Herdr 自身で更新できる。

```bash
herdr update
```

実行中のサーバーは更新前のプロセスを使い続ける場合がある。新バージョンへ確実に切り替えるには、作業を保存してからサーバーを停止し、再度起動する。

```bash
herdr server stop
herdr
```

Homebrew、mise、Nix で導入した場合は、それぞれのパッケージ管理手段で更新する。

## Herdr への一本化

この環境ではターミナルマルチプレクサーを Herdr に一本化する。Windows Terminal、Zed、VS Code のどこから起動する場合も、作業ディレクトリで `herdr` を実行する。

tmux の自動起動、エイリアス、補助関数、`~/.tmux.conf` は使用しない。Herdr を別のマルチプレクサー内で起動する二重構成も避ける。

## エイリアス

Herdr の操作に次のエイリアスを使用する。

```bash
alias h='herdr'
alias ha='herdr session attach'
alias hl='herdr session list'
alias hn='herdr session attach'
alias hk='herdr session stop'
```

| エイリアス | 実行内容 | 用途 |
| - | - | - |
| `h` | `herdr` | 既定 session を起動または attach |
| `ha work` | `herdr session attach work` | 名前付き session を起動または attach |
| `hl` | `herdr session list` | session 一覧を表示 |
| `hn work` | `herdr session attach work` | 名前付き session を新規作成または attach |
| `hk work` | `herdr session stop work` | 名前付き session と配下のプロセスを停止 |

Herdr には独立した `session new` コマンドはない。`session attach` が、指定した名前の session がなければ作成し、存在すれば接続するため、`ha` と `hn` は同じ定義になる。

## 参考

- [Herdr 公式サイト](https://herdr.dev/)
- [Install Herdr](https://herdr.dev/docs/install/)
- [Quick start](https://herdr.dev/docs/quick-start/)
- [Integrations](https://herdr.dev/docs/integrations/)
- [ogulcancelik/herdr](https://github.com/ogulcancelik/herdr)
