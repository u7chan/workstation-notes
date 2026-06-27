# Zed で Windows 向けにターミナル分割とクローズのショートカットを設定する

Last reviewed: 2026-06-27

前提:

- Windows
- Zed

## 概要

Zed のターミナルで、次のショートカットを使えるようにするメモ。

- `Ctrl+D`: ターミナルを左右分割
- `Ctrl+Shift+D`: ターミナルを上下分割
- `Ctrl+W`: アクティブなターミナルを閉じる

`keymap.json` に `Terminal` コンテキスト付きで設定するため、ターミナルにフォーカスがあるときだけ効く。エディタ側のショートカットには影響しない。

## 手順

### 1. `keymap.json` を開く

Zed のユーザー設定ファイル `%APPDATA%\\Zed\\keymap.json` を開く。

実体のパスは通常次のようになる。

`C:\\Users\\<username>\\AppData\\Roaming\\Zed\\keymap.json`

### 2. `Terminal` コンテキストの設定を追加する

`keymap.json` が JSON 配列になっていることを確認し、次の設定を追加する。

```jsonc
// Zed keymap
//
// For information on binding keys, see the Zed
// documentation: https://zed.dev/docs/key-bindings
//
// To see the default key bindings run `zed: open default keymap`
// from the command palette.
[
  {
    "context": "Terminal",
    "bindings": {
      "ctrl-d": "pane::SplitRight",
      "ctrl-shift-d": "pane::SplitUp",
      "ctrl-w": "pane::CloseActiveItem"
    },
    "unbind": {
      "ctrl-shift-d": "debug_panel::ToggleFocus",
      "ctrl-shift-5": "pane::SplitRight",
      "ctrl-k up": "pane::SplitUp"
    }
  }
]
```

すでに他の設定がある場合は、配列の中にこのオブジェクトを追加する。

## 設定内容

|ショートカット|動作|条件|
|-|-|-|
|`Ctrl+D`|ターミナルを左右分割|ターミナルにフォーカスがあるとき|
|`Ctrl+Shift+D`|ターミナルを上下分割|ターミナルにフォーカスがあるとき|
|`Ctrl+W`|アクティブなターミナルを閉じる|ターミナルにフォーカスがあるとき|

## 補足

- `Terminal` コンテキスト付きのため、エディタ上の `Ctrl+D`、`Ctrl+Shift+D`、`Ctrl+W` には影響しない。
- ターミナル内では `Ctrl+D` の既定動作がこの設定で上書きされる。
- `Ctrl+Shift+D` に割り当てられている `debug_panel::ToggleFocus` は、上下分割との競合を避けるためアンバインドしている。
- Zed 既定の分割ショートカットである `Ctrl+Shift+5` と `Ctrl+K Up` はアンバインドしている。
- 反映されない場合は Zed の再読み込みまたは再起動を試す。
