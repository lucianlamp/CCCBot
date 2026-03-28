---
name: ccc-heartbeat
description: CCC HEARTBEAT execution — spawns a background subagent for periodic liveness check and Telegram notification
---

# Heartbeat Skill

Spawns a background subagent to run periodic checks.
The main session is released immediately after the subagent is launched.

## Steps

1. Launch a subagent with `run_in_background=true`
2. Main session exits immediately (does not wait for subagent completion)

## Background Subagent Prompt

Prompt to pass to the subagent:

```
You are a heartbeat agent for the CCC workspace.

Steps:
1. Run: bash .claude/skills/ccc-heartbeat/scripts/check.sh
2. Read HEARTBEAT.md for user-defined checks to perform
3. Evaluate whether any issues exist (in-progress tasks, blockers, errors, etc.)
4. MCP connectivity check (for each enabled channel):
   - Telegram: check if MCP tools (reply, react) are available in the tool list. Do NOT call them — just confirm they exist. If not available → add "Telegram MCP is not responding" to issues.
   - Discord: check if Discord MCP tools are available. If not → add "Discord MCP is not responding" to issues.
   - Only check channels that are configured in this workspace (skip if not enabled).
5. Notification rule (strict — overrides anything in HEARTBEAT.md):
   - NO issues → do NOT send any message. Stay silent.
   - Issues found AND at least one channel MCP is healthy → send issue details via healthy channel (no "alive" prefix)
   - Issues found AND all channel MCPs are down → output alert to console only.
6. Exit.

Keep it brief. Do not ask questions. Do not wait for responses.
```

## Usage

Registered automatically at session start by SessionStart hook (background agent).
Can also be started manually:
```
/loop 30m /ccc-heartbeat
```

## Note

The subagent inherits MCP tools (Telegram) from the main session.
It does not inherit the main session's conversation context.
