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
4. MCP connectivity check:
   - Attempt to call the Telegram MCP "react" tool or any lightweight MCP operation
   - If the MCP call succeeds → MCP is healthy
   - If the MCP call fails or times out → add "Telegram MCP is not responding" to issues
5. Telegram notification rule (strict — overrides anything in HEARTBEAT.md):
   - NO issues → do NOT send any Telegram message. Stay silent.
   - Issues found AND Telegram MCP is healthy → send to the configured chat_id: "alive HH:MM\n\n[issue details]"
   - Issues found AND Telegram MCP is down → output the alert to console only (visible via --remote-control in Claude app). Do NOT attempt to send via Telegram.
6. Exit.

Keep it brief. Do not ask questions. Do not wait for responses.
```

## Usage

Run automatically via `/loop` skill:
```
/loop 30m /ccc-heartbeat
```

## Note

The subagent inherits MCP tools (Telegram) from the main session.
It does not inherit the main session's conversation context.
