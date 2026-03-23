# CCCBot — Claude Code Channels Bot

> **[日本語版はこちら](README.ja.md)**

An autonomous Claude Code workspace connected to messaging channels (Telegram, Discord, etc.).

Claude runs persistently, receives tasks via Telegram or Discord, executes them in the background, and reports results. The terminal running Claude Code must stay open to maintain the session.

Built on [Claude Code Channels](https://code.claude.com/docs/en/channels) — currently in research preview.

---

## Quick Start

### Option A — One-command install

```bash
# macOS / Linux
bash <(curl -fsSL https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.sh)
```

```powershell
# Windows (PowerShell)
$f="$env:TEMP\cccbot-install.bat"; (Invoke-WebRequest https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.bat).Content | Set-Content $f; & $f
```

### Option B — Clone and run

```bash
git clone https://github.com/lucianlamp/CCCBot
cd CCCBot
bash start.sh   # Windows: start.bat
```

`start.sh` automatically runs the installer on first launch if `~/.cccbot` doesn't exist.

### After install

1. Run `~/.cccbot/start.sh` (or `%USERPROFILE%\.cccbot\start.bat` on Windows)
2. The assistant will guide you through setup on first launch (`/ccc-setup`)
3. Send a message from Telegram or Discord — Claude will respond

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
| `SOUL.md` | Identity, persona, tone, values |
| `USER.md` | Info about the operator |
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

Personal config files (`SOUL.md`, `USER.md`, `CRONS.md`, etc.) live in `~/.cccbot/` and are not tracked by git.

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
