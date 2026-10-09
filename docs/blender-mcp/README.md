# Blender MCP を WSL2 の Pi から使う（Blender は Windows ホスト）

Last reviewed: 2026-10-09

## 概要

Windows ホストに入れた Blender を、WSL2 上の Pi から MCP 経由で操作できる。実測で「シーン情報の取得」「オブジェクトの追加」「レンダリング画像の確認」まで通った。

素直には繋がらない点が 1 つあり、そこだけ対処が必要。

1. Blender アドオン（MCP for Blender）は socket を `127.0.0.1` にしか開かない
2. WSL2 の既定（NAT モード）からは Windows 側の loopback に到達できない
3. そのため Windows 側に小さな TCP リレー（`0.0.0.0:9877` → `127.0.0.1:9876`）を置いて中継する

`look`（viewport スクリーンショット系）はこの構成では動かない。理由と代替手順は「できないこと・注意」に書く。

対象:

- Windows ホスト上の Blender（Microsoft Store 版）
- WSL2（NAT モード）上の Pi と `uvx`
- 接続方式は `examples/blender-mcp/` のリレーを常駐させる前提

## 確認環境

| 項目 | 内容 |
| --- | --- |
| OS | Windows 11（10.0.26300.9457）+ WSL 3.0.1.0（kernel 6.18.40.1-microsoft-standard-WSL2） |
| WSL ディストロ | Dev-Ubuntu-26.04。ネットワークは NAT モード（`/etc/wsl.conf`・`.wslconfig` にネットワーク設定の追加なし） |
| Blender | 5.2.2 LTS（Microsoft Store 版 `BlenderFoundation.Blender` 5.2.2.0、Python 3.13.13） |
| Blender アドオン | MCP for Blender v1.8（`bl_info` の version `(1, 8)` / protocol 13） |
| MCP サーバー | `mcp-for-blender` 2.1.9（`uvx mcp-for-blender`） |
| uv | 0.11.26（WSL 側） |
| MCP クライアント | Pi 1.1.0（`~/.pi/agent/mcp.json`、exposure は既定の `codemode`） |

## なぜリレーが必要か

実測した到達性は次のとおり。WSL からは Windows 側の loopback に閉じた待ち受けだけが届かない。

| Windows 側の待ち受け | WSL からの到達 |
| --- | --- |
| `0.0.0.0` に bind したポート | 到達できる |
| `127.0.0.1` に bind したポート | 到達できない（timeout） |
| Blender アドオンの socket | `127.0.0.1:9876` 固定 |

アドオン側の bind 先は `BlenderMCPServer(host='localhost', port=9876)` として固定で、UI・環境変数・シーン設定のいずれでも変更できない（ポートのみ UI で変更可）。変更できるのは MCP サーバー側の接続先（`BLENDER_HOST` / `BLENDER_PORT`）だけなので、間をリレーで埋める。

```
Pi (WSL) ──stdio──> mcp-for-blender (WSL, uvx)
                        │  TCP 172.25.128.1:9877
                        ▼
                 relay.ps1 (Windows, 0.0.0.0:9877)
                        │  TCP 127.0.0.1:9876
                        ▼
                 Blender 5.2.2 LTS + MCP for Blender (Windows)
```

`BLENDER_HOST` に書く IP は WSL から見た Windows ホスト、つまり WSL のデフォルトゲートウェイ。`ip route show default | awk '{print $3}'` で確認できる（この環境では `172.25.128.1`）。

リレーの待ち受けポートに `9877` を使うのは、アドオンが `9876` を掴んでいるため。

## セットアップ

### 1. uv を WSL に入れる

MCP サーバーは `uvx` で起動する。未導入なら公式インストーラで入れる（この環境では導入済み 0.11.26）。

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 2. Blender にアドオンを入れる

Microsoft Store 版は `%APPDATA%` がリダイレクトされるため、アドオンの実パスは次の形になる。

```text
%LOCALAPPDATA%\Packages\<PackageFamilyName>\LocalCache\Roaming\Blender Foundation\Blender\<BlenderVersion>\scripts\addons\
```

この環境では次のパスに `blender_mcp.py` として置いた（ファイル名は上流の `install-addon` に合わせる）。

```text
C:\Users\unaga\AppData\Local\Packages\BlenderFoundation.Blender_ppwjx1n5r4v9t\LocalCache\Roaming\Blender Foundation\Blender\5.2\scripts\addons\blender_mcp.py
```

`<PackageFamilyName>` は `(Get-AppxPackage -Name *Blender*).PackageFamilyName` で確認できる。

アドオン本体は次のいずれかから取得する。

- PyPI パッケージ同梱の `blender_mcp/bundled/addon.py`（`uvx mcp-for-blender` 実行後の uv キャッシュ内にある）
- 上流リポジトリの `addon.py`

