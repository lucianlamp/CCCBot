#!/bin/bash
# SessionStart hook — checks workspace state and outputs boot instruction.
# NOTE: Requires bash. On Windows, Claude Code's "shell": "bash" resolves to Git Bash.
#
# stdin: {"source":"startup|resume", "session_id":"...", "transcript_path":"...", "cwd":"...", ...}

INPUT=$(cat)

# Parse JSON without jq (grep + sed)
parse_json() { echo "$INPUT" | grep -o "\"$1\":\"[^\"]*\"" | sed "s/\"$1\":\"//;s/\"$//" ; }

SOURCE=$(parse_json source)
SOURCE=${SOURCE:-startup}
SESSION_ID=$(parse_json session_id)
TRANSCRIPT=$(parse_json transcript_path)

# Pre-check SOUL.md so boot can skip the bash step
if [ -f SOUL.md ]; then
  SOUL_STATUS="exists"
else
  SOUL_STATUS="missing"
fi

# Read previous session transcript path (if saved)
LAST_SESSION_FILE=".claude/last-session.json"
PREV_TRANSCRIPT=""
if [ -f "$LAST_SESSION_FILE" ]; then
  PREV_TRANSCRIPT=$(grep -o '"transcript_path":"[^"]*"' "$LAST_SESSION_FILE" | sed 's/"transcript_path":"//;s/"$//')
fi

# Save current session info for next time
if [ -n "$SESSION_ID" ]; then
  echo "{\"session_id\":\"${SESSION_ID}\",\"transcript_path\":\"${TRANSCRIPT}\",\"started_at\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%SZ)\"}" > "$LAST_SESSION_FILE"
fi

# Build context
CONTEXT="Session started (${SOURCE}). SOUL.md status: ${SOUL_STATUS}."
if [ -n "$PREV_TRANSCRIPT" ] && [ "$SOURCE" = "startup" ]; then
  CONTEXT="${CONTEXT} Previous session transcript: ${PREV_TRANSCRIPT}"
fi
CONTEXT="${CONTEXT} Your FIRST action must be to invoke the Skill tool with skill=\\\"ccc-boot\\\" to run the boot sequence. Do this before responding to any message."

cat <<HOOK
{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "${CONTEXT}"}}
HOOK
