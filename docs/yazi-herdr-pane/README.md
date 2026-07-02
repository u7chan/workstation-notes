# herdr から yazi を一時ペインで開く

Last reviewed: 2026-07-03

## 概要

herdr の `[[keys.command]]` + `type = "pane"` を使うと、tmux の `display-popup` のように一時ペインでコマンドを起動できる。yazi をこの仕組みで呼び出せば、どのペインからでもワンストロークでファイルブラウザが開ける。

## 背景

ターミナル上で作業中にファイル操作（コピー/削除/リネーム/プレビュー）が必要になったとき、`ls` / `cd` より yazi のほうが効率的。とはいえ普段は herdr 上でエージェントやシェルを使っているため、いちいち別ウィンドウや別ペインで yazi を起動するのは手間。

herdr の `type = "pane"` を使えば、ワンキーで yazi が一時ペインで開き、`q` で閉じれば元の作業にすぐ戻れる。

## 設定

`~/.config/herdr/config.toml` に以下を追記:

```toml
[[keys.command]]
key = "prefix+f"
type = "pane"
command = "yazi"
```

適用:

```bash
herdr server reload-config
```

この設定は chezmoi 管理対象（`chezmoi/dot_config/herdr/config.toml`）。

## 使い方

herdr 上のどのペインからでも `prefix+f`（デフォルトプレフィックスは `Ctrl+b`）で yazi が一時ペインとして開く。

| 操作 | 結果 |
|------|------|
| `prefix+f` | yazi が一時ペインで起動 |
| yazi 内で `q` | yazi 終了 → ペイン自動クローズ |

## 制限

一時ペインで起動する都合上、yazi のカレントディレクトリ変更は元ペインに伝播しない。ファイル操作（コピー/削除/リネーム/プレビュー/検索）に用途を絞るのがよい。

## 関連ドキュメント

- [yazi の導入](../yazi-setup/README.md)
