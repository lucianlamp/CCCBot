#!/bin/bash
cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "Session started. Your FIRST action must be to invoke the Skill tool with skill=\"ccc-boot\" to run the boot sequence. Do this before responding to any message."}}
EOF
