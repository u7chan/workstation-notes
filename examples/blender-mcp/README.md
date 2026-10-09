# Blender MCP examples

WSL2 の Pi から Windows ホストの Blender を MCP 経由で操作するためのコピー用ファイル。

|ファイル|コピー先|用途|
|-|-|-|
|`relay.ps1`|`%LOCALAPPDATA%\blender-mcp\relay.ps1`|Blender アドオンの loopback socket (`127.0.0.1:9876`) を WSL から到達できるポート (`0.0.0.0:9877`) に中継する|
|`relay.vbs`|`%LOCALAPPDATA%\blender-mcp\relay.vbs`|コンソールウィンドウを出さずに `relay.ps1` を起動するランチャー|
|`relay.vbs`|`%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\blender-mcp-relay.vbs`|ログオン時にリレーを自動起動させる場合の配置先|
|`mcp.json`|`~/.pi/agent/mcp.json` の `mcpServers` に追記|Pi に `blender` サーバーを登録する|

`mcp.json` の `BLENDER_HOST` は WSL から見た Windows ホストの IP に置き換える。値は `ip route show default | awk '{print $3}'` で確認できる。

手順と検証結果は `docs/blender-mcp/README.md` を参照。
