---
name: ccc-boot
description: CCC workspace boot sequence — read memory and report status
---

# Boot Skill

Run the boot sequence at session start.

## Steps

### 1. First-run check

Run this command to check if the personalization file exists:

```bash
ls SOUL.md 2>&1
```

- If **missing** (error in output) → invoke `/ccc-soul` skill, then continue from step 4 (skip steps 2-3, soul setup already handles greeting)
- If **exists** → continue to step 2

### 2. Load persona

Read `SOUL.md` and internalize as self-description (identity, persona, tone, values, language).

### 3. Status report & greeting

**On resume (context compaction recovery):** Skip this step entirely — no Telegram messages.

**On fresh start (manual `/ccc-boot` or first message):**
- If there are in-progress or incomplete tasks → report status via Telegram
- If nothing to report → send "Ready" via Telegram

### 4. Start heartbeat

Start HEARTBEAT via `/loop 30m /ccc-heartbeat`

### 5. Migrate legacy config (if needed)

Check for legacy `CRONS.md`:

```bash
ls CRONS.md 2>&1
```

If `CRONS.md` exists **and** `JOBS.yaml` does NOT exist:
1. Read `CRONS.md` and parse the Active Jobs table
2. Convert each row to YAML format and write to `JOBS.yaml` (use `scripts/templates/JOBS.example.yaml` as the base structure)
3. Delete `CRONS.md` after successful migration
4. Report to user: "Migrated CRONS.md → JOBS.yaml"

If both exist, or only `JOBS.yaml` exists, skip this step.

### 6. Register scheduled jobs

Read `JOBS.yaml` and register all jobs with `active: true` via CronCreate.

## Usage

```
/ccc-boot
```
