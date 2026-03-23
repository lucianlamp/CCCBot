---
name: ccc-setup
description: First-run interactive setup — generate config files and guide user through persona/identity configuration
---

# CCC Setup Skill

Interactive first-run setup. Creates config files and guides the user through workspace configuration via Telegram.

## When to Run

Called by `ccc-boot` when `SOUL.md` is missing. Can also be run manually with `/ccc-setup`.

## Steps

### 1. Ensure structural files exist

Run the setup script to copy structural config files (CLAUDE.md, JOBS.yaml, BOOT.md, HEARTBEAT.md) if not already present:

```bash
bash scripts/setup.sh
```

(On Windows cmd: `scripts\setup.bat`)

### 2. Create SOUL.md from template

Use the Write tool to copy template contents as a starting point:

- Read `scripts/templates/SOUL.example.md` → Write to `SOUL.md`

Only create if the file doesn't already exist.

### 3. Greet via Telegram

Send the first message via Telegram (reply MCP tool). This is the user's first contact with the bot.

```
Welcome to CCCBot!
Let me set up your workspace. I'll ask a few quick questions.
```

### 4. Interactive configuration (via Telegram)

Ask one question at a time via Telegram. Wait for each answer before asking the next. Write all answers to `SOUL.md` immediately.

**Q1: Language**
Ask: "What language should I use? (e.g., English, 日本語)"
→ Write to `SOUL.md` User > Language AND remove the old Language section at the bottom.
→ Switch to the chosen language for all subsequent messages.

**Q2: Your name**
Ask: "What should I call you? (name or handle)"
→ Write to `SOUL.md` User > Handle field.

**Q3: Bot name**
Ask: "What should my name be? (default: CCC)"
→ Write to `SOUL.md` Identity > Name field.

**Q4: Bot personality**
Ask: "How should I behave? Pick a style or describe your own:"
Offer examples: "1. Concise & technical  2. Friendly & casual  3. Formal & thorough  4. Custom"
→ Write to `SOUL.md` Persona and Tone sections.

**Q5: Scheduled tasks (optional)**
Ask: "Want to set up any recurring tasks? (e.g., daily reports, periodic checks) If not, just say 'skip'."
→ If yes, write to `JOBS.yaml`. If skip, move on.

### 5. Done

Send via Telegram:
```
Setup complete! Starting session now.
```

Return control to the boot skill to continue the boot sequence (heartbeat, crons).

## Design Notes

- **SOUL.md is the single personalization file.** It contains both user info (handle, language) and bot config (identity, persona, tone, values, boundaries).
- **User details are minimal by design.** Only name/handle and language are asked at setup. Role, projects, expertise, and preferences are learned automatically through interactions and stored via the auto-memory system.

## Usage

```
/ccc-setup
```
