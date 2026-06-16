# Neovim のセットアップ

Last reviewed: 2026-06-16

## 概要

このリポジトリでは、Neovim 設定本体を `chezmoi/dot_config/nvim/` で管理する。

- 設定配布: `chezmoi`
- プラグイン管理: `lazy.nvim`
- LSP 管理: `mason.nvim`

Windows 11 + WSL2 Ubuntu を前提にする。

## 前提

- `neovim 0.10+`（推奨 0.11+）
- `git`
- `curl`
- `ripgrep`
- `fd`
- `python3`
- `gcc` / `g++` / `make`
- Nerd Font

インストール例:

```bash
sudo apt update
sudo apt install -y git curl ripgrep fd-find python3 unzip gcc g++ make
```

Ubuntu 標準パッケージの `neovim` は古いことがある。現行の `lazy.nvim` / `nvim-lspconfig` / `nvim-treesitter` 構成では `0.10+` を使う。

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

## 関連

- `docs/chezmoi-setup/README.md`
- `docs/starship-setup/README.md`
