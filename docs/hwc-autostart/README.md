# HWC を常駐させる（systemd ユーザーユニット）

Last reviewed: 2026-11-08

## 概要

HWC は `bun run dev` を端末から起動する前提だったため、端末を閉じたときやプロセスが落ちたときに待受が消え、再開されなかった。systemd のユーザーユニットに載せて、落ちたら自動で戻る状態にする。

- 起動コマンドは `bun --watch src/server.ts`（`dev` と同じ）。リポジトリの main が更新されると自動で再起動する
- 落ちたら 3 秒後に再起動する（`Restart=always`）
- linger を有効にして、ログインしていなくても WSL の起動時に立ち上がるようにする

適用先:

- `~/.config/systemd/user/hwc.service`（`examples/systemd-user/hwc.service` をコピー）

## 前提

- WSL2 で systemd が有効（`/etc/wsl.conf` の `[boot] systemd=true`）
- HWC のリポジトリが `~/workspace/hwc` にある（別の場所なら `WorkingDirectory` を変える）
- `bun` が mise の shim から起動できる

## 手順

```bash
mkdir -p ~/.config/systemd/user
cp examples/systemd-user/hwc.service ~/.config/systemd/user/hwc.service
systemctl --user daemon-reload
loginctl enable-linger "$USER"
systemctl --user enable --now hwc.service
```

`loginctl enable-linger` が無いと、ログインしていない間はユーザーユニットが起動しない。WSL を起動しただけで待受を立てたい場合は必須。

## 確認

```bash
systemctl --user is-enabled hwc.service            # enabled
systemctl --user is-active hwc.service             # active
loginctl show-user "$USER" --property=Linger       # Linger=yes
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:30000/   # 200
```

落ちても戻ることは、プロセスを強制終了して確かめる。

```bash
kill -9 "$(systemctl --user show hwc.service -p MainPID --value)"
sleep 5
systemctl --user show hwc.service -p NRestarts --value             # 1 以上
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:30000/   # 200
```

## 停止とログ

```bash
systemctl --user stop hwc.service      # 一時停止
systemctl --user disable hwc.service   # 次回の WSL 起動でも起動しない
journalctl --user -u hwc.service -f
```

## 落とし穴

### WSL の再起動後に LAN から届かなくなる

WSL2 が NAT モードのとき、LAN への公開は Windows 側の portproxy が担う。転送先は WSL の IP を直接指すため、WSL の再起動で IP が変わると規則が古くなり、HWC が動いていてもスマートフォンから届かない。ユニットの再起動では直らない。

```bash
ip -4 -o addr show eth0
netsh.exe interface portproxy show all
```

転送先が現在の IP と違えば規則を貼り直す（管理者権限が要る）。portproxy を使わない mirrored ネットワークに切り替えればこの維持は不要になるが、他のポートの規則も含めて影響が出る。

### WSL 起動直後は表示が空

HWC は Herdr の socket から状態を取る。Herdr がまだ起動していない間も待受は続き、`herdr sync: ...` のエラーをログに出すだけ。Herdr を起動すれば購読が繋がり直し、状態を取り直す。

### 手元で `bun run dev` を起動しない

同じポート 30000 を取り合う。後から起動した側は `EADDRINUSE` で bind に失敗するが、`bun --watch` はプロセスが終了せず監視だけが残る（`bun src/server.ts` を直接起動した場合は exit 1）。

- 先に待受を取った側だけが応答する。ユニットが負けた場合は `active` のまま待受が立たない。`Restart=always` はプロセスの終了でしか働かないので、自動では戻らない
- 手元の dev を止めてから `systemctl --user restart hwc.service` で戻す
- 手元で動かしたいときは先に `systemctl --user stop hwc.service` する

### マージ直後に 1〜2 回再起動する

`bun --watch` はファイル変更のたびに再起動するため、main へのマージ中は一時的に中途半端な状態で立ち上がることがある。数秒で収束する。

## 見直すとき

- 起動コマンドを `bun run start`（watch 無し）へ変えたとき
- HWC のリポジトリを別のパスへ移したとき
- portproxy をやめて mirrored ネットワークへ切り替えたとき
- WSL の systemd 設定を変えたとき
