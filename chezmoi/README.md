# chezmoi source

このディレクトリは `chezmoi` の source directory として使う。

初回セットアップ例:

```bash
chezmoi init --source ~/workspace/workstation-notes/chezmoi
chezmoi diff
chezmoi apply
```

運用ルール:

- 実配布する dotfiles だけを置く
- secrets は置かない
- OS 依存の導入手順は `docs/` 側に書く
- 更新は source を編集してから `chezmoi diff` / `chezmoi apply` で確認する
