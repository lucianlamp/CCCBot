<p align="center">
  <img src="assets/banner.svg" alt="CCCBot — Claude Code Channels Bot" width="800">
</p>

[![Release](https://img.shields.io/github/v/release/lucianlamp/CCCBot)](https://github.com/lucianlamp/CCCBot/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-blue.svg)](#クイックスタート)
[![Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet.svg)](https://claude.ai/code)
[![Channels](https://img.shields.io/badge/Channels-Telegram%20%7C%20Discord-green.svg)](#仕組み)

> **[English version](README.md)**

[Claude Code Channels](https://code.claude.com/docs/en/channels) を拡張して、[OpenClaw](https://openclaw.org) 的な自律エージェントにするボット。

素の Channels は Telegram / Discord に「繋がる」だけ。CCCBot はその上にスケジュールタスク、死活監視（HEARTBEAT）、MCP 切断時の自動復旧、人格・ペルソナ設定を載せて、**自律的に動き続ける**ところまでやります。

最大の魅力は、Claude Code の **OAuth 定額プラン**で動くこと。API 従量課金ではなく、月額固定で Claude が自律的に動き続けます。

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

Claude Code が自動的に起動し、ブートシーケンスが実行されます。設定済みのチャンネル（Telegram または Discord）に挨拶メッセージが届きます。

メッセージが届かない場合は、[前提条件](#前提条件)が正しく設定されているか確認し、Claude Code のターミナルで `/ccc-boot` を実行してください。

### 以降の起動

```bash
cccbot
```

`cccbot` コマンドはインストール時に自動的に PATH に追加されます。利用できない場合はターミナルを再起動するか、インストーラーを再実行してください。

> **必ず `cccbot`**（または `start.sh` / `start.bat`）を使用してください。PID 管理、重複起動防止、セッション再開（`--continue`）、起動時自動トリガーが含まれています。`claude --channels ...` を直接実行するとこれらがスキップされます。

---

## アップデート

```bash
cccbot update
```

特定のバージョンにアップデート：

```bash
cccbot update v1.0.0
```

個人設定（`SOUL.md`、`cccbot.json` など）はアップデート時に自動的に保持されます。

> **v0.1.x からのアップグレード:** `cccbot` コマンドは v0.2.0 で追加されました。古いバージョンの場合は、[インストールコマンド](#クイックスタート)を一度実行してアップグレードしてください。以降は `cccbot update` で更新できます。

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
- **Heartbeat**: 定期チェック — 問題がある場合のみ通知を送信。MCPチャンネルが切断された場合、自動的にセッションを再起動して復旧
- **セッション復元**: ランチャースクリプトは `--continue` で前回セッションの復元を試み、なければ新規セッションを開始
- **JOBS.yaml**: 起動時に自動登録される定期タスクを定義（`/ccc-jobs` で管理）

> Telegram と Discord は同時に有効にできます。起動時に `--channels` で両方を指定してください。

### Claude アプリからのリモートコントロール

CCCBot は `--remote-control` 付きで起動するため、[Claude デスクトップ/モバイルアプリ](https://claude.ai)からセッションに接続できます：

- **監視** — Claude の動作をリアルタイムでスマホやブラウザから確認
- **承認** — パーミッションモードが `allowEdits` の場合、ツール実行を確認・許可
- **介入** — セッションに直接メッセージを送信、タスクの一時停止やキャンセル

Claude Code を実行中のターミナルはヘッドレスのまま動作し、すべてのやり取りはチャンネル（Telegram/Discord）および Claude アプリから行えます。

---

## 設定

### cccbot.json

`cccbot.json` はチャンネルとワークスペースのユーザー設定ファイルです:

```json
{
  "workspace": "workspace",
  "channels": "plugin:telegram@claude-plugins-official"
}
```

| キー | デフォルト | 説明 |
|------|-----------|------|
| `workspace` | `"workspace"` | ファイル操作のデフォルト作業ディレクトリ |
| `channels` | `"plugin:telegram@claude-plugins-official"` | チャンネルプラグイン（複数はスペース区切り） |

**ワークスペースのパス解決:**

| 値 | 解決先 |
|----|--------|
| `"workspace"` | `~/.cccbot/workspace`（インストールディレクトリからの相対パス） |
| `"~/projects/my-app"` | プロジェクトディレクトリ（チルダ展開） |
| `"/opt/project"` | 絶対パスはそのまま |

ワークスペースが `~/.cccbot` の外を指す場合、Claude Code の `additionalDirectories` に自動追加され、Claude がそのファイルにアクセスできるようになります。

**環境変数**は `cccbot.json` をオーバーライドします:

```bash
WORKSPACE=~/other-project CHANNELS="plugin:discord@claude-plugins-official" ~/.cccbot/start.sh
```

### 複数チャンネル

Telegram と Discord を同時に使用する場合:

```json
{
  "channels": "plugin:telegram@claude-plugins-official plugin:discord@claude-plugins-official"
}
```

### カスタマイズ可能なファイル

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
- **allowEdits** — `allowEdits`: ファイル編集は自動許可、Bash等の危険なツールは確認必要

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
+-- CLAUDE.md                # Claude のメイン設定（慎重に編集）
+-- SOUL.md                  # ペルソナ、アイデンティティ、トーン、価値観
+-- BOOT.md                  # セッション開始時の処理
+-- HEARTBEAT.md             # ハートビートチェック項目
+-- JOBS.yaml                # 定期スケジュールタスク
+-- cccbot.json              # ユーザー設定: ワークスペース、チャンネル（gitignore対象）
+-- .mcp.json                # MCP プラグイン設定（ボットトークン — gitignore対象）
+-- start.sh / start.bat     # ランチャー
+-- bin/
|   +-- cccbot               # CLI コマンド（macOS/Linux/WSL）
|   +-- cccbot.cmd           # CLI コマンド（Windows）
+-- workspace/               # デフォルト作業ディレクトリ
+-- scripts/
|   +-- install.sh           # インストーラー（macOS/Linux）
|   +-- install.bat          # インストーラー（Windows）
|   +-- restart-session.sh   # MCP 自動リカバリ（macOS/Linux）
|   +-- restart-session.bat  # MCP 自動リカバリ（Windows）
|   +-- get-parent-pid.ps1   # PID 取得ヘルパー（Windows）
|   +-- lib/                 # 共有 bash ユーティリティ
|   |   +-- json-parse.sh    # JSON キー値抽出
|   |   +-- resolve-workspace.sh  # パス展開
|   |   +-- add-directory.sh # additionalDirectories 管理
|   +-- templates/           # 設定テンプレート（初回実行時にコピー）
|       +-- settings.json.default
|       +-- cccbot.json.default
|       +-- CLAUDE.example.md
|       +-- SOUL.example.md
|       +-- BOOT.example.md
|       +-- HEARTBEAT.example.md
|       +-- JOBS.example.yaml
|       +-- .gitignore.default
+-- .claude/
|   +-- settings.json        # パーミッションとフック（gitignore対象）
|   +-- settings.local.json  # ローカル上書き設定（gitignore対象）
|   +-- scripts/
|   |   +-- session-start-hook.sh  # SessionStart フック（起動オーケストレーター）
|   +-- skills/              # スキル定義（動作ロジック）
|       +-- REQUIRED.md
|       +-- IMPORTED.md
|       +-- ccc-boot/
|       +-- ccc-soul/
|       +-- ccc-jobs/
|       +-- ccc-heartbeat/
|       +-- ccc-channel-task/
|       +-- ccc-defaults/
|       +-- ccc-import-openclaw-skill/
+-- memory/                  # 自動メモリストレージ（gitignore対象）
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

---

## 免責事項

- CCCBot は独立したコミュニティプロジェクトであり、**Anthropic とは無関係であり、Anthropic による公式な推奨を受けたものではありません**。
- [Claude Code Channels](https://code.claude.com/docs/en/channels) は現在リサーチプレビュー中です。機能や提供状況は予告なく変更される場合があります。
- CCCBot は Claude Code を自律的に実行します。使用前に[パーミッション](#パーミッション)設定を十分に確認してください。AI が行った意図しない動作について、作者は一切の責任を負いません。
- 自己責任でご使用ください。詳細は [LICENSE](LICENSE) を参照してください。
