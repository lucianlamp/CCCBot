# CCCBot — Claude Code Channels Bot

> **[English version](README.md)**

メッセージングチャンネル（Telegram、Discordなど）に接続された、自律型 Claude Code ワークスペース。

Claude が常駐し、Telegram や Discord からタスクを受け取り、バックグラウンドで実行し、結果を報告します。セッションを維持するため、Claude Code を実行中のターミナルは開いたままにしておく必要があります。

[Claude Code Channels](https://code.claude.com/docs/en/channels) 上に構築（リサーチプレビュー中）。

---

## クイックスタート

### オプション A — ワンコマンドインストール

```bash
# macOS / Linux
bash <(curl -fsSL https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.sh)
```

```powershell
# Windows (PowerShell)
git clone https://github.com/lucianlamp/CCCBot $env:USERPROFILE\.cccbot; & $env:USERPROFILE\.cccbot\scripts\setup.bat; & $env:USERPROFILE\.cccbot\start.bat
```

### オプション B — クローンして実行

```bash
git clone https://github.com/lucianlamp/CCCBot
cd CCCBot
bash start.sh   # Windows: start.bat
```

`start.sh` は `~/.cccbot` が存在しない場合、初回起動時に自動でインストーラーを実行します。

### インストール後

1. `~/.cccbot/start.sh`（Windows: `%USERPROFILE%\.cccbot\start.bat`）を実行
2. 初回起動時にアシスタントがセットアップをガイドします（`/ccc-setup`）
3. Telegram や Discord からメッセージを送信 — Claude が応答します

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

- **Boot**: cronジョブを登録し、ハートビートを開始
- **Heartbeat**: 定期チェック — 問題がある場合のみ通知を送信
- **CRONS.md**: 起動時に自動登録される定期タスクを定義

> Telegram と Discord は同時に有効にできます。起動時に `--channels` で両方を指定してください。

---

## カスタマイズ可能なファイル

以下のファイルは自由に編集可能です。ワークスペースの動作を定義します:

| ファイル | 用途 |
|----------|------|
| `CLAUDE.md` | **コア設定 — Claude の動作を制御。慎重に編集。** |
| `SOUL.md` | アイデンティティ、ペルソナ、トーン、価値観 |
| `USER.md` | オペレーターの情報 |
| `BOOT.md` | セッション開始時の処理 |
| `HEARTBEAT.md` | ハートビートサイクルごとのチェック項目 |
| `CRONS.md` | 定期スケジュールタスク |

> **CLAUDE.md** は最も重要なファイルです。Claude の指示を直接制御します。
> 不適切な編集は予期しない動作を引き起こす可能性があります。git で変更を追跡してください。

---

## プロジェクト構成

```
.
+-- CLAUDE.md              # Claude のメイン設定（慎重に編集）
+-- start.sh / start.bat   # ランチャー（初回起動時に自動インストール）
+-- scripts/
|   +-- install.sh         # インストーラー（macOS/Linux）
|   +-- install.bat        # インストーラー（Windows）
|   +-- setup.sh           # 共通セットアップ処理（テンプレートコピー、gitignore）
|   +-- setup.bat          # Windows 版
|   +-- templates/         # 個人設定テンプレート（初回実行時にコピー）
+-- .claude/
    +-- settings.json      # パーミッションとフック
    +-- skills/            # スキル定義（動作ロジック）
        +-- REQUIRED.md    # 必須スキル — 削除禁止
        +-- IMPORTED.md    # 外部インポートされたスキル
        +-- ccc-boot/
        +-- ccc-setup/
        +-- ccc-heartbeat/
        +-- ccc-channel-task/
        +-- ccc-defaults/
        +-- ccc-import-openclaw-skill/
```

個人設定ファイル（`SOUL.md`、`USER.md`、`CRONS.md` など）は `~/.cccbot/` に配置され、git で追跡されません。

---

## スキル

`.claude/skills/` 内のスキルが動作ロジックを定義します。上記の `.md` ファイルはスキルが読み込むユーザー設定です。

| スキル | 用途 |
|--------|------|
| `ccc-boot` | セッション開始シーケンス |
| `ccc-setup` | 初回セットアップ（対話的に設定をガイド） |
| `ccc-heartbeat` | 定期的な死活監視 |
| `ccc-channel-task` | チャンネルメッセージの標準フロー |
| `ccc-defaults` | ワークスペース全体のデフォルト設定 |
| `ccc-import-openclaw-skill` | ClawHub スキルのインストール |

### スキルレジストリファイル

| ファイル | 用途 |
|----------|------|
| `REQUIRED.md` | 必須 CCC スキル — 削除禁止 |
| `IMPORTED.md` | 外部インポートされたスキルとソースURL・インストール日 |
