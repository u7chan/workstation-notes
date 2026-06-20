# Neovim のセットアップ

Last reviewed: 2026-06-20

## 概要

このリポジトリでは、Neovim 設定本体を `chezmoi/dot_config/nvim/` で管理する。

- 設定配布: `chezmoi`
- プラグイン管理: `lazy.nvim`
- LSP 管理: `mason.nvim`

Windows 11 + WSL2 Ubuntu を前提にする。

## 前提

- `neovim 0.11.3+`
- `git`
- `curl`
- `ripgrep`
- `unzip`
- C compiler / `make`
- Nerd Font
- `win32yank.exe`（WSL2 で Windows クリップボードと連携する場合）

不足している必須パッケージのインストール例:

```bash
sudo apt update
sudo apt install -y git curl ripgrep unzip build-essential
```

`apt` は導入済みパッケージを再インストールしないため、Ubuntu に最初から入っているものが含まれていても問題ない。

必要に応じて追加するもの:

- `fd-find`: Telescope の file search を高速化する
- `python3`: Python provider を使う場合に必要

```bash
sudo apt install -y fd-find python3
```

`~/.local/bin` に配置したコマンドを利用できるよう、PATH に含まれていることを確認する。

```bash
case ":$PATH:" in
  *":$HOME/.local/bin:"*) echo "PATH configured" ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
```

このリポジトリの `chezmoi/dot_bashrc` には同じ PATH 設定が含まれる。`chezmoi apply` 後にターミナルを開き直すと、以降のシェルでも有効になる。

Ubuntu では `fd-find` のコマンド名が `fdfind` になるため、`fd` として使う場合はシンボリックリンクを作る。

```bash
mkdir -p ~/.local/bin
ln -s /usr/bin/fdfind ~/.local/bin/fd
```

Ubuntu 標準パッケージの `neovim` は古いことがある。現行の `nvim-lspconfig` が要求するバージョンに合わせ、`0.11.3+` を使う。

公式配布版を使う場合は、展開先を `~/.local/opt/nvim-<version>/`、実行ファイルのリンクを `~/.local/bin/nvim` にすると、apt 版を残したまま切り替えられる。

WSL2 のクリップボード連携には `win32yank` の x64 リリースを利用できる。展開した `win32yank.exe` を `~/.local/bin/` に置き、次のコマンドで認識されることを確認する。

```bash
command -v win32yank.exe
win32yank.exe -o --lf >/dev/null
```

## 現在の環境への適用記録

2026-06-20 に Ubuntu 24.04.4 LTS / WSL2 へ次を適用した。

- Neovim `0.12.3`
  - 公式 `nvim-linux-x86_64.tar.gz` を使用
  - SHA-256を検証
  - 配置先: `~/.local/opt/nvim-v0.12.3/`
  - 実行パス: `~/.local/bin/nvim`
- win32yank `0.1.1`
  - 公式 `win32yank-x64.zip` を使用
  - 配置先: `~/.local/bin/win32yank.exe`
- build-essential `12.10ubuntu1`
- fd-find `9.0.0-1`
  - `~/.local/bin/fd` から `/usr/bin/fdfind` を参照
- lua-language-server `3.18.2`
  - Mason で導入
- bash-language-server `5.6.0`
- typescript-language-server `5.3.0`
- TypeScript `6.0.3`
- vscode-langservers-extracted `4.10.0`
  - Node 系の4パッケージは npm のグローバル領域へ導入

確認結果:

```text
$ nvim --version
NVIM v0.12.3

$ fd --version
fdfind 9.0.0

$ command -v win32yank.exe
/home/u7dev/.local/bin/win32yank.exe
```

現在の設定を使った headless 起動と、WSL・win32yank の実行可能判定が成功することを確認済み。
Lua ファイルを開いた状態で `lua-language-server` が起動できることも確認済み。

## 適用方法

`chezmoi` で dotfiles を反映する。

```bash
chezmoi init --source ~/workspace/workstation-notes/chezmoi
chezmoi apply
```

反映される設定先:

- `~/.config/nvim/init.lua`
- `~/.config/nvim/lua/config/*.lua`
- `~/.config/nvim/lua/plugins/*.lua`
- `~/.config/nvim/lazy-lock.json`

## 初回起動

```bash
nvim
```

初回起動時に `lazy.nvim` が bootstrap され、`lazy-lock.json` に沿ってプラグインが同期される。

確認コマンド:

- `:Lazy`
- `:Mason`
- `:TSInstallInfo`
- `:checkhealth`
- `:checkhealth vim.lsp`

## LSP / Treesitter

この設定で使う主な LSP:

- `lua_ls`
- `ts_ls`
- `jsonls`
- `bashls`

Node 系 LSP を先に入れる例:

```bash
npm install -g bash-language-server typescript typescript-language-server vscode-langservers-extracted
```

`lua_ls` は `:Mason` から入れてよい。

Treesitter は `nvim-treesitter` を使う。`build = ":TSUpdate"` を設定しているため、初回同期時または更新時に parser 更新が走ることがある。

## 主なキーマップ

- `<leader>e`: file tree の開閉
- `<leader>o`: file tree へフォーカス
- `<leader>ff`: file search
- `<leader>fg`: live grep
- `<leader>m`: Mason
- `<leader>ti`: Treesitter install info
- `gd`, `gr`, `K`: LSP ナビゲーション

## 補足

- `fd` コマンドは Ubuntu では `fdfind` 名で入ることがある
- クリップボード連携が効かない場合は `:checkhealth` で provider を確認する
- フォント未設定だと devicons や starship の記号が崩れる

### Nerd Font を設定する

Nerd Font は WSL 側ではなく Windows 側へインストールし、Neovim を表示するターミナルに設定する。

- Windows Terminal: 対象プロファイルの「外観」からフォントフェイスを変更する
- VSCode: `terminal.integrated.fontFamily` にインストール済みの Nerd Font 名を設定する

VSCode の `settings.json` の例:

```json
"terminal.integrated.fontFamily": "Hack Nerd Font"
```

設定後にターミナルを開き直し、`nvim` で devicons が文字化けせず表示されることを確認する。

## 関連

- `docs/chezmoi-setup/README.md`
- `docs/starship-setup/README.md`
