# 個人設定の管理方針

Last reviewed: 2026-06-16

## 基本方針

個人設定は次の 3 層で分けて管理する。

1. `chezmoi`: `$HOME` に展開する実設定
2. `docs`: 導入手順、前提、設計意図
3. `examples`: 最小の参照実装

## 置き場所のルール

- 実配布するファイルは `chezmoi/` に置く
- 手順書は `docs/` に置く
- 実配置先にそのまま置かないサンプルは `examples/` に置く

## secrets の扱い

- API キー、トークン、秘密鍵は `chezmoi` に入れない
- `~/.config/envs/*/.env` のような別管理に寄せる
- 権限は `600` を基本にする

## OS 依存の扱い

v1 は Windows 11 + WSL2 Ubuntu に寄せる。

- WSL 固有挙動は dotfiles に入れてよい
- GUI 設定やフォント導入は docs に分離する
- 将来 macOS や素の Linux を扱う場合は、その時点で template 化を検討する

## 更新フロー

1. `chezmoi/` の source を更新する
2. `chezmoi diff` で差分を見る
3. `chezmoi apply` で反映する
4. 関連する `docs/` を更新する

## 対象外

次は v1 の管理対象外とする。

- 認証済み state
- shell history
- キャッシュ
- backup ファイル
- プラグイン本体やバイナリ本体
