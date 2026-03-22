---
name: heartbeat
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
1. Run: bash .claude/skills/heartbeat/scripts/check.sh
2. Read HEARTBEAT.md
3. Send a Telegram message to chat_id 1688027728 ONLY if issues are found:
   - If no issues: do NOT send any message
   - If issues found: send "alive HH:MM\n\n[issue details]"
4. Exit.

Keep it brief. Do not ask questions. Do not wait for responses.
```

## Usage

Run automatically via `/loop` skill:
```
/loop 30m /heartbeat
```

## Note

The subagent inherits MCP tools (Telegram) from the main session.
It does not inherit the main session's conversation context.
