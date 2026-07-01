# tmux のセットアップ

Last reviewed: 2026-07-01

## 概要

tmux は 1 つのターミナル内で複数の作業画面を扱うためのツール。

WSL2 Ubuntu + Windows Terminal で、レビューや AI 駆動開発の確認作業を複数ペインに分けて進めやすくする。

`.tmux.conf` は chezmoi で管理し、次を設定している。

- `escape-time 100`：Windows Terminal の端末応答を tmux が分割して、入力欄へ漏らす問題を避ける
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

Bash の行頭移動など、入力先へ通常の `Ctrl+a` を送りたい場合は `Ctrl+a` → `Ctrl+a` と押す。`bind C-a send-prefix` は、2 回目の `Ctrl+a` を tmux 内の shell やアプリへ渡すための設定。

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

設定値を確認する。

```bash
tmux show-options -s escape-time
```

`escape-time 100` と表示されれば反映済み。`100` はミリ秒単位で、端末応答を待つ時間と ESC キーの応答性のバランスを取った値。後述の表示崩れが続く場合は `500` まで増やす。

## Windows Terminal 起動時に制御文字列が表示される場合

プロンプトに次のような文字列が入力されることがある。

```text
11;rgb:2828/2c2c/3434
61;4;6;7;14;21;22;23;24;28;32;42;52c
```

前者は背景色照会（OSC 11）、後者は端末機能照会（DA1）に対する Windows Terminal の応答。`escape-time 0` では、応答が複数回に分かれて届いたときに tmux が制御シーケンスとして処理できず、Bash の入力へ漏れる場合がある。

このリポジトリでは `escape-time 100` を使用する。まだ発生する場合は `chezmoi/dot_tmux.conf` と `~/.tmux.conf` の値を `500` に変更して再読み込みする。値を大きくすると、tmux 内の Vim などで ESC キーの反応がわずかに遅くなる可能性がある。

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
