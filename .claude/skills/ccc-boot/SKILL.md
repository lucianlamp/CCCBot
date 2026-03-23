---
name: ccc-boot
description: CCC workspace boot sequence — read memory and report status
---

# Boot Skill

Run the boot sequence at session start.

## Steps

1. **First-run check:** If `SOUL.md` or `USER.md` is missing from the project root, invoke `/ccc-setup` to create them interactively and greet the user via Telegram. (Structural files like CLAUDE.md are created by the install script, but SOUL.md and USER.md require interactive setup.)
2. Read `SOUL.md` and internalize as self-description (identity, persona, tone, values)
3. If there are in-progress or incomplete tasks, report status via Telegram
4. Start HEARTBEAT via `/loop 30m /ccc-heartbeat` (CronCreate with `*/30 * * * *` + prompt `/ccc-heartbeat` + recurring true)
5. Read CRONS.md and register all Active Jobs via CronCreate
6. **Send ready notification via Telegram** — always send at least "Ready" so the user knows the bot is online. **Skip this if `/ccc-setup` was invoked in step 1** (setup already sends its own greeting).

## Usage

```
/ccc-boot
```
