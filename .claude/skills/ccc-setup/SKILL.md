---
name: ccc-setup
description: First-run interactive setup — generate config files and guide user through persona/identity configuration
---

# CCC Setup Skill

Interactive first-run setup. Generates config files via `setup.sh`/`setup.bat`, then guides the user through persona and identity configuration.

## When to Run

Called by `ccc-boot` when required files are missing. Can also be run manually.

## Steps

### 1. Copy structural templates (if not already done)

Run the setup script to copy structural config files (CLAUDE.md, CRONS.md, BOOT.md, HEARTBEAT.md):

- **Unix/WSL/Git Bash:** `bash scripts/setup.sh`
- **Windows (cmd):** `scripts\setup.bat`

Detect the platform and run the appropriate script.

### 2. Create SOUL.md and USER.md from templates

Copy the templates as starting points (these will be customized in the interactive step):

- `scripts/templates/SOUL.example.md` → `SOUL.md`
- `scripts/templates/USER.example.md` → `USER.md`

Only copy if the files don't already exist.

### 3. Greet the user via Telegram

**Always send the greeting via Telegram** (using the reply MCP tool). This is the user's first contact with the bot — they need to see it in their messaging app.

```
Welcome to CCCBot!
Let's set up your workspace. I'll ask a few questions here.
```

### 4. Interactive configuration (via Telegram)

Guide the user through the following, one at a time. Ask questions via Telegram and write their answers to the corresponding files.

**USER.md — Who are you?**
- Name / handle
- Role (developer, designer, etc.)
- Projects and interests
- Preferred language for conversation

**SOUL.md — Assistant persona**
- Persona name and style (e.g., concise, friendly, formal)
- Tone preferences
- Values and boundaries

**CRONS.md — Scheduled jobs (optional)**
- Ask if they want to set up any recurring tasks
- If not, skip

### 5. Done

Send via Telegram:
```
Setup complete! Starting session now.
```

Then return control to the boot skill to continue the boot sequence.

## Usage

```
/ccc-setup
```
