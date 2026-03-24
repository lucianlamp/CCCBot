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
| 2 | **Background Agent** | **MCP health check** — silent check, no greeting (see below) |
| 3 | **Background Agent** | **Session context review** — always launch (see below for prompt by source). Skip only if no transcript path is available. |

**Phase 2** — After Phase 1 completes, register crons in the **main session** (Cron tools are not available to subagents):

| # | Action |
|---|--------|
| 4 | **Heartbeat registration** — Use CronList to check if a heartbeat cron already exists (look for 'ccc-heartbeat' in prompt text). If it already exists, do nothing. If not found, use CronCreate with `schedule='*/30 * * * *'` and `prompt='Run /ccc-heartbeat skill (invoke Skill tool with skill=ccc-heartbeat)'`. |
| 5 | **Jobs registration** — Check if CRONS.md exists AND JOBS.yaml does NOT — if so, migrate: parse Active Jobs table, write JOBS.yaml, delete CRONS.md. Then read JOBS.yaml. If missing or empty, skip. Otherwise use CronList to get existing crons, then for each job with `active: true`, register via CronCreate if not already registered (match by prompt content). |

### #2 MCP health check

`description='MCP health check'`, `run_in_background=true`. Same prompt for both startup and resume:

```
Check MCP health silently.
1) Attempt a lightweight Telegram MCP call (send a short test message via 'reply' tool — do NOT use 'react' as it requires message_id). If it fails, wait 5s and retry (up to 3 attempts). Track mcp_ready.
2) If mcp_ready=false, log 'MCP not ready' to console.
3) Exit. Do NOT send any greeting or notification.
```

### #3 Previous session review

`description='review previous session'`, `run_in_background=true`.

```
Review the previous session transcript and report anything worth carrying forward.
1) Read the transcript JSONL file at: <Previous session transcript path from hook context>
2) Scan for: incomplete tasks, pending decisions, unresolved errors, user requests that weren't finished.
3) If nothing actionable found, exit silently.
4) If actionable items found, send a brief summary via Telegram reply. Format:
   "📋 前セッションの引き継ぎ:
   • <item 1>
   • <item 2>"
5) Exit.
```

**Phase 3** — Boot completion (main session, after Phase 2):

- If source is **startup**: send a boot completion greeting via Telegram `reply` tool (e.g. "Boot complete. Ready."). MCP is loaded at this point so `reply` works.
- If source is **resume**: do NOT send any message. Silent.

## Done

Main session is ready once Phase 3 completes. Background agents (#2, #3) continue independently.

## Usage

```
/ccc-boot
```
