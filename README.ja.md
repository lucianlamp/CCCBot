# CCCBot — Claude Code Channels Bot

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-blue.svg)](#クイックスタート)
[![Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet.svg)](https://claude.ai/code)
[![Channels](https://img.shields.io/badge/Channels-Telegram%20%7C%20Discord-green.svg)](#仕組み)

> **[English version](README.md)**

メッセージングチャンネル（Telegram、Discordなど）に接続された、自律型 Claude Code ワークスペース。

Claude が常駐し、Telegram や Discord からタスクを受け取り、バックグラウンドで実行し、結果を報告します。セッションを維持するため、Claude Code を実行中のターミナルは開いたままにしておく必要があります。

[Claude Code Channels](https://code.claude.com/docs/en/channels) 上に構築（リサーチプレビュー中）。

---

## 前提条件

[Claude Code Channels](https://code.claude.com/docs/en/channels) の公式ドキュメントに従い、以下を事前に完了してください:

- Telegram Bot Token または Discord Bot Token の取得・設定
- Claude Code Channels プラグインの有効化

---

## クイックスタート

```bash
# macOS / Linux
bash <(curl -fsSL https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.sh)
```

```powershell
# Windows (PowerShell)
$f="$env:TEMP\cccbot-install.bat"; (Invoke-WebRequest https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.bat).Content | Set-Content -Encoding ASCII $f; & $f
```

### インストール後

インストール完了後、Claude Code が自動で起動します。初回起動時は Telegram または Discord に挨拶メッセージが届き、対話的にセットアップが始まります。

### 2回目以降の起動

ランチャースクリプトでセッションを開始します:

```bash
# macOS / Linux
~/.cccbot/start.sh
```

```bat
:: Windows
%USERPROFILE%\.cccbot\start.bat
```

または、直接コマンドで起動することもできます:

```bash
cd ~/.cccbot

# Telegram のみ（デフォルト）
claude --channels plugin:telegram@claude-plugins-official --remote-control

# Discord のみ
claude --channels plugin:discord@claude-plugins-official --remote-control

# 両方同時
claude --channels plugin:telegram@claude-plugins-official plugin:discord@claude-plugins-official --remote-control
```

---

## アップデート

```bash
cd ~/.cccbot && git pull
```

スキル、スクリプト、テンプレートが更新されます。個人設定ファイル（`SOUL.md`、`CLAUDE.md`、`JOBS.yaml`、`BOOT.md`、`HEARTBEAT.md`）はテンプレートから未作成時のみ生成されるため、`git pull` で上書きされません。`.claude/settings.json` は gitignore 対象です。

新しいテンプレートが追加された場合、次回起動時に自動で作成されます。

---

## 仕組み

```
[Telegram / Discord メッセージ]
      |
      v
Claude Code（常駐セッション）
      |
      +-- 即座に受信確認
      +-- バックグラウンドエージェントでタスク実行
      +-- Telegram / Discord で結果を報告
```

- **Boot**: スケジュールジョブを登録し、ハートビートを開始
- **Heartbeat**: 定期チェック — 問題がある場合のみ通知を送信
- **JOBS.yaml**: 起動時に自動登録される定期タスクを定義（`/ccc-jobs` で管理）

> Telegram と Discord は同時に有効にできます。起動時に `--channels` で両方を指定してください。

### Claude アプリからのリモートコントロール

CCCBot は `--remote-control` 付きで起動するため、[Claude デスクトップ/モバイルアプリ](https://claude.ai)からセッションに接続できます：

- **監視** — Claude の動作をリアルタイムでスマホやブラウザから確認
- **承認** — パーミッションモードが `auto` の場合、ツール実行を確認・許可
- **介入** — セッションに直接メッセージを送信、タスクの一時停止やキャンセル

Claude Code を実行中のターミナルはヘッドレスのまま動作し、すべてのやり取りはチャンネル（Telegram/Discord）および Claude アプリから行えます。

---

## カスタマイズ可能なファイル

以下のファイルは自由に編集可能です。ワークスペースの動作を定義します:

| ファイル | 用途 |
|----------|------|
| `CLAUDE.md` | **コア設定 — Claude の動作を制御。慎重に編集。** |
| `SOUL.md` | ユーザー情報、ボットのアイデンティティ、ペルソナ、トーン、価値観 |
| `BOOT.md` | セッション開始時の処理 |
| `HEARTBEAT.md` | ハートビートサイクルごとのチェック項目 |
| `JOBS.yaml` | 定期スケジュールタスク（`/ccc-jobs` で管理） |

> **CLAUDE.md** は最も重要なファイルです。Claude の指示を直接制御します。
> 不適切な編集は予期しない動作を引き起こす可能性があります。git で変更を追跡してください。

---

## パーミッション

CCCBot はデフォルトで `.claude/settings.json` に自律性と安全性のバランスを取ったパーミッション設定を持っています。

**パーミッションモードはインストール時に選択します:**

- **bypass**（デフォルト）— `bypassPermissions`: 全ツールを確認なしで実行
- **auto** — `allowEdits`: ファイル編集は自動許可、Bash等の危険なツールは確認必要

**許可（デフォルト）:**

- Web 検索、`.claude/` 設定ファイルの読み書き

**拒否（破壊的操作）:**

- `rm -rf /`, `rm -rf ~` — ファイルシステム破壊
- `git push --force`, `git reset --hard`, `git clean -f`, `git branch -D` — 不可逆な git 操作
- `format`, `mkfs`, `dd if=` — ディスク操作
- `npm publish` — パッケージの誤公開

### パーミッションの更新

`.claude/settings.json` を直接編集:

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(npm test*)"     // 許可するツールパターンを追加
    ],
    "deny": [
      "Bash(dangerous-cmd*)" // 拒否するツールパターンを追加
    ]
  }
}
```

または、チャットで Claude に依頼できます — 例: *「npm test コマンドを許可して」*

> **ヒント:** deny ルールは allow ルールより優先されます。パーミッションパターンの完全な構文は [Claude Code ドキュメント](https://docs.anthropic.com/en/docs/claude-code) を参照してください。

---

## プロジェクト構成

```
.
+-- CLAUDE.md              # Claude のメイン設定（慎重に編集）
+-- start.sh / start.bat   # ランチャー（初回起動時に自動インストール）
+-- scripts/
|   +-- install.sh         # インストーラー（macOS/Linux）
|   +-- install.bat        # インストーラー（Windows）
|   +-- templates/         # 設定テンプレート（初回実行時にコピー）
|       +-- settings.json.default  # パーミッション・フックのデフォルト
+-- .claude/
    +-- settings.json      # パーミッションとフック（テンプレートから作成、gitignore対象）
    +-- skills/            # スキル定義（動作ロジック）
        +-- REQUIRED.md    # 必須スキル — 削除禁止
        +-- IMPORTED.md    # 外部インポートされたスキル
        +-- ccc-boot/
        +-- ccc-soul/
        +-- ccc-jobs/
        +-- ccc-heartbeat/
        +-- ccc-channel-task/
        +-- ccc-defaults/
        +-- ccc-import-openclaw-skill/
```

---

## スキル

`.claude/skills/` 内のスキルが動作ロジックを定義します。上記の `.md` ファイルはスキルが読み込むユーザー設定です。

| スキル | 用途 |
|--------|------|
| `ccc-boot` | セッション開始シーケンス |
| `ccc-jobs` | スケジュールジョブ管理（`JOBS.yaml`） |
| `ccc-soul` | SOUL.md ペルソナ・アイデンティティ設定 |
| `ccc-heartbeat` | 定期的な死活監視 |
| `ccc-channel-task` | チャンネルメッセージの標準フロー |
| `ccc-defaults` | ワークスペース全体のデフォルト設定 |
| `ccc-import-openclaw-skill` | ClawHub スキルのインストール |

### スキルレジストリファイル

| ファイル | 用途 |
|----------|------|
| `REQUIRED.md` | 必須 CCC スキル — 削除禁止 |
| `IMPORTED.md` | 外部インポートされたスキルとソースURL・インストール日 |
