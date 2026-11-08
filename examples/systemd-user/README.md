# systemd-user examples

ユーザーユニットとして常駐させるサービスの設定例。

|ファイル|コピー先|用途|
|-|-|-|
|`hwc.service`|`~/.config/systemd/user/hwc.service`|HWC（Herdr の Web UI）を `0.0.0.0:30000` で常駐させ、落ちたら再起動する|

```bash
mkdir -p ~/.config/systemd/user
cp hwc.service ~/.config/systemd/user/hwc.service
systemctl --user daemon-reload
loginctl enable-linger "$USER"
systemctl --user enable --now hwc.service
```

背景と確認手順は `docs/hwc-autostart/README.md` を参照。

## 読み替えが要る箇所

- `WorkingDirectory=%h/workspace/hwc`: HWC のリポジトリを別の場所に置いている場合はパスを変える
- `Environment=PATH=...`: HWC が子プロセスで起動する `pi` / `gh` / `git` / `codex` の解決先を足す。ユニットの環境は対話シェルの `PATH` を引き継がないため、必要なものだけを明示する。`opencode` はバイナリを起動せずローカルサービスの情報を HTTP で読むので、PATH には不要

`%h` は systemd がユーザーのホームディレクトリへ展開する。ユーザー名を書かずに済むので、共有しやすい。
