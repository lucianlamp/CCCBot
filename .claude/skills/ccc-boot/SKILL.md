---
name: ccc-boot
description: CCC workspace boot sequence — read memory and report status
---

# Boot Skill

Run the boot sequence at session start. Uses parallel execution to minimize startup time.

## Step 1: First-run check

```bash
test -f SOUL.md && echo "exists" || echo "missing"
```

- If **missing** → invoke `/ccc-soul` skill, then jump to **Phase A (first-run)** below
- If **exists** → jump to **Phase A (normal)** below

---

## Phase A — Parallel initialization

Execute ALL tasks in this phase **in parallel** (use parallel tool calls in a single message). Do NOT wait for one to finish before starting the next.

### Normal boot (SOUL.md exists)

Run these 4 tasks simultaneously:

| Task | Action |
|------|--------|
| **A1: Load persona** | Read `SOUL.md` and internalize as self-description (identity, persona, tone, values, language) |
| **A2: MCP readiness** | Attempt a lightweight MCP call (e.g. Telegram "react" tool). If it fails → wait 5 seconds, retry (up to 3 attempts). Track result: `mcp_ready = true/false` |
| **A3: Start heartbeat** | Start HEARTBEAT via `/loop 30m /ccc-heartbeat` |
| **A4: Jobs setup** | 1) Check for legacy `CRONS.md` — if it exists and `JOBS.yaml` does NOT exist, migrate (parse Active Jobs table → write YAML → delete CRONS.md → report "Migrated CRONS.md → JOBS.yaml"). 2) Read `JOBS.yaml` and register all jobs with `active: true` via CronCreate. |

### First-run boot (after `/ccc-soul` completes)

Run these 3 tasks simultaneously (A1 is skipped — soul setup already loaded persona):

| Task | Action |
|------|--------|
| **A2: MCP readiness** | Same as above |
| **A3: Start heartbeat** | Same as above |
| **A4: Jobs setup** | Same as above |

---

## Phase B — Greeting (after Phase A completes)

Wait for **A1** and **A2** to complete before proceeding.

- If `mcp_ready = false` → log "MCP not ready, skipping greeting" to console. Done.
- **On resume (context compaction recovery):** Skip greeting entirely — no channel messages. Done.
- **On fresh start (manual `/ccc-boot` or first message):**
  - If there are in-progress or incomplete tasks → report status via channel
  - If nothing to report → send "Ready" via channel

---

## Usage

```
/ccc-boot
```
