---
name: boot
description: CCC workspace boot sequence — read memory and report status
---

# Boot Skill

Run the boot sequence at session start.

## Steps

1. Run `scripts/load-memory.sh` to load memory (MEMORY.md + today's/yesterday's logs)
2. If there are in-progress or incomplete tasks, report status via Telegram
3. Start HEARTBEAT via `/loop 30m /heartbeat` (CronCreate with `*/30 * * * *` + prompt `/heartbeat` + recurring true)
4. If nothing to report, just respond "Ready"

## Usage

```
/boot
```
