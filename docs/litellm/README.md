# LiteLLM 設定の管理

Last reviewed: 2026-03-23

## 概要

LiteLLM 関連の設定は workstation-config 側で一元管理している。

- 実配置先: `~/.litellm-proxy.secrets`, `~/.litellm-models`

## 読み込み関係

- `~/.bashrc.local` から `~/.litellm-proxy.secrets` を読む
- 続けて `~/.litellm-models` を読む
- API キー本体やローカル URL は、実ファイル側で上書きする

## 運用ルール

- 秘密情報の実体は追跡しない
- モデル名やデフォルトの推奨が変わったら、このページを更新する
