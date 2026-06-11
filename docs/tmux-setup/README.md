# tmux のセットアップ

Last reviewed: 2026-06-11

## 概要

tmux は 1 つのターミナル内で複数の作業画面を扱うためのツール。

WSL2 Ubuntu + Windows Terminal で、レビューや AI 駆動開発の確認作業を複数ペインに分けて進めやすくする。

このガイドでは標準設定のまま使う。`.tmux.conf` によるカスタマイズは扱わない。

## 前提

- WSL2
- Ubuntu
- Windows Terminal
- `sudo apt` を実行できること

## インストール

```bash
sudo apt update
sudo apt install -y tmux
```

## インストール後の確認

```bash
tmux -V
command -v tmux
```

## 基本概念

| 用語 | 意味 |
| - | - |
| session | tmux の作業単位。ターミナルを閉じても残せる |
| window | session 内のタブに近い単位 |
| pane | window 内で分割された作業領域 |
| prefix | tmux に命令を送るための前置キー |

標準の prefix は `Ctrl+b`。

たとえば新しい pane を作る場合は、`Ctrl+b` を押してから `%` を押す。先に prefix を押すことで、通常のシェル入力ではなく tmux への操作として扱われる。

## 最小操作

名前付き session を作る。

```bash
tmux new -s work
```

session の一覧を見る。

```bash
tmux ls
```

既存 session に戻る。

```bash
tmux attach -t work
```

tmux 内でよく使う操作:

| 操作 | キー |
| - | - |
| session から抜ける | `Ctrl+b` → `d` |
| 左右に分割する | `Ctrl+b` → `%` |
| 上下に分割する | `Ctrl+b` → `"` |
| pane を移動する | `Ctrl+b` → 矢印キー |
| pane を終了する | shell で `exit` |

session を終了する。

```bash
tmux kill-session -t work
```

## Bash ショートカット

よく使う tmux コマンドは `~/.bashrc.local` にまとめておく。

Bash 設定全体の管理方針は `docs/shell/README.md` を参照。

```bash
# tmux
alias t='tmux'
alias ta='tmux attach -t'
alias tl='tmux ls'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'

# tmux rename-session shortcut
tr() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: tr <new_name>"
    return 1
  fi

  if [ -z "$TMUX" ]; then
    echo "Error: not inside tmux."
    return 1
  fi

  tmux rename-session "$1"
}

# tmux send-keys shortcut
ts() {
  if [ "$#" -lt 2 ]; then
    echo "Usage: ts <target-pane> <command>"
    return 1
  fi

  tmux send-keys -t "$1" "${*:2}" Enter
}

# tmux capture-pane shortcut
tc() {
  if [ "$#" -lt 1 ]; then
    echo "Usage: tc <target-pane> [lines]"
    return 1
  fi

  tmux capture-pane -t "$1" -p | tail -n "${2:-20}"
}
```

### alias

| コマンド | 意味 |
| - | - |
| `t` | `tmux` の短縮 |
| `tn work` | `tmux new -s work` の短縮 |
| `tl` | `tmux ls` の短縮 |
| `ta work` | `tmux attach -t work` の短縮 |
| `tk work` | `tmux kill-session -t work` の短縮 |
| `tr name` | 現在の session 名を `name` に変更 |

### `ts`

指定した pane にコマンドを送って Enter まで実行する。

```bash
ts work:0.1 "git status"
```

`work:0.1` は `session:window.pane` の形式。対象 pane は `Ctrl+b` → `q` で確認できる。

### `tc`

指定した pane の表示内容を取得する。行数を省略した場合は末尾 20 行を表示する。

```bash
tc work:0.1
tc work:0.1 80
```

## 反映

`~/.bashrc.local` を更新した後、シェルを開き直す。

すぐ反映したい場合は次を実行する。

```bash
source ~/.bashrc.local
```
