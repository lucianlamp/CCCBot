<p align="center">
  <img src="assets/banner.svg" alt="CCCBot — Claude Code Channels Bot" width="800">
</p>

[![Release](https://img.shields.io/github/v/release/lucianlamp/CCCBot)](https://github.com/lucianlamp/CCCBot/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-blue.svg)](#quick-start)
[![Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet.svg)](https://claude.ai/code)
[![Channels](https://img.shields.io/badge/Channels-Telegram%20%7C%20Discord-green.svg)](#how-it-works)

> **[日本語版はこちら](README.ja.md)**

An [OpenClaw](https://openclaw.org)-style autonomous agent built on top of [Claude Code Channels](https://code.claude.com/docs/en/channels).

Channels connects Claude Code to Telegram and Discord — CCCBot extends that into a **self-sustaining autonomous agent** with scheduled tasks, heartbeat monitoring, automatic recovery, and persona configuration.

The biggest advantage: it runs on Claude Code's **flat-rate OAuth plan**. No per-token API billing — Claude works autonomously at a fixed monthly cost.

---

## Prerequisites

Complete these steps first, following the [Claude Code Channels](https://code.claude.com/docs/en/channels) official docs:

- Obtain and configure a Telegram Bot Token or Discord Bot Token
- Enable the Claude Code Channels plugin

---

## Quick Start

```bash
# macOS / Linux
bash <(curl -fsSL https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.sh)
```

```powershell
# Windows (PowerShell)
$f="$env:TEMP\cccbot-install.bat"; (Invoke-WebRequest https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.bat).Content | Set-Content -Encoding ASCII $f; & $f
```

### After install

Claude Code starts automatically after installation. To begin the interactive setup, either:

- Run `/ccc-boot` in the Claude Code terminal, or
- Send any message from Telegram or Discord to the bot

A greeting message will arrive via the channel, and the setup will guide you through configuration.

### Subsequent launches

Use the launcher script to start the session:

```bash
# macOS / Linux
~/.cccbot/start.sh
```

```bat
:: Windows
%USERPROFILE%\.cccbot\start.bat
```

Or launch directly with the underlying command:

```bash
cd ~/.cccbot

# Telegram only (default)
claude --channels plugin:telegram@claude-plugins-official --remote-control

# Discord only
claude --channels plugin:discord@claude-plugins-official --remote-control

# Both at once
claude --channels plugin:telegram@claude-plugins-official plugin:discord@claude-plugins-official --remote-control
```

---

## Updating

Re-run the installer to update to the latest release:

```bash
# macOS / Linux
bash <(curl -fsSL https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.sh)
```

```powershell
# Windows (PowerShell)
$f="$env:TEMP\cccbot-install.bat"; (Invoke-WebRequest https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.bat).Content | Set-Content -Encoding ASCII $f; & $f
```

To install a specific version:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.sh) v1.0.0
```

Skills, scripts, and templates are updated. Your personal config files (`SOUL.md`, `CLAUDE.md`, `JOBS.yaml`, `BOOT.md`, `HEARTBEAT.md`) and settings are preserved.

---

## How It Works

```
[Telegram / Discord message]
      │
      ▼
Claude Code (persistent session)
      │
      ├─ Acknowledges immediately
      ├─ Runs task in background agent
      └─ Reports result via Telegram / Discord
```

- **Boot**: registers scheduled jobs, starts heartbeat
- **Heartbeat**: periodic check — sends notification only if issues are found; if an MCP channel disconnects, automatically triggers a session restart to recover
- **Session Resume**: launcher scripts try `--continue` first to resume the previous session, falling back to a fresh start if none exists
- **JOBS.yaml**: define recurring tasks that auto-register on boot (managed via `/ccc-jobs`)

> Both Telegram and Discord can be active simultaneously. Pass both to `--channels` when starting.

### Remote Control via Claude App

CCCBot launches with `--remote-control`, which connects the session to the [Claude desktop/mobile app](https://claude.ai). This lets you:

- **Monitor** — watch Claude's activity in real time from your phone or browser
- **Approve** — confirm tool executions when permission mode is set to `allowEdits`
- **Intervene** — send messages directly to the session, pause or cancel tasks

The terminal running Claude Code stays headless — all interaction happens through channels (Telegram/Discord) and/or the Claude app.

---

## Customizable Files

These files are yours to edit — they define behavior for your workspace:

| File | Purpose |
|------|---------|
| `CLAUDE.md` | **Core config — controls Claude's behavior. Edit with care.** |
| `SOUL.md` | User info, bot identity, persona, tone, values |
| `BOOT.md` | What to do at session start |
| `HEARTBEAT.md` | What to check on each heartbeat cycle |
| `JOBS.yaml` | Recurring scheduled tasks (managed via `/ccc-jobs`) |

> **CLAUDE.md** is the most critical file — it directly controls Claude's instructions.
> Incorrect edits can change behavior in unexpected ways. Use git to track changes.

---

## Permissions

CCCBot ships with a default permission set in `.claude/settings.json` that balances autonomy and safety.

**Permission mode is selected during installation:**

| Mode                 | `defaultMode`       | Behavior                                                            |
|----------------------|---------------------|---------------------------------------------------------------------|
| **bypass** (default) | `bypassPermissions` | All tools run without confirmation                                  |
| **allowEdits**       | `allowEdits`        | File edits auto-approved, Bash/dangerous tools require confirmation |

**Allowed by default:**

- Web search, reading/editing `.claude/` config files

**Denied (destructive operations):**

- `rm -rf /`, `rm -rf ~` — filesystem destruction
- `git push --force`, `git reset --hard`, `git clean -f`, `git branch -D` — irreversible git operations
- `format`, `mkfs`, `dd if=` — disk operations
- `npm publish` — accidental package publishing

### Updating Permissions

Edit `.claude/settings.json` directly:

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(npm test*)"     // add tool patterns to allow
    ],
    "deny": [
      "Bash(dangerous-cmd*)" // add tool patterns to deny
    ]
  }
}
```

Or ask Claude in chat — e.g. *"allow npm test commands"* — and it will update the settings file.

> **Tip:** Deny rules take precedence over allow rules. See [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code) for the full permission pattern syntax.

---

## Project Structure

```
.
├── CLAUDE.md                # Primary Claude config (edit with care)
├── SOUL.md                  # Persona, identity, tone, values
├── BOOT.md                  # Session start instructions
├── HEARTBEAT.md             # Heartbeat check instructions
├── JOBS.yaml                # Scheduled recurring tasks
├── .mcp.json                # MCP plugin config (bot tokens — gitignored)
├── start.sh / start.bat     # Launchers (auto-installs on first run)
├── scripts/
│   ├── install.sh           # Installer (macOS/Linux)
│   ├── install.bat          # Installer (Windows)
│   ├── restart-session.sh   # MCP auto-recovery (macOS/Linux)
│   ├── restart-session.bat  # MCP auto-recovery (Windows)
│   ├── get-parent-pid.ps1   # PID helper for Windows
│   └── templates/           # Config templates (copied on first run)
│       ├── settings.json.default
│       ├── CLAUDE.example.md
│       ├── SOUL.example.md
│       ├── BOOT.example.md
│       ├── HEARTBEAT.example.md
│       ├── JOBS.example.yaml
│       └── .gitignore.default
├── .claude/
│   ├── settings.json        # Permissions and hooks (gitignored)
│   ├── settings.local.json  # Local overrides (gitignored)
│   ├── scripts/
│   │   └── session-start-hook.sh  # SessionStart hook (boot orchestrator)
│   └── skills/              # Skill definitions (behavior logic)
│       ├── REQUIRED.md
│       ├── IMPORTED.md
│       ├── ccc-boot/
│       ├── ccc-soul/
│       ├── ccc-jobs/
│       ├── ccc-heartbeat/
│       ├── ccc-channel-task/
│       ├── ccc-defaults/
│       └── ccc-import-openclaw-skill/
└── memory/                  # Auto-memory storage (gitignored)
```

---

## Skills

Skills in `.claude/skills/` define the authoritative behavior logic. The `.md` files above are user-configurable inputs that skills read.

| Skill | Purpose |
|-------|---------|
| `ccc-boot` | Session start sequence |
| `ccc-heartbeat` | Periodic liveness check |
| `ccc-channel-task` | Standard flow for channel messages |
| `ccc-defaults` | Workspace-wide defaults (HTTP, git, Telegram) |
| `ccc-import-openclaw-skill` | Install ClawHub skills |
| `ccc-jobs` | Scheduled job management (`JOBS.yaml`) |
| `ccc-soul` | SOUL.md persona/identity configuration |

### Skill Registry Files

| File | Purpose |
|------|---------|
| `REQUIRED.md` | Essential CCC skills — do NOT delete these |
| `IMPORTED.md` | Externally imported skills with source URLs and install dates |

---

## Disclaimer

- CCCBot is an independent community project and is **not affiliated with or endorsed by Anthropic**.
- [Claude Code Channels](https://code.claude.com/docs/en/channels) is currently in research preview. Features and availability may change without notice.
- CCCBot runs Claude Code autonomously. Review the [permissions](#permissions) configuration carefully before use. The authors are not responsible for any unintended actions performed by the AI.
- Use at your own risk. See [LICENSE](LICENSE) for details.
