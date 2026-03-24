---
name: ccc-boot
description: CCC workspace boot sequence — persona load + background agent orchestration
---

# Boot Skill

Boot orchestrator. The SessionStart hook provides these values in the hook context:
- `Session started (startup|resume)` — event source
- `SOUL.md status: exists|missing` — pre-checked by hook
- `Current transcript: <path>` — current session's JSONL (always present)
- `Previous session transcript: <path>` — only on startup, if a previous session exists

Use these directly. No bash checks needed.

## Execution

**Phase 1** — Single message with parallel tool calls (foreground + background agents):

| # | Type | Action |
|---|------|--------|
| 1 | **Foreground** | If SOUL.md **exists**: Read `SOUL.md` and internalize as self-description (identity, persona, tone, values, language). If SOUL.md **missing**: invoke `/ccc-soul` skill (interactive persona setup), then read the created `SOUL.md`. |
| 2 | **Background Agent** | **MCP check + greeting** — prompt changes by source (see below) |
| 3 | **Background Agent** | **Session context review** — always launch (see below for prompt by source). Skip only if no transcript path is available. |

**Phase 2** — After Phase 1 completes, register crons in the **main session** (Cron tools are not available to subagents):

| # | Action |
|---|--------|
| 4 | **Heartbeat registration** — Use CronList to check if a heartbeat cron already exists (look for 'ccc-heartbeat' in prompt text). If it already exists, do nothing. If not found, use CronCreate with `schedule='*/30 * * * *'` and `prompt='Run /ccc-heartbeat skill (invoke Skill tool with skill=ccc-heartbeat)'`. |
| 5 | **Jobs registration** — Check if CRONS.md exists AND JOBS.yaml does NOT — if so, migrate: parse Active Jobs table, write JOBS.yaml, delete CRONS.md. Then read JOBS.yaml. If missing or empty, skip. Otherwise use CronList to get existing crons, then for each job with `active: true`, register via CronCreate if not already registered (match by prompt content). |

### #2 prompt by source

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

### #3 Previous session review

`description='review previous session'`, `run_in_background=true`.

```
Review the previous session transcript and report anything worth carrying forward.
1) Read the transcript JSONL file at: <Previous session transcript path from hook context>
2) Scan for: incomplete tasks, pending decisions, unresolved errors, user requests that weren't finished.
3) If nothing actionable found, exit silently.
4) If actionable items found, read .claude/access.json to get chat_id, then send a brief summary via Telegram reply to chat_id. Format:
   "📋 前セッションの引き継ぎ:
   • <item 1>
   • <item 2>"
5) Exit.
```

## Done

Main session is ready once Phase 2 completes. Background agents (#2, #3) continue independently.

## Usage

```
/ccc-boot
```
