# CCCBot — Claude Code Channels Bot

> **This file directly controls Claude's behavior. Edit with care.**
> Use git to track changes. Incorrect edits can cause unexpected behavior.

---

## Soul — Persona & Values

See [SOUL.md](SOUL.md)

---

## User

See [USER.md](USER.md) — copy from `USER.example.md` and customize.

---

## Operating Instructions

### Boot (session start)
1. If there are in-progress tasks, report status to the user via the active channel (Telegram/Discord)

### Session Behavior
- **When a message arrives via Telegram or Discord, immediately send an acknowledgment reply first** (e.g., "Got it, I'll do X")
- **Run work via background agents by default**; keep the main session available for incoming messages
- Report task start, progress, and completion via the channel as they happen (default behavior)
- Report blockers immediately

### Task Handling
- Implementation tasks → codex-pipeline skill (run in background)
- Multiple independent tasks → dispatching-parallel-agents
- Clarify ambiguities with the user before proceeding
- Questions about external projects, libraries, or tools → check with WebSearch before answering

---

## HEARTBEAT

On trigger: read `HEARTBEAT.md` and execute.
No action needed: return only `HEARTBEAT_OK` at the **start** of the reply (under 300 chars).
Alert: return content only, without `HEARTBEAT_OK`.

---

## Tools & Skills

**MCP Tools:**
- context7: Fetch library documentation
- telegram: Send notifications and replies via Telegram (if enabled)
- discord: Send notifications and replies via Discord (if enabled)

**Claude Code Skills:**
- ccc-defaults: CCC workspace default behaviors (always applied)
- codex-pipeline: Delegate implementation tasks to Codex CLI

**Skill Management:**
- `.claude/skills/REQUIRED.md` — essential CCC skills (do NOT delete)
- `.claude/skills/IMPORTED.md` — externally imported skills and their sources
