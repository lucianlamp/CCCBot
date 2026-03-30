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

> **⚠️ Windows users:** The Channels plugin on Windows-native Claude Code is currently unstable. We strongly recommend running CCCBot under **WSL (Windows Subsystem for Linux)** for a reliable experience. Use the macOS / Linux install command inside your WSL terminal.

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

Claude Code starts automatically and runs the boot sequence. A greeting message should arrive via your configured channel (Telegram or Discord).

If you don't receive a message, check that the [prerequisites](#prerequisites) are set up correctly, then run `/ccc-boot` in the Claude Code terminal.

### Subsequent launches

```bash
cccbot
```

The `cccbot` command is automatically added to your PATH during installation. If it's not available, restart your terminal or re-run the installer.

> **Always use `cccbot`** (or `start.sh` / `start.bat` directly). They handle PID tracking, duplicate-launch prevention, session resume (`--continue`), and boot auto-trigger. Running `claude --channels ...` directly will skip these safeguards.

---

## Updating

```bash
cccbot update
```

To update to a specific version:

```bash
cccbot update v1.0.0
```

Your personal settings (`SOUL.md`, `cccbot.json`, etc.) are preserved during updates.

> **Upgrading from v0.1.x:** The `cccbot` command was added in v0.2.0. If you're on an older version, run the [install one-liner](#quick-start) once to upgrade. After that, `cccbot update` will work for all future updates.

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
- **Heartbeat**: periodic check — sends notification only if issues are found
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

## Configuration

### cccbot.json

`cccbot.json` is the user configuration file for channels and workspace settings:

```json
{
  "workspace": "workspace",
  "channels": "plugin:telegram@claude-plugins-official"
}
```

| Key | Default | Description |
|-----|---------|-------------|
| `workspace` | `"workspace"` | Default working directory for file operations |
| `channels` | `"plugin:telegram@claude-plugins-official"` | Channel plugins (space-separated for multiple) |

**Workspace path resolution:**

| Value | Resolves to |
|-------|-------------|
| `"workspace"` | `~/.cccbot/workspace` (relative to install dir) |
| `"~/projects/my-app"` | Your project directory (tilde expansion) |
| `"/opt/project"` | Absolute path as-is |

When the workspace points outside `~/.cccbot`, it is automatically added to Claude Code's `additionalDirectories` so Claude can access the files.

**Environment variables** override `cccbot.json`:

```bash
WORKSPACE=~/other-project CHANNELS="plugin:discord@claude-plugins-official" ~/.cccbot/start.sh
```

### Multiple channels

To use both Telegram and Discord simultaneously:

```json
{
  "channels": "plugin:telegram@claude-plugins-official plugin:discord@claude-plugins-official"
}
```

### Customizable Files

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
├── cccbot.json              # User config: workspace, channels (gitignored)
├── .mcp.json                # MCP plugin config (bot tokens — gitignored)
├── start.sh / start.bat     # Launchers
├── bin/
│   ├── cccbot               # CLI command (macOS/Linux/WSL)
│   └── cccbot.cmd           # CLI command (Windows)
├── workspace/               # Default working directory
├── scripts/
│   ├── install.sh           # Installer (macOS/Linux)
│   ├── install.bat          # Installer (Windows)
│   ├── get-parent-pid.ps1   # PID helper for Windows
│   ├── lib/                 # Shared bash utilities
│   │   ├── json-parse.sh    # JSON key-value extraction
│   │   ├── resolve-workspace.sh  # Path expansion
│   │   └── add-directory.sh # additionalDirectories management
│   └── templates/           # Config templates (copied on first run)
│       ├── settings.json.default
│       ├── cccbot.json.default
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
