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

## tmux との使い分け

tmux は汎用の永続ターミナルセッションとして成熟している。Herdr は同じ領域を扱いながら、AI エージェントの状態集約、セッション復元用の連携、CLI / Socket API によるエージェントからの操作を追加している。

この環境では、どちらかへ一本化せず、起動元によって使い分ける。

| 起動元 | 使用するマルチプレクサー | 用途 |
| - | - | - |
| Zed / VS Code の統合ターミナル | tmux | 統合ターミナル内でエージェントを起動し、既存の tmux ベースのオーケストレーションを使う |
| Windows Terminal だけで作業する場合 | Herdr | 複数エージェントの状態確認、ワークスペース管理、detach / reattach を Herdr に任せる |

このため、Windows Terminal + WSL での tmux 自動起動設定は残す。Windows Terminal で通常どおりシェルを開いた後、必要なときだけ tmux から Herdr へ切り替える。

Herdr は tmux 内でも動作するが、ここでは二重に使わない。このリポジトリの tmux は prefix を `Ctrl+a`、Herdr は標準の `Ctrl+b` としているものの、session、pane、detach、マウス処理が二重になるため。

### Herdr ペイン内での tmux 自動起動を防ぐ

Herdr は管理下のペインへ `HERDR_ENV=1` を設定する。Herdr が起動した Bash で tmux が再び自動起動しないように、自動起動条件へ `HERDR_ENV` の確認を追加する。

```bash
if [ -z "$TMUX" ] && [ -z "$HERDR_ENV" ] && [ -n "$WT_SESSION" ]; then
  # tmux 自動起動
fi
```

### tmux から Herdr へ切り替える関数

tmux 3.4 の `detach-client -E` を使うと、現在の tmux client を切り離し、同じターミナルで Herdr を起動できる。

```bash
herdr() {
  local herdr_bin="$HOME/.local/bin/herdr"
  local replace_client=

  case "${1:-}" in
    ""|--session|--remote|--no-session)
      replace_client=1
      ;;
    session|agent|terminal)
      if [ "${2:-}" = "attach" ]; then
        replace_client=1
      fi
      ;;
  esac

  if [ -n "${TMUX:-}" ] && [ -z "${HERDR_ENV:-}" ] && [ -n "$replace_client" ]; then
    local cmd arg quoted

    printf -v cmd 'cd -- %q && %q' "$PWD" "$herdr_bin"

    for arg in "$@"; do
      printf -v quoted '%q' "$arg"
      cmd+=" $quoted"
    done

    # Herdr 終了後は Bash へ戻す。
    # .bashrc の自動起動により、新しい tmux session が始まる。
    cmd+='; exec bash -i'

    printf -v quoted '%q' "$cmd"
    tmux detach-client -E "bash -lc $quoted"
  else
    "$herdr_bin" "$@"
  fi
}
```

`detach-client -E` が起動するコマンドには、tmux ペイン内で移動したカレントディレクトリが自動では引き継がれない。そのため、関数内で `cd -- "$PWD"` 相当のコマンドを明示している。

この切り替えは、Windows Terminal の pane ごとに自動生成される、使い捨ての tmux session 専用とする。共有 session や複数 pane を持つ通常の tmux session で実行すると、`destroy-unattached on` によって session 全体と配下のプロセスが終了する可能性がある。

### エイリアス

tmux の `t` と対応させ、Herdr は `h` で起動する。

```bash
alias t='tmux'
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

`h`、`ha`、`hn` は上記の `herdr` 関数を呼ぶため、tmux の自動生成 session 内では tmux から Herdr へ切り替わる。`hl` や `hk` など画面をattachしない管理コマンドは、tmuxを維持したまま実行する。

## 参考

- [Herdr 公式サイト](https://herdr.dev/)
- [Install Herdr](https://herdr.dev/docs/install/)
- [Quick start](https://herdr.dev/docs/quick-start/)
- [Integrations](https://herdr.dev/docs/integrations/)
- [ogulcancelik/herdr](https://github.com/ogulcancelik/herdr)
