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
| `SOUL.example.md` | `SOUL.md` | Persona and tone |
| `IDENTITY.example.md` | `IDENTITY.md` | Name and role |
| `USER.example.md` | `USER.md` | Operator info |
| `CRONS.example.md` | `CRONS.md` | Scheduled jobs |
| `BOOT.example.md` | `BOOT.md` | Boot checklist |
| `HEARTBEAT.example.md` | `HEARTBEAT.md` | Heartbeat checklist |
| `TOOLS.example.md` | `TOOLS.md` | MCP tools and project paths |
| `.mcp.json.example` | `.mcp.json` | MCP config (bot token) |

## Steps

For each file in the table above:
1. Check if the target file exists in the project root
2. If missing: copy the template to the target path
3. Log which files were created

After generating files:
- Notify the user (via Telegram if available, otherwise print): "First-run setup complete. Edit the following files to configure your workspace: [list of created files]"
- If `.mcp.json` was created, add a note: "Add your Telegram bot token to .mcp.json"

## Usage

Called automatically by boot skill on first run. Can also be run manually:
```
/setup
```