```bash
# 同梱 addon.py の場所（WSL 側）
find ~/.cache/uv -name addon.py -path "*mcp*" | head -1
```

WSL 側から `uvx mcp-for-blender install-addon` を実行しても `addon-paths` は `No Blender addons directories found.` となり、Windows 側の Store パスは検出できない。Windows 側で実行するか、上記のパスへ直接コピーするか、Blender の GUI から入れる。

```text
# GUI から入れる場合
Edit → Preferences → Add-ons → Install… → addon.py を選択
```

Blender 5.2 でも `scripts/addons/*.py` のレガシー形式アドオンはそのまま動作した。

### 3. アドオンを有効化する

`Edit → Preferences → Add-ons` で **Interface: MCP for Blender** を有効化する。

アドオンは Blender 起動時に socket サーバーを自動で開始する（既定で `Auto-Start Server` が有効）。手動で開始する場合は 3D ビューの `N` パネル → **MCP for Blender** タブ → `Connect to MCP server`。

```powershell
# サーバーが立ったか確認（LocalAddress=127.0.0.1 / OwningProcess=blender の PID）
Get-NetTCPConnection -LocalPort 9876 -State Listen | Select-Object LocalAddress,LocalPort,OwningProcess
```

### 4. Windows 側にリレーを置いて常駐させる

`examples/blender-mcp/relay.ps1` と `relay.vbs` を `%LOCALAPPDATA%\blender-mcp\` にコピーする。

```text
%LOCALAPPDATA%\blender-mcp\
├── relay.ps1   # 0.0.0.0:9877 -> 127.0.0.1:9876（ユーザー権限で動く。管理者権限は不要）
└── relay.vbs   # コンソールを出さずに relay.ps1 を起動するランチャー
```

手動で起動する場合:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\blender-mcp\relay.ps1"
```

ログオン時に自動起動させる場合は、`relay.vbs` をスタートアップフォルダにコピーする。

```text
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\blender-mcp-relay.vbs
```

タスクスケジューラでの登録（`schtasks /Create /SC ONLOGON`）は管理者権限が必要で、この環境では「アクセスが拒否されました」で失敗したため、スタートアップフォルダ方式を採っている。

```powershell
# リレーの状態確認
Get-NetTCPConnection -LocalPort 9877 -State Listen | Select-Object LocalAddress,LocalPort,OwningProcess
Get-Content "$env:LOCALAPPDATA\blender-mcp\relay.log" -Tail 5
```

Blender が起動していない間は、リレーは接続を受けても転送先に繋がらずに閉じるだけで、エラーにはならない。

### 5. Pi に MCP サーバーを登録する

```bash
pi mcp add blender \
  --env BLENDER_HOST=172.25.128.1 \
  --env BLENDER_PORT=9877 \
  --description "Windows ホストの Blender を socket 経由で操作する" \
  -- uvx mcp-for-blender
```

`~/.pi/agent/mcp.json` に直接書く場合は `examples/blender-mcp/mcp.json` を参照。`BLENDER_HOST` は環境によって変わるので、`ip route show default | awk '{print $3}'` の値に置き換える。

### 6. 動作確認

```bash
pi mcp list
# state=connected / tools: get_addon_status, get_scene_info, execute_blender_code,
# look, generate_3d, search_assets, import_asset, disable_telemetry, record_trajectory_feedback
```

WSL から直接 socket を叩いて切り分ける場合:

```bash
# リレーが開いているか
timeout 3 bash -c 'cat < /dev/null > /dev/tcp/172.25.128.1/9877' && echo reachable

# アドオンに ping して応答を見る（MCP サーバーを介さない確認）
python3 - <<'PY'
import json, socket
s = socket.create_connection(('172.25.128.1', 9877), timeout=10)
s.sendall(json.dumps({"type": "ping", "params": {}}).encode())
print(s.recv(65536).decode())
PY
```

## 検証エビデンス

| 項目 | 実測値 |
| --- | --- |
| WSL → リレー → アドオンの `ping` | 29 ms |
| `get_scene_info`（リレー経由、接続込み） | 49〜54 ms |
| Pi（`pi -p`）経由でのオブジェクト追加 | 成功。追加した `pi_e2e_test` を別経路の raw socket でも確認 |
| アドオンの capability | `execute_code` / `get_scene_info` / `get_viewport_screenshot` など 13 件、`blender_version: 5.2.2 LTS` |
| レンダリング画像の確認 | Blender 側で PNG 保存 → `/mnt/c/...` を Pi の `read` ツールで読んで内容を説明できた |

Pi 経由では次のプロンプトで確認した。

```bash
pi -p "blender MCP サーバーのツールで 'pi_e2e_test' という名前の立方体を追加し、シーン情報を取得して確認して報告して"
```

