# chezmoi で個人設定を配布する

Last reviewed: 2026-06-16

## 概要

このリポジトリでは、実配布する dotfiles を `chezmoi/` に置き、手順書や背景説明は `docs/` に置く。

- `chezmoi/`: 実際に `$HOME` へ展開する source
- `docs/`: 導入手順、依存ツール、運用ルール
- `examples/`: 個別設定の参照実装

v1 の対象環境は Windows 11 + WSL2 Ubuntu。

## 管理対象

`chezmoi` で配布する対象:

- `~/.bashrc`
- `~/.bashrc.local`
- `~/.bash_aliases`
- `~/.bash_functions`
- `~/.gitconfig`
- `~/.config/git/ignore`
- `~/.config/starship.toml`
- `~/.config/nvim/`

管理しない対象:

- `~/.ssh/`
- `~/.gnupg/`
- `~/.config/envs/*/.env`
- `gh auth login` が作る認証情報
- shell history や backup ファイル

## 初回セットアップ

### 1. 必要ツールを入れる

最低限の例:

```bash
sudo apt update
sudo apt install -y git curl ripgrep fd-find python3 python3-pip luarocks unzip gcc g++ make
```

追加で用意するもの:

- `chezmoi`
- `neovim 0.11.3+`
- `node` / `npm` または `nvm`
- `starship`
- `gh`
- Nerd Font
- `win32yank.exe`（WSL2 で Windows クリップボードと連携する場合）

`chezmoi` のインストールは公式手順を使う。
Ubuntu 標準パッケージの `neovim` は古いことがあるため、現行プラグイン構成では公式配布物か新しめの配布元を使う。
Ubuntu では `fd-find` の実行ファイル名が `fdfind` になるため、必要に応じて `~/.local/bin/fd` へのシンボリックリンクを作る。

### 2. source directory を指定して初期化する

```bash
chezmoi init --source ~/workspace/workstation-notes/chezmoi
chezmoi diff
chezmoi apply
```

### 3. secrets を手動配置する

API キー類は `chezmoi` に含めない。必要なものは手で置く。

例:

```bash
mkdir -p ~/.config/envs/<provider>
chmod 700 ~/.config/envs ~/.config/envs/<provider>
```

`.env` の例:

```dotenv
BASE_URL="https://api.example.com/anthropic"
API_KEY="replace-me"
MODEL="your-model"
```

作成後は権限を絞る。

```bash
chmod 600 ~/.config/envs/<provider>/.env
```

### 4. Neovim を初回同期する

`nvim` 初回起動時に `lazy.nvim` が bootstrap される。

```bash
nvim
```

その後に必要に応じて次を確認する。

- `:Lazy`
- `:Mason`
- `:TSInstallInfo`
- `:checkhealth`

## Neovim の依存

`lazy.nvim` と `lazy-lock.json` でプラグイン構成を再現する。

この構成は `neovim 0.11.3+` を前提にする。古いバージョンでは `nvim-lspconfig` の現行版を利用できない。

追加で必要になりやすいもの:

- `bash-language-server`
- `typescript-language-server`
- `vscode-langservers-extracted`
- `lua-language-server`

Node 系の LSP を入れる例:

```bash
npm install -g bash-language-server typescript typescript-language-server vscode-langservers-extracted
```

Lua LSP は Mason から入れてよい。

## Git アカウントを使い分ける

配布する `~/.gitconfig` は個人用 identity を既定値にし、`~/workspace/work/` 配下では `~/.gitconfig.work` を追加で読み込む。

仕事用 identity はリポジトリへ含めず、各端末で作成する。

```gitconfig
[user]
  name = Your Work Name
  email = you@example.com
```

別の配置先を使う場合は、`chezmoi/dot_gitconfig` の `includeIf` にある `gitdir` を変更する。これは commit の署名者を切り替える設定であり、GitHub の認証アカウント切替は `gh auth switch` や SSH host の設定を別途使う。

## 運用

- dotfiles 変更は `chezmoi/` の source を直接更新する
- 反映前に `chezmoi diff` を見る
- 反映は `chezmoi apply`
- 背景説明や依存手順は `docs/` に残す
- 共有しにくいローカル秘密情報は repo に入れない

## 関連

- `docs/shell/README.md`
- `docs/nvim-setup/README.md`
- `docs/starship-setup/README.md`
- `docs/herdr-setup/README.md`
- `docs/herdr-agent-integrations/README.md`
