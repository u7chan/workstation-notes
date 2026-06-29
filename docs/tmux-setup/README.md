# tmux のセットアップ

Last reviewed: 2026-06-29

## 概要

tmux は 1 つのターミナル内で複数の作業画面を扱うためのツール。

WSL2 Ubuntu + Windows Terminal で、レビューや AI 駆動開発の確認作業を複数ペインに分けて進めやすくする。

`.tmux.conf` は chezmoi で管理し、次を設定している。

- `escape-time 0`：ESC キーが tmux に吸収されるのを防ぐ（tmux 内で動作する CLI ツールの中断操作などに必要）
- `mouse on`：マウス操作の有効化
- `allow-passthrough on`：OSC シーケンス等のパススルー
- prefix を `Ctrl+b` から `Ctrl+a` に変更
- prefix に続く `d` / `s` / `w` で pane の分割と終了

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

標準の prefix は `Ctrl+b`。この環境では操作しやすいように `Ctrl+a` へ変更している。

prefix は同時押しではない。`Ctrl+a` を押して離してから、次のキーを押す。先に prefix を押すことで、通常のシェル入力ではなく tmux への操作として扱われる。

## ペイン操作のキーバインド

Windows Terminal の `Ctrl+d` / `Ctrl+Shift+d` / `Ctrl+w` とは分け、tmux 内では prefix に続けて通常キーを押す。

| 操作 | キー |
| - | - |
| 左右に分割する | `Ctrl+a` → `d` |
| 上下に分割する | `Ctrl+a` → `s` |
| pane を終了する | `Ctrl+a` → `w`、確認後に `y` |

tmux 標準の `Ctrl+a` → `%`（左右分割）と `Ctrl+a` → `"`（上下分割）もそのまま使える。`Ctrl+a` → `d` は tmux 標準では session から抜ける操作だが、この設定では左右分割へ上書きされる。

設定は `chezmoi/dot_tmux.conf` で管理する。

```tmux
# ペイン操作用のカスタムキーバインド
# 合わない場合は、このブロックをコメントアウトすると標準設定へ戻せる
# --- custom pane keybindings ---
unbind C-b
set -g prefix C-a
bind C-a send-prefix

bind-key d split-window -h
bind-key s split-window -v
bind-key w confirm-before -p "kill-pane? (y/n)" kill-pane
# --- end custom pane keybindings ---
```

この操作が合わない場合は、開始・終了コメント間のブロック全体をコメントアウトする。既存の tmux server には読み込み済みの設定が残るため、すべての session を終了して tmux を起動し直すと標準の `Ctrl+b` に戻る。

設定を現在の tmux server へ反映する。

```bash
tmux source-file ~/.tmux.conf
```

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
| session から抜ける | `tmux detach-client` |
| 左右に分割する | `Ctrl+a` → `d` または `%` |
| 上下に分割する | `Ctrl+a` → `s` または `"` |
| pane を移動する | `Ctrl+a` → 矢印キー |
| pane を終了する | `Ctrl+a` → `w`、確認後に `y` |
| pane を終了する | shell で `exit` |

session を終了する。

```bash
tmux kill-session -t work
```

## Bash ショートカット

よく使う tmux alias は `~/.bash_aliases`、関数は `~/.bash_functions` にまとめておく。`~/.bashrc.local` はこの 2 ファイルを読み込む入口にする。

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

`work:0.1` は `session:window.pane` の形式。対象 pane は `Ctrl+a` → `q` で確認できる。

### `tc`

指定した pane の表示内容を取得する。行数を省略した場合は末尾 20 行を表示する。

```bash
tc work:0.1
tc work:0.1 80
```

## 反映

`~/.bash_aliases` / `~/.bash_functions` を更新した後、シェルを開き直す。

すぐ反映したい場合は次を実行する。

```bash
source ~/.bashrc.local
```
