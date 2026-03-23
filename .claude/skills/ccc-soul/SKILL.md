---
name: ccc-soul
description: Interactive SOUL.md configuration — persona, identity, language, and personality setup via Telegram
---

# CCC Soul Skill

Interactive persona/identity configuration. Guides the user through SOUL.md setup via Telegram.

## When to Run

Called by `ccc-boot` when `SOUL.md` is missing. Can also be run manually with `/ccc-soul`.

## Steps

### 1. Create SOUL.md from template

Use the Write tool to copy template contents as a starting point:

- Read `scripts/templates/SOUL.example.md` → Write to `SOUL.md`

Only create if the file doesn't already exist.

### 2. Greet via Telegram

Send the first message via Telegram (reply MCP tool). This is the user's first contact with the bot.

```
Welcome to CCCBot!
Let me set up your persona. I'll ask a few quick questions.
```

### 3. Interactive configuration (via Telegram)

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

### 4. Done

Send via Telegram:
```
Soul configured! Starting session now.
```

Return control to the boot skill to continue the boot sequence (heartbeat, crons).

## Design Notes

- **SOUL.md is the single personalization file.** It contains both user info (handle, language) and bot config (identity, persona, tone, values, boundaries).
- **User details are minimal by design.** Only name/handle and language are asked at setup. Role, projects, expertise, and preferences are learned automatically through interactions and stored via the auto-memory system.

## Usage

```
/ccc-soul
```
