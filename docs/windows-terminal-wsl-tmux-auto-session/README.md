# Windows Terminal + WSL で pane ごとに tmux session を自動作成する

Last reviewed: 2026-06-12

## 概要

Windows Terminal で WSL pane を split したときに、新しい pane ごとに専用の `tmux` session を自動作成する設定。

さらに pane を `Ctrl+w` で閉じたとき、その pane 専用 session も自動で破棄する。

tmux を挟んでも Windows Terminal のペイン分割時にカレントディレクトリを引き継ぎ、ホイールスクロールで tmux の履歴をスクロールできるようにする。

## 目的

- split した pane ごとに独立した `tmux` session を持たせたい
- split した新 pane を元 pane と同じディレクトリで開始したい
- tmux 内でもマウスホイールでスクロールしたい
- pane を閉じたときに session を孤児化させたくない
- 手動で `tmux kill-session` する手間を減らしたい

## 前提

- WSL2
- Ubuntu
- Windows Terminal
- `tmux 3.4` 以降

`destroy-unattached` と `allow-passthrough` を使うため、`tmux 3.4` 以降を前提にする。

## 仕組み

`~/.bashrc` で Windows Terminal にカレントディレクトリを通知し、次を満たすときだけ `tmux new-session` を実行する。

- まだ `tmux` 内ではない
- Windows Terminal 上の WSL shell である

Windows Terminal のディレクトリ引き継ぎは OSC 9;9 エスケープシーケンスで動く。tmux 内ではそのままだと破棄されるため、DCS パススルーで包んで外側の Windows Terminal まで届ける。

作成する session 名は `w$$` 形式にする。`$$` は shell の PID なので、短くても通常は衝突しにくい。

session には `destroy-unattached on` を付ける。これにより、その pane が最後の client なら、閉じた時点で session も自動削除される。

tmux 起動時に `allow-passthrough on`、`mouse on`、`WheelUpPane` のキーバインドも設定する。これにより `.tmux.conf` を別途編集せず、`.bashrc` 側の設定だけでディレクトリ引き継ぎとスクロールを有効化する。

## 設定例

適用先は `~/.bashrc`。

サンプルは [examples/bash/bashrc.tmux-auto-session](/home/u7dev/workspace/workstation-notes/examples/bash/bashrc.tmux-auto-session) に置いている。

```bash
# Windows Terminal にカレントディレクトリを通知する
# tmux 内では OSC 9;9 が破棄されるため、DCS パススルーで外側へ届ける
__wt_report_cwd() {
  local wpath
  wpath="$(wslpath -w "$PWD" 2>/dev/null)" || return
  if [ -n "$TMUX" ]; then
    printf '\ePtmux;\e\e]9;9;%s\e\e\\\e\\' "$wpath"
  else
    printf '\e]9;9;%s\e\\' "$wpath"
  fi
}

case ";$PROMPT_COMMAND;" in
  *";__wt_report_cwd;"*) ;;
  *) PROMPT_COMMAND=${PROMPT_COMMAND:+"$PROMPT_COMMAND; "}__wt_report_cwd ;;
esac

# Windows Terminal + WSL で pane ごとに tmux session を自動作成する
# tmux と Herdr の外側にいる shell のときだけ実行する
if [ -z "$TMUX" ] && [ -z "$HERDR_ENV" ] && [ -n "$WT_SESSION" ]; then
  __auto_tmux_session_name="w$$"
  exec tmux new-session -s "$__auto_tmux_session_name" \; \
    set-option -g allow-passthrough on \; \
    set-option -g mouse on \; \
    bind-key -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" \
      "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e; send-keys -M'" \; \
    set-option destroy-unattached on
fi
```

starship を使う場合は、このブロックを `eval "$(starship init bash)"` より後に置く。tmux 内シェルでは `$TMUX`、Herdr 管理下のシェルでは `$HERDR_ENV` が設定済みのため、再度 `exec tmux` されない。

## なぜ `trap` ではなく `destroy-unattached` を使うか

`exec tmux ...` で shell 自体を `tmux` client に置き換えるため、shell 側の `trap` に終了処理を持たせる設計は安定しない。

今回の用途では、session の寿命管理を `tmux` 自身に任せる方が単純で壊れにくい。

## session 名がデフォルト番号でなくなる理由

`tmux new-session -s ...` で名前を明示しているため。

- `tmux new-session`: `0`, `1`, `2` のようなデフォルト番号
- `tmux new-session -s w12345`: `w12345` が session 名

デフォルト番号は短いが、pane ごとにどの session か判別しづらい。今回の用途では `w$$` の方が扱いやすい。

## 確認手順

1. 新しい WSL shell を開く
2. `cd ~/workspace` などで移動する
3. Windows Terminal で pane を split する
4. 新しい pane が同じディレクトリ、かつ別の `tmux` session で始まることを確認する
5. ホイール上スクロールで tmux の履歴をスクロールできることを確認する
6. どちらかの pane で `tmux ls` を実行し、`w12345` のような session 名が見えることを確認する
7. その pane を `Ctrl+w` で閉じる
8. 残った pane で `tmux ls` を実行し、対応 session が消えていることを確認する

## 注意

- `WT_SESSION` を条件にしているため、Windows Terminal 以外では自動起動しない
- 既存の共有 session に attach する運用とは相性が違う
- `tl` を使いたい場合は `alias tl='tmux ls'` を `~/.bashrc.local` などに定義する
- 既存の tmux server が動いている場合でも、新しい pane 起動時に必要な tmux option は再設定される

## 関連ドキュメント

- `docs/tmux-setup/README.md`
- `docs/windows-terminal-settings/README.md`
- `docs/shell/README.md`
