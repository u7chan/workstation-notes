# ripgrep の導入

Last reviewed: 2026-05-30

## 概要

コード探索で `rg` を使えるようにするため、Ubuntu / WSL に `ripgrep` を apt でインストールする。

Codex の実行環境では同梱された `rg` が PATH に見えることがある。ただし、OS に `ripgrep` パッケージが入っているとは限らないため、apt パッケージとしての導入状態を確認する。

## 背景

Codex がコード探索時に次のような応答を返した。

> `@tanstack/react-query` は依存関係に入っています。`rg` が無い環境なので、既存の利用パターンだけ `grep`/`find` で確認します。

`rg` がないと検索が `find` / `grep` にフォールバックし、探索の手間が増える。開発用の Ubuntu / WSL では `ripgrep` を標準ツールとして入れておく。

## 前提

- Ubuntu 24.04 LTS
- WSL2 または Ubuntu 環境
- `sudo apt` を実行できること

## インストール前の確認

`command -v rg` は Codex 同梱の `rg` を拾う場合があるため、apt パッケージの状態は `dpkg` と `apt-cache` で確認する。

```bash
dpkg -s ripgrep
```

未インストールの場合は、次のような結果になる。

```text
dpkg-query: package 'ripgrep' is not installed and no information is available
```

apt で入れられる候補があるか確認する。

```bash
apt-cache policy ripgrep
```

Ubuntu 24.04 では `noble/universe` から `ripgrep` を入れられる。

## インストール

```bash
sudo apt update
sudo apt install -y ripgrep
```

## インストール後の確認

apt パッケージとして入ったことを確認する。

```bash
dpkg -s ripgrep
```

`rg` コマンドが実行できることを確認する。

```bash
rg --version
```

Codex の実行 PATH などで別の `rg` が先に見える場合は、OS 側に入った `rg` を直接確認する。

```bash
/usr/bin/rg --version
```

検索が動くことも確認する。

```bash
rg "ripgrep" docs
```

## 実行ログ

2026-05-30 に Ubuntu 24.04.4 LTS 環境で確認した。

インストール前は apt パッケージとして未導入だった。

```text
$ dpkg -s ripgrep
dpkg-query: package 'ripgrep' is not installed and no information is available
```

apt の候補として `14.1.0-1` が見えていた。

```text
$ apt-cache policy ripgrep
ripgrep:
  Installed: (none)
  Candidate: 14.1.0-1
  Version table:
     14.1.0-1 500
        500 http://archive.ubuntu.com/ubuntu noble/universe amd64 Packages
```

`sudo apt update` 後、`sudo apt install -y ripgrep` で `ripgrep 14.1.0-1` がインストールされた。

```text
The following NEW packages will be installed:
  ripgrep

Setting up ripgrep (14.1.0-1) ...
```

インストール後は `dpkg` で `install ok installed` になった。

```text
$ dpkg -s ripgrep
Package: ripgrep
Status: install ok installed
Version: 14.1.0-1
```

OS 側の `rg` も実行できる。

```text
$ /usr/bin/rg --version
ripgrep 14.1.0
```

## 補足

`ripgrep` はコマンド名が `rg`、apt パッケージ名が `ripgrep`。

Codex やエディタ拡張が一時的に独自の `rg` を提供している場合でも、普段使うシェルで安定して使うには OS 側に `ripgrep` を入れておく。
