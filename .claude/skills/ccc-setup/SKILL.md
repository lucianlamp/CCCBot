---
name: ccc-setup
description: First-run interactive setup — generate config files and guide user through persona/identity configuration
---

# CCC Setup Skill

Interactive first-run setup. Generates config files via `setup.sh`/`setup.bat`, then guides the user through persona and identity configuration.

## When to Run

Called by `ccc-boot` when required files are missing. Can also be run manually.

## Steps

### 1. Generate config files

Run the setup script to copy templates:

- **Unix/WSL/Git Bash:** `bash scripts/setup.sh`
- **Windows (cmd):** `scripts\setup.bat`

Detect the platform and run the appropriate script.

### 2. Greet the user

Print to terminal (and via Telegram if available):

```
Welcome to CCCBot — Claude Code Channels Bot!

I'm your autonomous assistant. Let's set up your workspace.
```

### 3. Interactive configuration

Guide the user through the following, one at a time. Ask questions and write their answers to the corresponding files.

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

### 4. Done

```
Setup complete! Run /ccc-boot to start a fresh session with your new config.
```

## Usage

```
/ccc-setup
```
