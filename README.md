# CCCBot — Claude Code Channels Bot

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-blue.svg)](#quick-start)
[![Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet.svg)](https://claude.ai/code)
[![Channels](https://img.shields.io/badge/Channels-Telegram%20%7C%20Discord-green.svg)](#how-it-works)

> **[日本語版はこちら](README.ja.md)**

An autonomous Claude Code workspace connected to messaging channels (Telegram, Discord, etc.).

Claude runs persistently, receives tasks via Telegram or Discord, executes them in the background, and reports results. The terminal running Claude Code must stay open to maintain the session.

Built on [Claude Code Channels](https://code.claude.com/docs/en/channels) — currently in research preview.

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

Claude Code starts automatically after installation. On first launch, a greeting message will arrive via Telegram or Discord, and the interactive setup will guide you through configuration.

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

- **Boot**: registers cron jobs, starts heartbeat
- **Heartbeat**: periodic check — sends notification only if issues are found
- **CRONS.md**: define recurring tasks that auto-register on boot

> Both Telegram and Discord can be active simultaneously. Pass both to `--channels` when starting.

---

## Customizable Files

These files are yours to edit — they define behavior for your workspace:

| File | Purpose |
|------|---------|
| `CLAUDE.md` | **Core config — controls Claude's behavior. Edit with care.** |
| `SOUL.md` | User info, bot identity, persona, tone, values |
| `BOOT.md` | What to do at session start |
| `HEARTBEAT.md` | What to check on each heartbeat cycle |
| `CRONS.md` | Recurring scheduled tasks |

> **CLAUDE.md** is the most critical file — it directly controls Claude's instructions.
> Incorrect edits can change behavior in unexpected ways. Use git to track changes.

---

## Project Structure

```
.
├── CLAUDE.md              # Primary Claude config (edit with care)
├── start.sh / start.bat   # Launchers (auto-installs on first run)
├── scripts/
│   ├── install.sh         # Installer (macOS/Linux)
│   ├── install.bat        # Installer (Windows)
│   ├── setup.sh           # Shared setup logic (template copy, gitignore)
│   ├── setup.bat          # Windows version
│   └── templates/         # Personal config templates (copied on first run)
└── .claude/
    ├── settings.json      # Permissions and hooks
    └── skills/            # Skill definitions (behavior logic)
        ├── REQUIRED.md    # Essential skills — do not delete
        ├── IMPORTED.md    # Externally imported skills
        ├── ccc-boot/
        ├── ccc-setup/
        ├── ccc-heartbeat/
        ├── ccc-channel-task/
        ├── ccc-defaults/
        └── ccc-import-openclaw-skill/
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
| `ccc-setup` | First-run config file generation |

### Skill Registry Files

| File | Purpose |
|------|---------|
| `REQUIRED.md` | Essential CCC skills — do NOT delete these |
| `IMPORTED.md` | Externally imported skills with source URLs and install dates |
