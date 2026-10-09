# edge-tts は無料 TTS として使えるか

Last reviewed: 2026-10-09

## 概要

[edge-tts](https://github.com/rany2/edge-tts) は、Microsoft Edge の読み上げ機能が使うエンドポイントを Python から利用する非公式クライアント。API キー・アカウント登録・課金なしで音声を合成できる。

2026-10-09 に Linux コンテナ上で、ボイス一覧、生成パラメータ、合成速度、字幕生成、CLI の挙動、代替手段との比較を実測した。

結論は「検証・試作・手元の作業用なら十分使える。プロダクションの依存先には向かない」。

自作アプリ u7agent の組み込み `generate_speech` が既定構成で失敗する問題の回避策として使った経路でもある。不具合自体は [u7chan/monorepo Issue #1825](https://github.com/u7chan/monorepo/issues/1825) で扱っている。

## 確認環境

| 項目 | 内容 |
| --- | --- |
| OS | Linux コンテナ |
| Python | 3.13 |
| edge-tts | 7.2.8（PyPI 公開 2026-03-22） |
| 導入方法 | `uv venv .venv` + `uv pip install --python .venv/bin/python edge-tts` |
| venv サイズ | 14 MB |
| 補助ツール | `mutagen`（音声長・形式の確認） |
| ffmpeg | なし |

## 結論

**使える。API キー・アカウント登録・課金なしで、実用速度で音声が出る。** ただし**非公式・無保証**で、Microsoft の内部エンドポイントをクライアント側で再現しているだけなので、**プロダクションの依存先には向かない**。検証・プロトタイプ・手元の作業用としては非常に優秀。

| 観点 | 評価 |
| --- | --- |
| 費用 | 無料（キー不要・課金なし） |
| 日本語品質 | 良好（Azure のニューラル音声系。`ja-JP-NanamiNeural` / `ja-JP-KeitaNeural`） |
| 速度 | 高速（360 字 → 音声 81.12 秒を 0.98 秒で合成） |
| 安定性 | 非公式ゆえ保証なし。仕様変更で壊れうる |
| ライセンス | OSS（LGPLv3。`srt_composer.py` のみ MIT）。音声の商用利用条件は公開文書がなく不明確 |
| 出力形式 | mp3 固定（`audio-24khz-48kbitrate-mono-mp3`）＋ SRT / WebVTT 字幕 |

## なぜ無料なのか

Edge ブラウザの読み上げ機能が使う WebSocket エンドポイントを直接叩いている。

```python
# edge_tts/constants.py より（トークンの実値は伏せる。下記コマンドでパッケージ内を確認できる）
BASE_URL = "speech.platform.bing.com/consumer/speech/synthesize/readaloud"
TRUSTED_CLIENT_TOKEN = "<パッケージにハードコードされた固定値>"
WSS_URL = f"wss://{BASE_URL}/edge/v1?TrustedClientToken={TRUSTED_CLIENT_TOKEN}"
VOICE_LIST = f"https://{BASE_URL}/voices/list?trustedclienttoken={TRUSTED_CLIENT_TOKEN}"
```

```bash
# TRUSTED_CLIENT_TOKEN の実値はこの 1 コマンドで取得できる（OSS のソースを読むだけ）
# 出力例: TRUSTED_CLIENT_TOKEN = "<32 桁の 16 進数>"
grep -r TRUSTED_CLIENT_TOKEN .venv/lib/python*/site-packages/edge_tts/constants.py
```

- 認証は**公開済みの固定トークン**のみ。アカウントも従量課金も無い。値はパッケージの公開ソースに平文で載っており、ユーザー固有の資格情報ではない。本ページで値を伏せているのは、シークレットスキャナの誤検知を避け、手順書が「エンドポイントを直接叩くレシピ」に見えるのを避けるため。実値が必要なときは上記の 1 コマンドで取り出せる。
- 併せて `Sec-MS-GEC` トークンをクライアント側で計算して送る（`edge_tts/drm.py`）。時刻ベースなので、**システム時計が大きくずれていると失敗する**（ライブラリ側にサーバ時刻でスキュー補正する実装がある）。
- つまり「Microsoft が Edge 向けに開放している経路を、ブラウザの代わりに Python から利用している」形。**MS 側の都合でいつでも塞がれうる**。

## 導入手順

```bash
uv venv .venv
uv pip install --python .venv/bin/python edge-tts
```

```python
import asyncio, edge_tts

async def main():
    await edge_tts.Communicate("こんにちはなのだ", "ja-JP-NanamiNeural").save("generated/hello.mp3")

asyncio.run(main())
```

- 保存先のディレクトリは先に作る（`mkdir -p generated`）。無いと `FileNotFoundError` になる。
- 検証時の生成物は 12,672 bytes / MPEG layer III、24 kHz、モノラルだった。

## 実測結果

### ボイス一覧

```python
import asyncio, edge_tts

async def main():
    voices = await edge_tts.list_voices()  # 322 件
    print([v["ShortName"] for v in voices if v["Locale"].startswith("ja-")])

asyncio.run(main())
```

- 総数 **322** 件。うち `ja-JP` は **2 件のみ**。
  - `ja-JP-NanamiNeural`（Female, General, Friendly / Positive）
  - `ja-JP-KeitaNeural`（Male, General, Friendly / Positive）
- 多言語ボイス（`MultilingualNeural` 系）も 12 件含まれるため、英語混じりの読み上げにも対応余地がある。

### 生成パラメータ

```python
c = edge_tts.Communicate(
    "こんにちはなのだ",
    "ja-JP-NanamiNeural",
    rate="+50%",      # 話速
    volume="+20%",    # 音量
    pitch="-20Hz",    # ピッチ
)
await c.save("out.mp3")
```

- 出力は常に **mp3 / 24 kHz / 48 kbps CBR / モノラル**（`communicate.py` に `audio-24khz-48kbitrate-mono-mp3` が固定で埋め込まれている）。wav は直接出力できない。
- クライアント側の検証は書式のみ（`rate` / `volume` は `^[+-]\d+%$`、`pitch` は `^[+-]\d+Hz$`）で、範囲チェックはない。今回試したのは `-50%` から `+100%` まで。
- 話速の効き方（同一テキスト「ずんだもんなのだ。」×20、180 字）:

  | rate | 音声長 |
  | --- | --- |
  | `-50%` | 81.17 秒 |
  | `+0%` | 40.61 秒 |
  | `+50%` | 27.07 秒 |
  | `+100%` | 20.33 秒 |

  短い文では差が出にくい（文末無音やパディングの影響）。**効果を測るなら長文で**。

### 合成速度

| 入力 | 音声長 | 実時間 |
| --- | --- | --- |
| 「こんにちはなのだ」（8 字） | 2.11 秒 | 0.22 秒 |
| 「ずんだもんなのだ。」×40（360 字） | 81.12 秒 | 0.98 秒 |

- 実時間は回線状況で変動する。同日中の再実行では 8 字が 0.30 秒、360 字が 0.99 秒だった。
- さらに**10 リクエストを並列 5 で同時実行 → 全件成功、合計 0.86 秒**（再実行では 1.04 秒）。小規模用途ではレート制限は体感されない。
- 継続的な大量リクエストでの上限・BAN 挙動は未検証（[未確認事項](#未確認事項)を参照）。

### 字幕（SRT）

`SubMaker` でストリームから字幕も作れる。境界は既定で文単位（`boundary="SentenceBoundary"`）。

```python
sub = edge_tts.SubMaker()

with open("out.mp3", "wb") as f:
    async for chunk in edge_tts.Communicate(text, "ja-JP-NanamiNeural").stream():
        if chunk["type"] == "audio":
            f.write(chunk["data"])
        elif chunk["type"] in ("WordBoundary", "SentenceBoundary"):
            sub.feed(chunk)

open("out.srt", "w", encoding="utf-8").write(sub.get_srt())
```

実測出力:

```text
1
00:00:00,100 --> 00:00:02,100
こんにちはなのだ。

2
00:00:02,050 --> 00:00:04,412
今日はいい天気なのだ。
```

`SubMaker` にあるのは `feed()` と `get_srt()` だけで、7.x では `generate_srt_subs()` は廃止されている。

## CLI を使う場合の注意

CLI 自体は動作するが、**出力先を開けないときに `UnboundLocalError` で落ち、本来のエラーが隠れる**。`util.py` の `finally` が、`open()` の失敗で未代入のままの変数を参照するため。

```text
$ edge-tts --voice ja-JP-NanamiNeural --text "こんにちはなのだ" --write-media generated/out.mp3
（generated/ が無い場合）
  File ".../edge_tts/util.py", line 82, in _run_tts
    if audio_file is not sys.stdout.buffer:
       ^^^^^^^^^^
UnboundLocalError: cannot access local variable 'audio_file' where it is not associated with a value
```

- 出力先のディレクトリを作れば CLI でも成功する（同じ引数で 12,672 bytes の mp3 が生成できた）。
- 原因を追いにくいエラーになるため、**Python API（`Communicate.save()` / `.stream()`）を使うほうが安全**。

## 制約とリスク

### 技術面

- 出力は mp3 固定。wav が必要ならデコード工程が別途必要（この環境に `ffmpeg` は無いので `pydub` は不可。`av` や `soundfile` 等を選ぶ）。
- 日本語話者は 2 種のみ。感情・スタイル指定、話者間の抑揚制御は無い。**カスタム SSML も使えない**（Microsoft 側が Edge 由来の `<voice>` + `<prosody>` 以外を拒否するため、ライブラリがサポートを削除している）。
- 長文はクライアント側で分割送信する。UTF-8 で 4096 バイトを超える入力を自然な境界で分割する実装（`communicate.py` の `split_text_by_byte_length(text, 4096)`）。360 字は一括で通ったが、サーバー側の上限は未検証。

### 規約・運用面

- **非公式**: Microsoft は third-party クライアントからの利用を公式に文書化していない。Microsoft Q&A の回答でも「Edge 読み上げ音声と edge-tts の商用利用権を明示的に扱った公開文書は現時点で存在しない」として、確実性が必要なら Microsoft のサポート/法務へ確認するよう案内している（[Q&A: Unofficial Edge TTS API](https://learn.microsoft.com/en-us/answers/questions/2392491/unofficial-edge-tts-api)、[Q&A: Commercial Use of Edge Read Aloud Voices via edge-tts](https://learn.microsoft.com/en-us/answers/questions/5925556/commercial-use-of-edge-read-aloud-voices-via-edge)）。
- 音声の**商用利用可否は不明確**。配布物・商用利用に使うなら、規約判断は自己責任になる。
- レート制限・BAN・IP ブロックのリスクを負う。無保証・無 SLA。監査ログも課金管理も無い。
- u7agent の組み込みツール（OpenRouter 経由・クレジット管理下・秘密情報管理下）とは**別経路**。迂回して使う場合は組織のポリシー確認が必要。u7agent の場合は [Issue #1825](https://github.com/u7chan/monorepo/issues/1825) の修正でツール側を使えるようにするのが本筋。

## 代替手段との比較

| 手段 | 費用 | 公式性 | 日本語 | ローカル実行 | 備考 |
| --- | --- | --- | --- | --- | --- |
| **edge-tts** | 無料 | ×（非公式） | ○（2 声） | ×（要ネット） | 手軽さ・速度は最高。規約と安定性が弱点 |
| Azure Speech (F0) | 無料枠 月 50 万字 | ○ | ○ | × | 公式。F0 は 20 トランザクション / 60 秒、1 リクエストあたり最大 10 分。edge-tts と同系統の声が使える |
| Google Cloud TTS | 無料枠あり | ○ | ○ | × | 公式。無料枠超過は従量 |
| gTTS | 無料 | ×（非公式） | ○ | × | Google 翻訳の読み上げ API を直接利用する。大量アクセスで制限の可能性 |
| piper / piper-plus | 無料 | ○（OSS） | △ | ○ | 完全オフライン。本家 piper の対応言語に日本語は無く、日本語は piper-plus 系を使う |
| VOICEVOX | 無料 | ○（OSS） | ◎ | ○ | エンジンは商用・非商用可。ずんだもん等の音声は「VOICEVOX:ずんだもん」のクレジット表記で商用・非商用利用可。エンジン + モデルのダウンロードが大きい |
| OpenAI / Gemini TTS（u7agent 経由） | 有料（枠あり） | ○ | ◎ | × | 組み込みの `generate_speech` は現在こちら経由。設定修正待ち（[Issue #1825](https://github.com/u7chan/monorepo/issues/1825)） |

## 使い分け

1. **手元の検証・試作・社内メモ用** → edge-tts で十分。速い・無料・導入 1 分。
2. **成果物を配布・商用利用する** → VOICEVOX（クレジット表記で明確に権利処理できる）か Azure F0（公式・無料枠）へ移す。
3. **オフライン・閉域で動かす** → piper 系。初回のモデル取得だけネットワークが要る。
4. **u7agent から普通に使いたい** → ツール側の修正（モデルに応じた `response_format` の出し分け）が本筋。

選択の要点は、権利処理の明快さと品質を取るなら VOICEVOX、手軽さと速度を取るなら edge-tts、公式性を取るなら Azure F0。VOICEVOX は音声ライブラリの規約が明確で、ずんだもん等は `VOICEVOX:ずんだもん` のクレジット表記で商用・非商用どちらも無料で使える点が大きい。

## 未確認事項

- 継続的な大量リクエストでのレート制限・BAN 閾値（今回は並列 10 件までしか試していない）
- 1 リクエストで送れるテキスト長のサーバー側上限
- 音声の商用利用条件についての Microsoft 公式見解（現時点で公開文書なし）
- mp3 → wav 変換を行う場合の採用ライブラリ（`av` / `soundfile` など、`ffmpeg` 無しで動くもの）
- `MultilingualNeural` 系の日本語混在テキストでの品質
- VOICEVOX エンジンをこのコンテナに導入した場合のサイズと起動時間
- トークン失効・403 が起きたときの挙動（過去に仕様変更で壊れた例は [#267](https://github.com/rany2/edge-tts/issues/267) / [#290](https://github.com/rany2/edge-tts/issues/290)）

## 参考

- [rany2/edge-tts](https://github.com/rany2/edge-tts)
- [edge_tts/constants.py（トークンが平文で公開されている一次資料）](https://github.com/rany2/edge-tts/blob/master/src/edge_tts/constants.py)
- [edge-tts 7.2.8（PyPI）](https://pypi.org/project/edge-tts/7.2.8/)
- [Q&A: Unofficial Edge TTS API](https://learn.microsoft.com/en-us/answers/questions/2392491/unofficial-edge-tts-api)
- [Q&A: Commercial Use of Edge Read Aloud Voices via edge-tts](https://learn.microsoft.com/en-us/answers/questions/5925556/commercial-use-of-edge-read-aloud-voices-via-edge)
- [Azure Speech の価格](https://azure.microsoft.com/en-us/pricing/details/speech/)
- [Azure Speech のクォータと制限（Free F0 / TTS）](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/speech-services-quotas-and-limits)
- [pndurette/gTTS](https://github.com/pndurette/gTTS)
- [gTTS の仕組みと非公式性に関する解説](https://note.com/liuk_net/n/n5a558a9059b6)
- [OHF-Voice/piper1-gpl（本家 piper・対応言語一覧）](https://github.com/OHF-Voice/piper1-gpl)
- [piper-plus（日本語対応 fork）](https://pypi.org/project/piper-plus/)
- [VOICEVOX ソフトウェア利用規約](https://voicevox.hiroshiba.jp/term/)
- [音源利用ガイドライン（ずんだもん等のクレジット条件）](https://zunko.jp/con_ongen_kiyaku.html)
- [u7chan/monorepo Issue #1825（u7agent の generate_speech が pcm 専用モデルで失敗する件）](https://github.com/u7chan/monorepo/issues/1825)
