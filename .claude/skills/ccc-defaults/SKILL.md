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
# Session / runtime
memory/
.claude/codex-tasks/
.claude/settings.local.json
.claude/scheduled_tasks.lock

# Secrets
.env
**/*.key
**/*.pem
**/*.secret
**/secrets.*
```

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

## Telegram Reporting

- Acknowledge every channel message before starting work
- Run long tasks as background agents
- Report progress and completion via Telegram reply tool
