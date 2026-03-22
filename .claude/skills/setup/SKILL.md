---
name: setup
description: First-run setup — generate personal config files from templates if they don't exist
---

# Setup Skill

Creates personal config files from templates on first run.

## When to Run

Called by the `boot` skill when required files are missing.

## Templates Location

`.claude/skills/setup/templates/`

## Files to Generate

| Template | Target | Notes |
|----------|--------|-------|
| `CLAUDE.example.md` | `CLAUDE.md` | Workspace instructions for Claude |
| `SOUL.example.md` | `SOUL.md` | Identity, persona and tone |
| `USER.example.md` | `USER.md` | Operator info |
| `CRONS.example.md` | `CRONS.md` | Scheduled jobs |
| `BOOT.example.md` | `BOOT.md` | Boot checklist |
| `HEARTBEAT.example.md` | `HEARTBEAT.md` | Heartbeat checklist |
| `TOOLS.example.md` | `TOOLS.md` | MCP tools and project paths |
| `.mcp.json.example` | `.mcp.json` | MCP config (bot token) |

## Git Setup

Before generating files, ensure the workspace has git and a `.gitignore`:

1. Run `git rev-parse --git-dir 2>/dev/null` — if it fails, run `git init`
2. If `.gitignore` is missing, create it with this content:

```gitignore
# MCP config (contains bot tokens)
.mcp.json

# Runtime / session data
memory/
.claude/scheduled_tasks.lock

# Local machine overrides
.claude/settings.local.json

# Security: Telegram access list
.claude/access.json
**/access.json

# Secrets and credentials
.env
**/*.key
**/*.pem
**/*.secret
**/secrets.*
**/credentials.*
```

## Steps

For each file in the table above:
1. Check if the target file exists in the project root
2. If missing: copy the template to the target path
3. Log which files were created

After generating files:

1. **Greet the user** (print to terminal, and via Telegram if available):

   ```
   👋 Welcome to CCCBot — Claude Code Channels Bot!

   I'm your autonomous assistant. Before we get started, let's set up your identity.

   Please edit these files to configure me:
     • CLAUDE.md    — Workspace instructions (skills, tools, behaviors)
     • SOUL.md      — My persona, tone, and values (who I am)
     • USER.md      — Info about you and your projects
     • .mcp.json    — Add your Telegram bot token to connect the channel

   Once you've edited them, run start.sh (or start.bat) again.
   ```

2. If `.mcp.json` was created, emphasize: "⚠️ Don't forget to add your Telegram bot token to .mcp.json — without it, I can't receive messages."

3. **Pause and wait** — do not proceed with the rest of boot until the user confirms they've configured the files (or explicitly says to skip).

## Usage

Called automatically by boot skill on first run. Can also be run manually:
```
/setup
```
