# VSCode で Shift+Tab がフォーカス移動になってしまう問題を直す

前提:

- VSCode

## 概要

`Ctrl+M` を誤って押すと「Tab Moves Focus」モードが有効になり、Tab / Shift+Tab がインデント操作ではなくフォーカス移動に変わってしまう。コーディングエージェント（Claude Code 等）の Shift+Tab キーバインドも効かなくなる。

## 応急処置

`Ctrl+M` をもう一度押してトグルオフする。

## 恒久対策

`Ctrl+M` 自体を無効化して、誤爆を防ぐ。

### 1. `keybindings.json` を開く

`Ctrl+Shift+P` でコマンドパレットを開き、`Preferences: Open Keyboard Shortcuts (JSON)` を実行する。

### 2. 設定を追加する

`keybindings.json` に次の設定を追加する。

```json
{
  "key": "ctrl+m",
  "command": "-editor.action.toggleTabFocusMode"
}
```

キーの前に `-` を付けることで、既定のキーバインドを無効化できる。

## 補足

- この設定は `Ctrl+M` のキーバインドを削除するだけなので、コマンドパレットから `Toggle Tab Key Moves Focus` を手動で実行することは引き続き可能。
