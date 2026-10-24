# fontconfig examples

Chromium 系ツールの CJK フォールバックを日本語字形に固定するためのコピー用設定例。

|ファイル|コピー先|用途|
|-|-|-|
|`fonts.conf`|`~/.config/fontconfig/fonts.conf`|`serif` / `sans-serif` / `monospace` の解決順で Noto CJK JP を中国語フォント（WenQuanYi Zen Hei）より前に置き、Latin は DejaVu のまま残す|

```bash
sudo apt install fonts-noto-cjk
mkdir -p ~/.config/fontconfig
cp fonts.conf ~/.config/fontconfig/fonts.conf
fc-match -s sans-serif | grep -E 'Noto Sans CJK JP|WenQuanYi' | head -2
```

`fonts-noto-cjk` を入れても、それだけでは直らない。パッケージが入れる `70-fonts-noto-cjk.conf` は `lang=ja` 条件のルールで、Chromium の CJK フォールバックには効かない。この `fonts.conf` とセットで使う。

既存の `~/.config/fontconfig/fonts.conf` がある場合は置き換えず、`<alias>` のブロックだけを追記する。

背景と検証結果は `docs/wsl-japanese-font-fallback/README.md` を参照。
