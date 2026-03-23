---
name: ccc-boot
description: CCC workspace boot sequence — read memory and report status
---

# Boot Skill

Run the boot sequence at session start.

## Steps

### 1. First-run check

Run this command to check if personalization files exist:

```bash
ls SOUL.md USER.md 2>&1
```

- If **either file is missing** (error in output) → invoke `/ccc-setup` skill, then continue from step 4 (skip steps 2-3, setup already handles greeting)
- If **both exist** → continue to step 2

### 2. Load persona

Read `SOUL.md` and internalize as self-description (identity, persona, tone, values, language).

### 3. Status report & greeting

- If there are in-progress or incomplete tasks → report status via Telegram
- If nothing to report → send "Ready" via Telegram

### 4. Start heartbeat

Start HEARTBEAT via `/loop 30m /ccc-heartbeat`

### 5. Register cron jobs

Read `CRONS.md` and register all Active Jobs via CronCreate.

## Usage

```
/ccc-boot
```