### 見た目の確認方法（`look` が使えない代わり）

`look` の代わりに、Blender 側でレンダリングして Pi の `read` ツールで読む。`execute_blender_code` に渡す例:

```python
import bpy
sc = bpy.context.scene
sc.render.resolution_x, sc.render.resolution_y = 480, 270
sc.render.image_settings.file_format = 'PNG'
sc.render.filepath = 'C:/Users/<user>/AppData/Local/Temp/blender_check.png'
bpy.ops.render.render(write_still=True)
```

Windows 側のパスに書かせれば、WSL からは `/mnt/c/Users/<user>/AppData/Local/Temp/blender_check.png` として同じファイルを読める。Pi の `read` ツールは画像をそのまま添付できるため、モデルはレンダリング結果を見て判断できる。

## できないこと・注意

### `look`（スクリーンショット系）はこの構成では動かない

MCP サーバー（WSL）が自分の temp パス（例 `/tmp/blender_look_123.png`）を Blender に渡し、Blender（Windows）がそのパスへ書き、サーバーが同じ文字列のパスを自分のファイルシステムから読む設計になっている。`/tmp/...` は Windows 側では `C:\tmp\...` に解決されるため同一ファイルにならず、全モードで失敗する。

| 呼び出し | 実際のエラー |
| --- | --- |
| `look()`（既定 = viewport） | `Screenshot failed: Screenshot file was not created` |
| `look(mode='angles' / 'camera')` | `[Errno 2] No such file or directory: '/tmp/blender_look_<pid>.png'` |
| `look(image='Render Result')` | `Error: Cannot read '/tmp/blender_look_<pid>.png': No such file or directory`（Blender 側で失敗） |

回避策は前述の「レンダリング → `/mnt/c` 経由で読む」手順。

### セキュリティ

- アドオンの socket は無認証で、接続できた相手は Blender 内で任意の Python を実行できる。リレーは `0.0.0.0` で待ち受けるため、ネットワークの公開範囲には注意する。
- この環境では Wi-Fi のネットワークプロファイルが `Public` で、Windows Firewall の受信既定（`Get-NetFirewallProfile` の `DefaultInboundAction` は未構成 = ローカル既定のブロック）が効く想定だが、**別ホストから 9877 に到達できるかは未検証**。Private プロファイルのネットワークで使う場合は到達しうるため、その前提で扱う。
- 上流には `BLENDER_MCP_SAFE_MODE=1`（実行前に危険なコードを検査する）がある。この環境では未検証。

### 運用

- WSL の NAT サブネットが変わると `BLENDER_HOST` が古くなる。`pi mcp list` が `connected` にならないときは `ip route show default | awk '{print $3}'` を確認して `~/.pi/agent/mcp.json` を更新する。
- アドオンを更新するときは `blender_mcp.py` を再配置する。WSL 側の `uvx mcp-for-blender update` は Windows 側の Store パスを検出できない。
- MCP サーバーのインスタンスは 1 つにする（上流の注意書き。複数クライアントから同時に使わない）。
- `search_assets` / `import_asset` / `generate_3d` は今回試していない。アセット取り込みは Blender 側（Windows）で完結するため動く見込みだが未検証。

## 採用しなかった案

| 案 | 判断 |
| --- | --- |
| `networkingMode=mirrored` に変更して `localhost` 直結 | 通ればリレーも `BLENDER_HOST` も不要になり最短だが、`wsl --shutdown` が必要で WSL のネットワーク全体に影響が出るため今回は未検証。代替案として有力 |
| アドオンの bind 先を `0.0.0.0` に変更 | 上流コードの改変になり、アドオン更新のたびに上書きされるため不採用 |
| Windows 側で MCP サーバーを動かす（Windows に uv を入れ、Pi から interop で起動） | ネットワーク変更は不要だが、ツールチェーンが 2 系統になり stdio を interop 越しに扱う検証が別途必要 |
| タスクスケジューラでリレーを常駐 | 管理者権限が必要で拒否されたため、スタートアップフォルダ方式に変更 |
| Blender Lab の公式 MCP Server | 配布が Blender Lab 拡張リポジトリ / `.mcpb` で、Pi（stdio MCP）からの利用実績が薄いため今回は比較対象外 |

## 参考

- [ahujasid/mcp-for-blender](https://github.com/ahujasid/mcp-for-blender)（旧 `blender-mcp`。PyPI パッケージ名は `mcp-for-blender`）
- [Blender Lab MCP Server](https://www.blender.org/lab/mcp-server/)
- [Advanced settings configuration in WSL](https://learn.microsoft.com/en-us/windows/wsl/wsl-config)（`networkingMode` / `hostAddressLoopback` など）
