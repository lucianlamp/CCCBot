---
name: boot
description: CCC workspace boot sequence — read memory and report status
---

# Boot Skill

Run the boot sequence at session start.

## Steps

1. **First-run check:** If any of `SOUL.md`, `IDENTITY.md`, `USER.md`, `CRONS.md` are missing from the project root, invoke the `/setup` skill to generate them from templates before proceeding.
2. If there are in-progress or incomplete tasks, report status via Telegram
3. Start HEARTBEAT via `/loop 30m /heartbeat` (CronCreate with `*/30 * * * *` + prompt `/heartbeat` + recurring true)
3. Read CRONS.md and register all Active Jobs via CronCreate
4. **Git setup check:**
   - Run `git rev-parse --git-dir 2>/dev/null` — if it fails, git is not initialized
   - If not initialized: run `git init`, then create `.gitignore` from the template in ccc-defaults skill
   - If `.gitignore` is missing even in an existing repo, create it from the template
5. If nothing to report, just respond "Ready"

## Usage

```
/boot
```
