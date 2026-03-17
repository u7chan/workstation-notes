# Neovim で catppuccin Mocha を使う

## 概要

Neovim に `catppuccin/nvim` を追加し、Theme を `Mocha` に固定する手順。

この手順は、素の package 構成で `~/.local/share/nvim/site/pack/plugins/start` にプラグインを配置している前提。

公式:

https://github.com/catppuccin/nvim

## 追加した内容

- `catppuccin/nvim` を `~/.local/share/nvim/site/pack/plugins/start/catppuccin` に追加
- `~/.config/nvim/init.lua` に `Mocha` 用の設定を追加
- あとで消しやすいように、`catppuccin` の設定は区切りコメント付きで追加

## 手順

### 1. プラグイン配置先を確認する

```bash
mkdir -p ~/.local/share/nvim/site/pack/plugins/start
```

### 2. `catppuccin/nvim` を追加する

```bash
git clone --depth=1 https://github.com/catppuccin/nvim.git \
  ~/.local/share/nvim/site/pack/plugins/start/catppuccin
```

### 3. `init.lua` に設定を追加する

`~/.config/nvim/init.lua` に次のブロックを追加する。

```lua
-- catppuccin theme start
local ok, catppuccin = pcall(require, "catppuccin")
if ok then
  catppuccin.setup({
    flavour = "mocha",
  })
  vim.cmd.colorscheme("catppuccin")
end
-- catppuccin theme end
```

`pcall(require, "catppuccin")` にしているので、未導入時でも `init.lua` 全体が即エラーで止まりにくい。

### 4. 起動確認をする

```bash
nvim
```

起動後に `Mocha` 系の配色になっていれば反映完了。

## 現在の `init.lua` 例

今回の構成では、`catppuccin` の追加箇所は次のようになる。

```lua
-- 既存の設定
...

-- catppuccin theme start
local ok, catppuccin = pcall(require, "catppuccin")
if ok then
  catppuccin.setup({
    flavour = "mocha",
  })
  vim.cmd.colorscheme("catppuccin")
end
-- catppuccin theme end

-- 既存の設定
...
```

## 補足

- `catppuccin` を外したくなったら、`init.lua` の `catppuccin theme start` から `catppuccin theme end` までをまとめて削除すればよい
- プラグイン本体も不要なら、`~/.local/share/nvim/site/pack/plugins/start/catppuccin` を削除する
