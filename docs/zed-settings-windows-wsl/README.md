# Zedユーザー設定パラメーターシート（Windows + WSL）

Last reviewed: 2026-06-27

対象:

- Windows版Zed
- WSL内のプロジェクト
- `%APPDATA%\Zed\settings.json`

## 目的

現在使用しているZedユーザー設定について、設定値と採用理由を記録する。

コピー用の設定全体は `examples/zed/settings.windows-wsl.jsonc` を参照。

## 起動・ワークスペース

|パラメーター|設定値|目的・採用理由|
|-|-|-|
|`restore_on_startup`|`last_workspace`|Zed起動時に前回のワークスペースを復元し、作業を再開しやすくする|
|`cli_default_open_behavior`|`existing_window`|WSLから`zed <path>`を実行したとき、新しいウィンドウを増やさず既存ウィンドウを使う|

`cli_default_open_behavior` は同じフォルダの二重オープンを検出する設定ではない。CLIから開く際に既存ウィンドウを利用するための設定。

## テーマ・フォント

|パラメーター|設定値|目的・採用理由|
|-|-|-|
|`theme.mode`|`dark`|常にダークテーマを使用する|
|`theme.dark`|`Ayu Mirage`|エディタのダークテーマとして使用する|
|`theme.light`|`One Light`|ライトモードへ変更した場合のテーマを定義しておく|
|`icon_theme.mode`|`dark`|アイコンも常にダークモード向けにする|
|`icon_theme.dark`|`Catppuccin Frappé`|ダークモード時のアイコンテーマとして使用する|
|`icon_theme.light`|`Catppuccin Latte`|ライトモードへ変更した場合のアイコンテーマを定義しておく|
|`ui_font_size`|`16`|メニューやパネルなど、UI全体の文字サイズを調整する|
|`buffer_font_family`|`CodeNewRoman Nerd Font Mono`|エディタ本文にNerd Font対応の等幅フォントを使用する|
|`buffer_font_size`|`15`|エディタ本文の文字サイズを調整する|

## 編集

|パラメーター|設定値|目的・採用理由|
|-|-|-|
|`format_on_save`|`off`|保存時に意図しない整形が走らないよう、自動フォーマットを無効にする|

## パネル配置

|パラメーター|設定値|目的・採用理由|
|-|-|-|
|`project_panel.dock`|`left`|ファイルツリーを左側に配置する|
|`outline_panel.dock`|`left`|シンボル一覧をファイルツリーと同じ左側に配置する|
|`git_panel.dock`|`right`|Git操作を右側に分離する|
|`collaboration_panel.button`|`false`|使用しないコラボレーションパネルのボタンを非表示にする|

## AIエージェント

|パラメーター|設定値|目的・採用理由|
|-|-|-|
|`agent.sidebar_side`|`right`|エージェント用サイドバーを右側に配置する|
|`agent.dock`|`right`|エージェントパネルを右側に配置する|
|`agent.favorite_models`|`[]`|お気に入りモデルを固定せず、必要に応じて選択する|
|`agent.model_parameters`|`[]`|モデル固有の追加パラメーターを設定しない|
|`agent_servers.codex-acp.type`|`registry`|Codex ACPをZedのレジストリ経由で利用する|
|`agent_servers.claude-acp.type`|`registry`|Claude ACPをZedのレジストリ経由で利用する|
|`agent_servers.opencode.type`|`registry`|OpenCodeをZedのレジストリ経由で利用する|

## 言語サーバー

|パラメーター|設定値|目的・採用理由|
|-|-|-|
|`languages.CSS.language_servers`|`["tailwindcss-intellisense-css"]`|Tailwind CSS v4 の `@theme` ディレクティブをビルトイン CSS LSP が認識しないため、Tailwind 用 LSP に切り替える|

### 背景

Tailwind CSS v4 は `@import 'tailwindcss'` と `@theme { ... }` でテーマを定義する。Zed のビルトイン CSS LSP (vscode-css-language-server) は `@theme` を認識せず `Unknown at rule @theme` 警告を出す。CSS に対して `tailwindcss-intellisense-css` を使うことで、警告を抑制しつつ Tailwind の補完も有効になる。

## ターミナル

|パラメーター|設定値|目的・採用理由|
|-|-|-|
|`terminal.shell.program`|`wsl.exe`|Windows版Zedの内蔵ターミナルでWSLを起動する|
|`terminal.working_directory`|`first_project_directory`|新しいターミナルを、ワークスペース内の最初のプロジェクトルートで起動する|

`terminal.working_directory` の既定値は `current_project_directory`。現在開いているファイルを基準にするため、Zedのユーザー設定ファイルを表示した状態でターミナルを作り直すと、次のWindows側ディレクトリで起動する場合があった。

```text
/mnt/c/Users/<username>/AppData/Roaming/Zed
```

`first_project_directory` に変更することで、設定ファイルやアクティブなタブに左右されず、最初に開いたプロジェクトのルートを使用する。たとえばWSL内のプロジェクトを開いている場合は次のような場所になる。

```text
/home/<username>/workspace/<project-name>
```

なお、`wsl.exe` の引数に `~` を指定するとプロジェクトルートを引き継げないため、`args: ["~"]` は設定しない。

## 設定ファイル

設定の実体は [`examples/zed/settings.windows-wsl.jsonc`](../../examples/zed/settings.windows-wsl.jsonc) を参照。

## 参考

- [Zed: Configuring Zed](https://zed.dev/docs/configuring-zed)
- [Zed: Terminal](https://zed.dev/docs/terminal)
- [Zed: Windows & Projects](https://zed.dev/docs/windows-and-projects)
