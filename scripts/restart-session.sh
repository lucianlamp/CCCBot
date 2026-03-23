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
    echo "Killing old session (PID: $OLD_PID) and its process tree..."
    # Kill the process group (shell + all children including claude)
    kill -- -"$OLD_PID" 2>/dev/null || kill "$OLD_PID" 2>/dev/null
    # Wait for process to fully terminate
    sleep 2
fi

echo "Starting new session..."
exec "$START_SH"
