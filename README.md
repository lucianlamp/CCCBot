# CCC — Claude Code Channels

An autonomous Claude Code workspace connected to messaging channels (Telegram, etc.).

Claude runs persistently, receives tasks via Telegram, executes them in the background, and reports results — without requiring a terminal open.

---

## Quick Start

1. Clone this repo
2. Copy `.mcp.json.example` → `.mcp.json` and set your Telegram bot token
3. Copy `USER.example.md` → `USER.md` and fill in your details
4. Copy `CRONS.example.md` → `CRONS.md` and configure your scheduled jobs
5. Run `start.bat` (Windows) or `start.sh` (Unix)
6. Send a message from Telegram — Claude will respond

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

- **Boot**: reads memory, registers cron jobs, starts heartbeat
- **Heartbeat**: periodic check — sends Telegram only if issues are found
- **CRONS.md**: define recurring tasks that auto-register on boot

---

## Customizable Files

These files are yours to edit — they define behavior for your workspace:

| File | Purpose |
|------|---------|
| `CLAUDE.md` | **Core config — controls Claude's behavior. Edit with care.** |
| `SOUL.md` | Persona, tone, values |
| `IDENTITY.md` | Name, role, context |
| `USER.md` | Info about the operator |
| `BOOT.md` | What to do at session start |
| `HEARTBEAT.md` | What to check on each heartbeat cycle |
| `CRONS.md` | Recurring scheduled tasks |
| `MEMORY.md` | Long-term memory index |

> **CLAUDE.md** is the most critical file — it directly controls Claude's instructions.
> Incorrect edits can change behavior in unexpected ways. Use git to track changes.

---

## Project Structure

```
.
├── CLAUDE.md              # Primary Claude config (edit with care)
├── SOUL.md / IDENTITY.md  # Persona and identity
├── BOOT.md / HEARTBEAT.md # Session lifecycle hooks
├── CRONS.md               # Scheduled tasks
├── MEMORY.md              # Memory index
├── start.bat / start.sh   # Launchers
└── .claude/
    ├── settings.json      # Permissions and hooks
    └── skills/            # Skill definitions (behavior logic)
        ├── REQUIRED.md    # Essential skills — do not delete
        ├── IMPORTED.md    # Externally imported skills
        ├── boot/
        ├── heartbeat/
        ├── channel-task/
        └── ccc-defaults/
```

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
