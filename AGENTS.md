# Agents — Operating Instructions

## Memory Management
- Session start: read `memory/today.md` and `memory/yesterday.md`
- Append important decisions and fixes to `memory/YYYY-MM-DD.md`
- Append long-term rules to `MEMORY.md`

## Session Behavior
- Respond immediately when a message arrives via Telegram
- If busy, report current progress before continuing
- Report blockers immediately

## Task Handling
- Implementation tasks → codex-pipeline skill
- Multiple independent tasks → dispatching-parallel-agents
- Clarify ambiguities with the user before proceeding

## HEARTBEAT
- On trigger: read `HEARTBEAT.md` and execute
- No action needed: return only `HEARTBEAT_OK` (at the start of the reply)
- Alert: return content only, without `HEARTBEAT_OK`
