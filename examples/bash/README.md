## bashrc

Bash 関連のコピーベース設定例。

README はファイルの用途と配置先だけを説明し、実際にコピーする内容は個別ファイルに分けて管理する。

| ファイル | コピー先 | 用途 |
| --- | --- | --- |
| `bashrc.wsl-ubuntu` | `~/.bashrc` | WSL Ubuntu 向けのフル `.bashrc` サンプル |
| `bashrc.local` | `~/.bashrc.local` | 個人ローカル設定の読み込み口とツール初期化 |
| `bash_aliases` | `~/.bash_aliases` | alias 定義 |
| `bash_functions` | `~/.bash_functions` | Bash 関数定義 |

## 使い分け

新しい環境をまとめて整える場合は `bashrc.wsl-ubuntu` を `~/.bashrc` にコピーする。

個人用の alias は `bash_aliases`、関数は `bash_functions` に寄せる。`bashrc.local` はそれらを読み込む入口として使う。`bashrc.wsl-ubuntu` は `~/.bashrc.local` が存在する場合に読み込む。

## 関連ドキュメント

- `docs/shell/README.md`
- `docs/windows-terminal-settings/README.md`
- `docs/herdr-setup/README.md`
