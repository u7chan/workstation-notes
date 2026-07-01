# Herdr と Claude Code・Codex・OpenCode を連携する

Last reviewed: 2026-07-01

## 概要

Herdr の integration を導入し、Claude Code、Codex、OpenCode の状態を Herdr 上で管理できるようにする。

連携後は Herdr 画面左下の Agents に各エージェントが表示され、実行状況に応じて `working` / `idle` などのステータスが切り替わる。

## 確認環境

- WSL2
- Ubuntu
- Herdr 0.7.1
- Claude Code
- Codex CLI
- OpenCode

Herdr 自体の導入手順は [Herdr のセットアップ](../herdr-setup/README.md) を参照する。

## integration のインストール

各エージェントの integration をインストールする。

```bash
herdr integration install codex
herdr integration install opencode
herdr integration install claude
```

それぞれ次のファイルが作成または更新される。

| エージェント | 主な配置先 |
| - | - |
| Codex | `~/.codex/herdr-agent-state.sh`、`~/.codex/hooks.json`、`~/.codex/config.toml` |
| OpenCode | `~/.config/opencode/plugins/herdr-agent-state.js` |
| Claude Code | `~/.claude/hooks/herdr-agent-state.sh`、`~/.claude/settings.json` |

integration のファイルは Herdr が管理する。再インストールや更新で上書きされるため、独自の hook は別ファイルで管理する。

## インストール状態の確認

```bash
herdr integration status
```

導入した3つが `current` と表示されればよい。今回の確認結果は次のとおり。

```text
claude: current (v7) (/home/u7dev/.claude/hooks/herdr-agent-state.sh)
codex: current (v6) (/home/u7dev/.codex/herdr-agent-state.sh)
opencode: current (v7) (/home/u7dev/.config/opencode/plugins/herdr-agent-state.js)
```

バージョン番号は Herdr の更新により変わる可能性がある。

## 動作確認

integration の導入前から起動しているエージェントは終了し、新しいプロセスとして起動する。

作業ディレクトリで Herdr を起動する。

```bash
herdr
```

Herdr の各ペインでエージェントを起動する。

```bash
codex
```

```bash
opencode
```

```bash
claude
```

次の状態を確認する。

1. Herdr 画面左下の Agents に起動したエージェントが表示される
2. プロンプトを送信するとステータスが `working` になる
3. 応答が完了するとステータスが `idle` になる

別ターミナルから確認する場合は次を実行する。

```bash
herdr agent list
```

今回、Claude Code、Codex、OpenCode の3つすべてで Agents への表示とステータスの切り替えを確認できた。

## integration の削除

不要になった integration はエージェントごとに削除できる。

```bash
herdr integration uninstall codex
herdr integration uninstall opencode
herdr integration uninstall claude
```

既存設定へ追加された機能フラグなどが残る場合があるため、削除後は対象エージェントの設定ファイルも確認する。

## 参考

- [Herdr Integrations](https://herdr.dev/docs/integrations/)
