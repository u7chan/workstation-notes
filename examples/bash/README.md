## bashrc

Bash 関連のコピーベース設定例。

README はファイルの用途と配置先だけを説明し、実際にコピーする内容は個別ファイルに分けて管理する。

| ファイル | コピー先 | 用途 |
| --- | --- | --- |
| `bashrc.wsl-ubuntu` | `~/.bashrc` | WSL Ubuntu 向けのフル `.bashrc` サンプル |
| `bashrc.local` | `~/.bashrc.local` | 個人ローカル設定の読み込み口とツール初期化 |
| `bash_aliases` | `~/.bash_aliases` | alias 定義 |
| `bash_functions` | `~/.bash_functions` | Bash 関数定義 |
| `bashrc.tmux-auto-session` | `~/.bashrc` 末尾 | Windows Terminal + WSL で pane ごとに `tmux` session を自動作成する追加設定 |

## 使い分け

新しい環境をまとめて整える場合は `bashrc.wsl-ubuntu` を `~/.bashrc` にコピーする。

既存の `.bashrc` を維持したまま tmux 自動起動だけ追加したい場合は、`bashrc.tmux-auto-session` の内容を `~/.bashrc` の末尾に追記する。

個人用の alias は `bash_aliases`、関数は `bash_functions` に寄せる。`bashrc.local` はそれらを読み込む入口として使う。`bashrc.wsl-ubuntu` は `~/.bashrc.local` が存在する場合に読み込む。

## 関連ドキュメント

- `docs/shell/README.md`
- `docs/windows-terminal-settings/README.md`
- `docs/windows-terminal-wsl-tmux-auto-session/README.md`
- `docs/tmux-setup/README.md`
