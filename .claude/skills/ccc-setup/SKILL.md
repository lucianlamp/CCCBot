---
name: ccc-setup
description: First-run interactive setup — generate config files and guide user through persona/identity configuration
---

# CCC Setup Skill

Interactive first-run setup. Creates config files and guides the user through workspace configuration via Telegram.

## When to Run

Called by `ccc-boot` when `SOUL.md` or `USER.md` is missing. Can also be run manually with `/ccc-setup`.

## Steps

### 1. Ensure structural files exist

Run the setup script to copy structural config files (CLAUDE.md, CRONS.md, BOOT.md, HEARTBEAT.md) if not already present:

```bash
bash scripts/setup.sh
```

(On Windows cmd: `scripts\setup.bat`)

### 2. Create SOUL.md and USER.md from templates

Use the Write tool to copy template contents as starting points:

- Read `scripts/templates/SOUL.example.md` → Write to `SOUL.md`
- Read `scripts/templates/USER.example.md` → Write to `USER.md`

Only create if the files don't already exist.

### 3. Greet via Telegram

Send the first message via Telegram (reply MCP tool). This is the user's first contact with the bot.

```
Welcome to CCCBot!
Let me set up your workspace. I'll ask a few quick questions.
```

### 4. Interactive configuration (via Telegram)

Ask one question at a time via Telegram. Wait for each answer before asking the next. Write answers to the corresponding files immediately.

**Q1: Language**
Ask: "What language should I use? (e.g., English, 日本語)"
→ Write to `SOUL.md` Language section AND `USER.md` Language field.
→ Switch to the chosen language for all subsequent messages.

**Q2: Your name**
Ask: "What should I call you? (name or handle)"
→ Write to `USER.md` Handle field.

**Q3: Bot name**
Ask: "What should my name be? (default: CCC)"
→ Write to `SOUL.md` Identity > Name field.

**Q4: Bot personality**
Ask: "How should I behave? Pick a style or describe your own:"
Offer examples: "1. Concise & technical  2. Friendly & casual  3. Formal & thorough  4. Custom"
→ Write to `SOUL.md` Persona and Tone sections.

**Q5: Scheduled tasks (optional)**
Ask: "Want to set up any recurring tasks? (e.g., daily reports, periodic checks) If not, just say 'skip'."
→ If yes, write to `CRONS.md`. If skip, move on.

### 5. Done

Send via Telegram:
```
Setup complete! Starting session now.
```

Return control to the boot skill to continue the boot sequence (heartbeat, crons).

## Design Notes

- **USER.md is minimal by design.** Only name/handle and language are asked. User's role, projects, expertise, and preferences are learned automatically through interactions and stored via the auto-memory system — not through an interrogation at setup time.
- **SOUL.md defines the bot**, not the user. Keep the setup focused on how the bot should behave.

## Usage

```
/ccc-setup
```
