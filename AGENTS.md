# Project Context for Codex

## Overview
CCCBot is an autonomous agent built on Claude Code Channels. It connects Claude Code to Telegram/Discord and adds scheduled tasks, heartbeat monitoring, and persona configuration. The project is shell scripts and batch files — no Node.js runtime or build tools.

## Tech Stack
- Language: Bash (Mac/Linux/WSL), Batch/cmd.exe + PowerShell (Windows)
- No package.json, no build system, no test framework
- Git for version control
- GitHub Releases for distribution

## Directory Structure
- `start.sh` / `start.bat` — Bot launcher entry points
- `bin/` — CLI wrapper scripts (`cccbot` command)
- `scripts/` — Installer and utility scripts
- `scripts/lib/` — Shared bash library functions (json-parse, resolve-workspace, add-directory)
- `scripts/templates/` — Default config file templates
- `.claude/skills/` — Claude Code skill definitions
- `.claude/scripts/` — Claude Code hooks
- `workspace/` — Default working directory for the bot

## Coding Conventions
- Shell scripts use `#!/usr/bin/env bash` shebang for portability
- Batch files use `@echo off` and `goto` for flow control
- PowerShell is used inline in batch files for complex operations (JSON parsing, PATH manipulation)
- Shell lib functions follow the pattern: source from `scripts/lib/`, single-purpose per file
- Config is read from `cccbot.json` with env var overrides (env > config > default)
- Idempotent operations: always check before modifying (grep before appending, `if exist` before creating)

## Key Scripts
- `scripts/install.sh` / `scripts/install.bat` — Download-based installer (also handles updates)
- `start.sh` / `start.bat` — Session launcher with PID tracking and config loading

## Skills Reference
- bat ファイルは複雑な変数トラッキングを避け最小限に保つ
- .gitignore.default（テンプレート）と .gitignore（実運用）は別管理で同期しない
- install.sh と install.bat は同じ機能を提供するが、実装はプラットフォーム固有

## Constraints
- Do NOT modify files outside the task scope
- Do NOT add dependencies (no package.json exists)
- Follow existing patterns: sh for Unix, bat+PowerShell for Windows
- User config files (CLAUDE.md, SOUL.md, cccbot.json, etc.) are gitignored
- .env, access.json, .mcp.json は読みに行かない
