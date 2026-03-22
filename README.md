# CCCBot — Claude Code Channels Bot

An autonomous Claude Code workspace connected to messaging channels (Telegram, etc.).

Claude runs persistently, receives tasks via Telegram, executes them in the background, and reports results — without requiring a terminal open.

---

## Quick Start

### Option A — One-command install

```bash
# macOS / Linux
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ccc/main/scripts/install.sh)
```

```powershell
# Windows (PowerShell)
$f="$env:TEMP\ccc-install.bat"; Invoke-WebRequest https://raw.githubusercontent.com/YOUR_USERNAME/ccc/main/scripts/install.bat -OutFile $f; & $f
```

Or download `scripts/install.sh` / `scripts/install.bat` and run it directly.

### Option B — Clone and run

```bash
git clone https://github.com/YOUR_USERNAME/ccc
cd ccc
bash start.sh   # Windows: start.bat
```

`start.sh` automatically runs the installer on first launch if `~/.cccbot` doesn't exist.

### After install

1. Edit `~/.cccbot/.mcp.json` — add your Telegram bot token
2. Edit `~/.cccbot/USER.md` — describe yourself and your projects
3. Run `~/.cccbot/start.sh` (or `%USERPROFILE%\.cccbot\start.bat` on Windows) — Claude starts and connects to Telegram
4. Send a message from Telegram — Claude will respond

---

## How It Works

```
[Telegram message]
      │
      ▼
Claude Code (persistent session)
      │
      ├─ Acknowledges immediately
      ├─ Runs task in background agent
      └─ Reports result via Telegram
```

- **Boot**: registers cron jobs, starts heartbeat
- **Heartbeat**: periodic check — sends Telegram only if issues are found
- **CRONS.md**: define recurring tasks that auto-register on boot

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
│   └── install.bat        # Installer (Windows)
└── .claude/
    ├── settings.json      # Permissions and hooks
    └── skills/            # Skill definitions (behavior logic)
        ├── REQUIRED.md    # Essential skills — do not delete
        ├── IMPORTED.md    # Externally imported skills
        ├── boot/
        ├── heartbeat/
        ├── channel-task/
        ├── ccc-defaults/
        └── setup/
            └── templates/ # Personal config templates (generated on first boot)
```

Personal config files (`SOUL.md`, `USER.md`, `CRONS.md`, etc.) live in `~/.cccbot/` and are not tracked by git.

---

## Skills

Skills in `.claude/skills/` define the authoritative behavior logic. The `.md` files above are user-configurable inputs that skills read.

| Skill | Purpose |
|-------|---------|
| `boot` | Session start sequence |
| `heartbeat` | Periodic liveness check |
| `channel-task` | Standard flow for channel messages |
| `ccc-defaults` | Workspace-wide defaults (HTTP, git, Telegram) |

### Skill Registry Files

| File | Purpose |
|------|---------|
| `REQUIRED.md` | Essential CCC skills — do NOT delete these |
| `IMPORTED.md` | Externally imported skills with source URLs and install dates |
