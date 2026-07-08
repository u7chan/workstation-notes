# yazi のテーマカスタマイズ

Last reviewed: 2026-07-02

## 概要

yazi の Catppuccin Mocha テーマをベースに、ファイルタイプ別アイコンの追加とフォルダ色の調整を行う方法。デフォルトの flavor では提供されない拡張子ベース・ファイル名ベースのアイコン（200+種）を追加し、フォルダの色を黄色基調に変更する。

## 背景

デフォルトの catppuccin-mocha flavor には `[icon.dirs]` と `[icon.conds]` しか含まれておらず、ファイル種別に応じたアイコン（Dockerfile → クジラ、package.json → npm など）が表示されない。また、フォルダ色が青で、開閉状態の切り替えもない。

## 前提

- yazi 26.5.6
- Nerd Font（アイコン表示に必要）
- Catppuccin flavor 導入済み

```bash
ya pkg add yazi-rs/flavors:catppuccin-mocha
ya pkg add yazi-rs/flavors:catppuccin-latte
```

```toml
# ~/.config/yazi/theme.toml（flavor 指定の最小構成）
[flavor]
dark = "catppuccin-mocha"
light = "catppuccin-latte"
```

ターミナルの背景色に応じて yazi がダーク/ライトを自動判定し、`[flavor] dark` / `[flavor] light` のテーマが適用される。

## やったこと

### 1. ファイルタイプ別アイコンの追加

catppuccin/yazi リポジトリのフルテーマ（`themes/mocha/catppuccin-mocha-lavender.toml`）から `[icon]` セクションを `theme.toml` に追記。これにより以下が追加される：

- `[icon.dirs]` — 特殊フォルダ用アイコン（.config, .git, Desktop など 14 種）
- `[icon.conds]` — 条件付きアイコン（dir, exec, link, orphan など）
- `[icon.files]` — ファイル名ベースのアイコン 200+ 種（package.json, Dockerfile, tsconfig.json, README.md など）
- `[icon.exts]` — 拡張子ベースのアイコン 300+ 種（.rs → Rust, .py → Python, .ts → TypeScript など）

### 2. フォルダ色の黄色化

flavor の `[filetype]` に `{ url = "*/", fg = "#89b4fa" }`（青）が定義されており、これが `[icon]` の色より優先される。`theme.toml` に `[filetype]` セクションを追記し、ディレクトリ fallback の前景色を `#f9e2af`（Catppuccin Yellow）に上書き。

### 3. フォルダの開閉アイコン

`[icon.conds]` に `{ if = "dir & hovered", text = "", fg = "#f9e2af" }` を追加し、カーソルがフォルダに乗ったときに開いたフォルダアイコンを表示。通常時は `{ if = "dir", text = "", fg = "#f9e2af" }` で閉じたフォルダ。

## 設定ファイル

dotfiles で管理するファイルは `~/.config/yazi/theme.toml`。

flavor のベーステーマを維持しつつ、ユーザー側の `theme.toml` で以下のセクションを上書き・追加する：

```toml
[flavor]
dark = "catppuccin-mocha"
light = "catppuccin-latte"

[filetype]
rules = [
	# Image
	{ mime = "image/*", fg = "#94e2d5" },
	# Media
	{ mime = "{audio,video}/*", fg = "#f9e2af" },
	# Archive
	{ mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}", fg = "#f5c2e7" },
	# Document
	{ mime = "application/{pdf,doc,rtf}", fg = "#a6e3a1" },
	# Virtual file system
	{ mime = "vfs/{absent,stale}", fg = "#9399b2" },
	# Fallback
	{ url = "*", fg = "#cdd6f4" },
	{ url = "*/", fg = "#f9e2af" },
]

[icon]
dirs = [
	{ name = ".config", text = "", fg = "#f9e2af" },
	{ name = ".git", text = "", fg = "#f9e2af" },
	{ name = ".github", text = "", fg = "#f9e2af" },
	{ name = ".npm", text = "", fg = "#f9e2af" },
	{ name = "Desktop", text = "", fg = "#f9e2af" },
	{ name = "Development", text = "", fg = "#f9e2af" },
	{ name = "Documents", text = "", fg = "#f9e2af" },
	{ name = "Downloads", text = "", fg = "#f9e2af" },
	{ name = "Library", text = "", fg = "#f9e2af" },
	{ name = "Movies", text = "", fg = "#f9e2af" },
	{ name = "Music", text = "", fg = "#f9e2af" },
	{ name = "Pictures", text = "", fg = "#f9e2af" },
	{ name = "Public", text = "", fg = "#f9e2af" },
	{ name = "Videos", text = "", fg = "#f9e2af" },
]
conds = [
	# Special files
	{ if = "orphan", text = "", fg = "#cdd6f4" },
	{ if = "link", text = "", fg = "#a6adc8" },
	{ if = "block", text = "", fg = "#f9e2af" },
	{ if = "char", text = "", fg = "#f9e2af" },
	{ if = "fifo", text = "", fg = "#f9e2af" },
	{ if = "sock", text = "", fg = "#f9e2af" },
	{ if = "sticky", text = "", fg = "#f9e2af" },
	{ if = "dummy", text = "", fg = "#f38ba8" },

	# Fallback
	{ if = "dir & hovered", text = "", fg = "#f9e2af" },
	{ if = "dir", text = "", fg = "#f9e2af" },
	{ if = "exec", text = "", fg = "#a6e3a1" },
	{ if = "!dir", text = "", fg = "#cdd6f4" },
]
# files と exts は別途 catppuccin/yazi の themes/mocha/catppuccin-mocha-lavender.toml から取得
```

`files` と `exts` は行数が多いため上記サンプルでは省略している。実際のファイルには `catppuccin/yazi` リポジトリの `themes/mocha/catppuccin-mocha-lavender.toml` から `[icon]` 配下の `files` と `exts` をコピーする。

## デバッグで判明したこと

| 問題 | 原因 | 解決 |
|------|------|------|
| `[icon.conds]` でフォルダ色を黄色に変更しても青のまま | `[filetype]` の `{ url = "*/" }` ルールがアイコンの前景色を上書きしている | `theme.toml` に `[filetype]` セクションを追加し、`{ url = "*/", fg = "#f9e2af" }` で上書き |
| フォルダにカーソルを合わせても開いたアイコンに変わらない | デフォルトの catppuccin-mocha flavor に `dir & hovered` のルールがない | `conds` に `{ if = "dir & hovered", text = "", fg = "#f9e2af" }` を追加 |

flavor のマージにおいて、ユーザーの `theme.toml` の各セクションは flavor の同名セクションを上書きする。ただし `[icon]` 内の個別ルールはマージされず、セクション全体が置き換わるため、必要な定義はすべてユーザー側に書く必要がある。

## 参考

- [catppuccin/yazi](https://github.com/catppuccin/yazi)
- [yazi-rs/flavors](https://github.com/yazi-rs/flavors)
- アイコンソース: [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
