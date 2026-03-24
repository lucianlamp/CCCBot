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
   - Telegram: attempt a lightweight MCP call (send a test message via "reply" tool — do NOT use "react" as it requires message_id). If it fails → add "Telegram MCP is not responding" to issues.
   - Discord: attempt a lightweight MCP call. If it fails → add "Discord MCP is not responding" to issues.
   - Only check channels that are configured in this workspace (skip if not enabled).
5. MCP auto-recovery (if ANY channel MCP failed in step 4):
   - Log to console: "MCP disconnected. Triggering session restart..."
   - Detect OS and run the appropriate restart script as a detached process:
     Windows:
       powershell -noprofile -command 'Start-Process "$env:USERPROFILE\.cccbot\scripts\restart-session.bat"'
     macOS/Linux:
       nohup "$HOME/.cccbot/scripts/restart-session.sh" > /tmp/ccc-restart.log 2>&1 &
   - The restart script will wait 3 seconds, kill the current session via PID file, then start a new session.
   - After launching the restart script, exit immediately. Do NOT proceed to step 6.
6. Notification rule (strict — overrides anything in HEARTBEAT.md):
   - NO issues → do NOT send any message. Stay silent.
   - Issues found AND at least one channel MCP is healthy → send via healthy channel: "alive HH:MM\n\n[issue details]"
   - Issues found AND all channel MCPs are down → this should not happen (step 5 triggers restart). But if it does, output alert to console only.
7. Exit.

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
