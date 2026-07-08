# Windows Terminal settings

Windowsターミナルのキーバインド（カスタムメモ）

`+ボタン` > `設定` > `操作`

![terminal-settings](./images/terminal-settings.png)

|アクション|キーバインド|
|-|-|
|ペインを閉じる| ctrl+w|
|ペインの複製する, split: down| ctrl+shift+d|
|ペインの複製する, split: right| ctrl+d|

## WSLでペイン複製時にディレクトリを引き継ぐ

Windows Terminal + WSL の組み合わせでは、`.bashrc` に次の設定を追加すると、ペイン複製時にカレントディレクトリを引き継げる。

```bash
__wt_report_cwd() {
  local wpath
  wpath="$(wslpath -w "$PWD" 2>/dev/null)" || return
  printf '\e]9;9;%s\e\\' "$wpath"
}

case ";$PROMPT_COMMAND;" in
  *";__wt_report_cwd;"*) ;;
  *) PROMPT_COMMAND=${PROMPT_COMMAND:+"$PROMPT_COMMAND; "}__wt_report_cwd ;;
esac
```

設定後はシェルを再起動する。

この設定は Windows Terminal + WSL の場合に有効なカスタム。
