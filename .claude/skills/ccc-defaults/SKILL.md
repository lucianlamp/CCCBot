---
name: ccc-defaults
description: CCC workspace default behaviors — always applied in this workspace
---

# CCC Default Behaviors

These rules are always applied in the CCC workspace. They override general defaults.

## HTTP Requests

**Always use `curl` via Bash, never WebFetch.**

```bash
curl -s "https://api.example.com/endpoint"
```

**Why:** WebFetch has a 15-minute cache, making it unsuitable for real-time data (prices, status, etc.). `curl` always fetches fresh data.

**WebFetch is only acceptable for:** parsing static documentation pages where caching is harmless.

## Git Setup

**Every workspace must have git initialized and a .gitignore.**

This is checked at boot. If missing, initialize automatically:

```bash
# Check
git rev-parse --git-dir 2>/dev/null || git init

# Create .gitignore if missing
```

**.gitignore template for CCC workspaces:**

```gitignore
# Runtime / session data (changes every session, not reproducible from config)
memory/
.claude/scheduled_tasks.lock

# Local machine overrides (never share between machines)
.claude/settings.local.json

# Security: Telegram access list contains allowed user IDs
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

**What TO commit:**
- `CLAUDE.md`, `SOUL.md`, `USER.md`, `AGENTS.md`, `TOOLS.md` — workspace identity
- `BOOT.md`, `HEARTBEAT.md`, `CRONS.md` — operational config
- `MEMORY.md` — memory index (not daily logs)
- `.claude/settings.json` — base permissions and hooks (no secrets)
- `.claude/skills/**` — all skill definitions
- `.mcp.json` — MCP server list (only if it contains no tokens/credentials)
- `start.bat`, `start.sh` — launchers

## Git History Management

**Commit after every meaningful change.**

Trigger: after completing a task that modifies files (config, skills, scripts, docs).

```bash
git add <specific files>   # never git add -A or git add .
git commit -m "short description"
```

**Security rules (conservative):**
- Stage files explicitly by name — never `git add -A` or `git add .`
- Never commit: `.env`, `*.key`, `*.pem`, `settings.local.json`, `memory/`, files with tokens/passwords
- If unsure whether a file is safe to commit, skip it and ask
- Never force-push, never `--no-verify`

**Commit message format:** one concise line describing what changed and why.

## Cron Deduplication

**Always wrap bash commands in cron prompts with a lock file check.**

Cron triggers can fire 2–3× in the same interval due to scheduler jitter. Without deduplication, this causes duplicate API calls and duplicate Telegram messages.

**Pattern:**

```bash
LOCK=/tmp/ccc-<job-id>; NOW=$(date +%s); if [ -f "$LOCK" ] && [ $((NOW - $(cat "$LOCK"))) -lt <threshold>; then echo "SKIP"; else echo $NOW > "$LOCK"; <your command>; fi
```

**Threshold = ~75% of the cron interval in seconds:**

| Interval | Threshold |
|----------|-----------|
| `*/2 * * * *` (2 min) | 90s |
| `*/5 * * * *` (5 min) | 225s |
| `*/10 * * * *` (10 min) | 450s |
| `0 * * * *` (hourly) | 2700s |

**In the cron prompt, add:** "If output is `SKIP`, stop here and do nothing."

**Why not just ignore duplicates manually?** Manual dedup (skipping extra triggers in context) still executes the bash command and hits the API. The lock file prevents the API call itself.

## Telegram Reporting

- Acknowledge every channel message before starting work
- Run long tasks as background agents
- Report progress and completion via Telegram reply tool
