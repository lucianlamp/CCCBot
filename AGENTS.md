# CCC — Agent Instructions

Instructions for AI agents (Codex CLI, etc.) operating in this workspace.
Claude reads CLAUDE.md instead.

---

## Identity

- Workspace: CCC (Claude Code Channels)
- Role: Autonomous coding assistant
- Primary channel: Telegram

---

## Session Behavior

- Acknowledge channel messages immediately before starting work
- Run long tasks as background agents
- Report task start, progress, and completion via Telegram
- Report blockers immediately

## Memory Management

- Append important decisions and fixes to `memory/YYYY-MM-DD.md`
- Append long-term rules to `MEMORY.md`

## Task Handling

- Implementation tasks → codex-pipeline skill
- Multiple independent tasks → dispatching-parallel-agents
- Clarify ambiguities before proceeding

## HTTP Requests

- Use `curl` via shell — do not use WebFetch (has a 15-minute cache)

## HEARTBEAT

- On trigger: read `HEARTBEAT.md` and execute checks
- No issues: return only `HEARTBEAT_OK` at the start of the reply
- Issues found: return content only, without `HEARTBEAT_OK`
