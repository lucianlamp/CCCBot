#!/bin/bash
# CCC Session Restart
# Launched as detached process (nohup) to safely kill old session.

CCCBOT_DIR="$HOME/.cccbot"
PID_FILE="$CCCBOT_DIR/.ccc-pid"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] CCC restart triggered"

# Wait for Claude to finish its reply
sleep 3

# Kill old session via PID file
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE" | tr -d '[:space:]')
    if [ -n "$OLD_PID" ] && ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "Killing previous session (PID: $OLD_PID)..."
        pkill -P "$OLD_PID" 2>/dev/null
        kill "$OLD_PID" 2>/dev/null
    else
        echo "No active session found"
    fi
    rm -f "$PID_FILE"
    sleep 5
fi

# Start new session (skip --continue, force fresh start)
export CCC_FRESH=1
exec "$CCCBOT_DIR/start.sh"
