---
name: channel-task
description: Standard flow for receiving tasks from channels (Telegram/Discord etc). Immediate acknowledgment → background execution → progress reporting → completion notification. Always follow this skill when receiving channel messages.
---

# Channel Task Skill

Standard processing flow for tasks received from channels like Telegram or Discord.

## Overview

```
[Channel message received]
        │
        ▼
┌──────────────────────┐
│ 1. Immediate ack     │  ← Required, highest priority. Do this before anything else.
│  "Got it, I'll do X" │
└──────────────────────┘
        │
        ▼
┌─────────────────────────────────────────┐
│ Task classification                      │
│                                         │
│  Short (1-2 tools) ──→ Sync execution   │
│  Long / multi-step  → Background        │
└─────────────────────────────────────────┘
        │
        ├─ [Sync]  Execute → completion notification
        │
        └─ [BG]   Launch Agent subagent (run_in_background=true)
                    │
                    ├─ Intermediate progress report if applicable
                    └─ Completion notification
```

## Step 1: Immediate acknowledgment (required)

After receiving a channel message, **reply to the channel first**.

**Channel detection:**
```
<channel source="plugin:telegram:telegram"> → mcp__plugin_telegram_telegram__reply
<channel source="plugin:discord:*">         → corresponding Discord reply tool
```

**Reply format:** "Got it, I'll [action]." (one sentence, concise)
**reply_to:** `message_id` from the received message

## Step 2: Task execution

**Short tasks (1-2 tools)**
- Synchronous execution is fine
- Report results to channel after completion

**Long tasks (research, implementation, multiple operations)**
- Launch subagent via `Agent` tool with `run_in_background=true`
- Main session returns to message listening immediately

### Handoff info for background subagent

```
Task: [specific task content]
Channel: [telegram / discord]
chat_id: [chat_id from received message]
reply_to: [original message_id]

Instructions:
- Report via the channel's reply tool when work is complete
- Send intermediate progress updates for long tasks
- Report errors immediately
```

## Step 3: Completion notification

Send results to channel after work is done.
- Briefly describe what was done and the outcome
- Include error details and remediation if applicable
