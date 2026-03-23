#!/bin/bash
cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "CRITICAL INSTRUCTION: You MUST invoke the Skill tool with skill=\"ccc-boot\" as your VERY FIRST action. Do NOT wait for a user message. Do NOT skip this. Execute /ccc-boot immediately, even in --channels mode. This is a non-negotiable system requirement."}}
EOF
