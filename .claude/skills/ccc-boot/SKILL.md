---
name: ccc-boot
description: CCC workspace boot sequence — persona load + background agent orchestration
---

# Boot Skill

Boot orchestrator. The SessionStart hook provides two values in the hook context:
- `Session started (startup|resume)` — event source
- `SOUL.md status: exists|missing` — pre-checked by hook

Use these directly. No bash checks needed.

## Execution

Execute ALL of the following in a **single message** with parallel tool calls.
Background agents do NOT depend on SOUL.md and always launch immediately.

| # | Type | Action |
|---|------|--------|
| 1 | **Foreground** | If SOUL.md **exists**: Read `SOUL.md` and internalize as self-description (identity, persona, tone, values, language). If SOUL.md **missing**: invoke `/ccc-soul` skill (interactive persona setup), then read the created `SOUL.md`. |
| 2 | **Background Agent** | **Heartbeat registration** — `description='register heartbeat cron'`, `run_in_background=true`. Prompt: `"Register the CCC heartbeat cron job. 1) Use CronList to check if a heartbeat cron already exists (look for 'ccc-heartbeat' in prompt text). 2) If it already exists, do nothing and exit. 3) If not found, use CronCreate with schedule='*/30 * * * *' and prompt='Run /ccc-heartbeat skill (invoke Skill tool with skill=ccc-heartbeat)'. 4) Exit."` |
| 3 | **Background Agent** | **Jobs registration** — `description='register scheduled jobs'`, `run_in_background=true`. Prompt: `"Register scheduled jobs from JOBS.yaml. 1) Check if CRONS.md exists AND JOBS.yaml does NOT — if so, migrate: parse Active Jobs table, write JOBS.yaml, delete CRONS.md. 2) Read JOBS.yaml. If missing or empty, exit. 3) Use CronList to get existing crons. 4) For each job with active:true, register via CronCreate if not already registered (match by prompt content). 5) Exit."` |
| 4 | **Background Agent** | **MCP check + greeting** — `description='MCP check and greeting'`, `run_in_background=true`. Prompt changes based on event source: |

### #4 prompt by source

**startup** (fresh session):
```
Check MCP health and send greeting.
1) Read .claude/access.json to get chat_id.
2) Attempt a lightweight Telegram MCP call (e.g. 'react' tool). If it fails, wait 5s and retry (up to 3 attempts). Track mcp_ready.
3) If mcp_ready=false, log 'MCP not ready' to console and exit.
4) If mcp_ready=true, check for in-progress tasks.
5) If tasks exist, send status via Telegram reply to chat_id.
6) If nothing to report, send 'Ready' via Telegram reply to chat_id.
7) Exit.
```

**resume** (context compaction recovery):
```
Check MCP health silently. No greeting.
1) Attempt a lightweight Telegram MCP call (e.g. 'react' tool). If it fails, wait 5s and retry (up to 3 attempts). Track mcp_ready.
2) If mcp_ready=false, log 'MCP not ready' to console.
3) Exit. Do NOT send any message.
```

## Done

Main session is ready once #1 completes. Background agents continue independently.

## Usage

```
/ccc-boot
```
