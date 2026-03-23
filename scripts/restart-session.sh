#!/bin/bash
# CCC Session Restart Script
# Called by heartbeat when MCP disconnection is detected.
# Runs as a detached process: kills the old session, then starts a new one.

CCCBOT_DIR="$HOME/.cccbot"
PID_FILE="$CCCBOT_DIR/.claude/ccc-session.pid"
START_SH="$(dirname "$0")/../start.sh"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] CCC restart triggered"

# Wait for the calling process to finish its cleanup
sleep 3

# Read PID and kill the old session process tree
if [ ! -f "$PID_FILE" ]; then
    echo "No PID file found. Skipping kill."
else
    OLD_PID=$(cat "$PID_FILE")
    # Validate process is actually a CCC session before killing
    OLD_CMD=$(ps -p "$OLD_PID" -o args= 2>/dev/null || true)
    if echo "$OLD_CMD" | grep -qE "(claude|ccc|start\.sh)"; then
        echo "Killing old session (PID: $OLD_PID) and its process tree..."
        # Kill child processes first, then the parent
        pkill -P "$OLD_PID" 2>/dev/null
        kill "$OLD_PID" 2>/dev/null
    else
        echo "PID $OLD_PID is not a CCC session (cmd: $OLD_CMD). Skipping kill."
        rm -f "$PID_FILE"
    fi
    # Wait for process to fully terminate
    sleep 2
fi

echo "Starting new session..."
exec "$START_SH"
