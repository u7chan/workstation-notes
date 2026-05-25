# Bash 設定の管理

Last reviewed: 2026-05-25

## 概要

Bash 関連の設定は、実際の配置先とリポジトリ内の管理名を分ける。

- 実配置先: `~/.bashrc`, `~/.bashrc.local`
- 管理用サンプル: `examples/bash/bashrc`, `examples/bash/bashrc.local`

`docs` では役割と適用先を説明し、設定例そのものは `examples` で管理する。

## 役割分担

### `~/.bashrc`

- 共通の初期化処理を置く
- `~/.bashrc.local` を条件付きで読み込む
- WSL 判定、SSH エージェント、共通 alias、PATH のような土台を持たせる

### `~/.bashrc.local`

- 個人用 alias、関数、プロンプト、任意のツール設定を置く
- 変更頻度が高い設定をこちらへ寄せる
- LiteLLM 関連 env もここから読み込む

## Git ブランチクリーンアップ関数

`~/.bashrc.local` には Git ブランチの掃除用関数が 3 つ定義されている。

### `gc`

リモートで削除済み（`: gone]`）のブランチをローカルから削除する。

- 確認なしで即削除する
- 削除後、まだリモートに存在するブランチを警告表示する

### `gc2`

`git fetch origin main:main` → `git switch main` → `gc` の順に実行する。

- main にいる場合は `git pull` だけ
- main にいない場合は fetch で main を更新 → switch → gc

### `agent-gc`

Codex / スキルが作成したワークツリーとブランチを一括掃除する。`gc` の機能（リモート削除済みブランチの削除）も内包している。

```bash
agent-gc                 # dry-run（削除せずに対象を表示）
agent-gc -y              # 削除を実行
agent-gc -y -f           # 未マージ/dirty も強制削除
```

**掃除対象:**

| 対象 | 検出方法 |
|------|---------|
| Agent ワークツリー | `*-worktrees/` 配下, `/tmp/*-pr` 配下 |
| Agent ブランチ | `codex/pr*`, `pr-*`, `ci-fix-pr-*`（マージ済みのみ） |
| リモート削除済みブランチ | `git branch -vv` の `: gone]` 検出 |

**前提条件:**
- ワーキングツリーがクリーン（`git status --porcelain -uno` が空）
- `main` に switch できること

### 使い分け

| 状況 | 使うコマンド |
|------|------------|
| 開発が一区切りした、リポジトリをきれいにしたい | `agent-gc -y` |
| メインに戻ってリモート追跡切れだけ掃除したい | `gc2` |
| リモート追跡切れのブランチだけ即削除したい | `gc` |

### `agent-gc` の実装背景

monorepo ではワークツリーが `$root/projects/<project>-worktrees/` に作られるため、リポジトリルート直下の兄弟ディレクトリだけを見ていた旧実装では検出漏れが発生した。`project_wt_parent` 変数を追加し、monorepo 内のプロジェクト単位ワークツリーも検出対象としている。

## このリポジトリでの参照元

- `examples/bash/bashrc`
- `examples/bash/bashrc.local`

## 関連ドキュメント

- `docs/starship-setup/README.md`
- `docs/windows-terminal-settings/README.md`

これらの手順書で出てくる `.bashrc` は、実際の適用先として読む。

## 更新ルール

1. まずこのページで背景と適用方針を更新する
2. 次に `examples/bash/` 配下の対応ファイルを更新する
3. 過去の断片メモを増やしすぎず、現在の推奨に寄せる
