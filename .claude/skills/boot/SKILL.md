---
name: boot
description: CCC workspace boot sequence — read memory and report status
---

# Boot Skill

Run the boot sequence at session start.

## Steps

1. **First-run check:** If any of `CLAUDE.md`, `SOUL.md`, `USER.md`, `CRONS.md` are missing from the project root, invoke the `/setup` skill to generate them from templates before proceeding.
2. Read `SOUL.md` and internalize as self-description (identity, persona, tone, values)
3. If there are in-progress or incomplete tasks, report status via Telegram
4. Start HEARTBEAT via `/loop 30m /heartbeat` (CronCreate with `*/30 * * * *` + prompt `/heartbeat` + recurring true)
5. Read CRONS.md and register all Active Jobs via CronCreate
6. If nothing to report, just respond "Ready"

## Usage

```
/boot
```
