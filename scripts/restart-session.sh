#!/bin/bash
# CCC Session Restart
# Launched as detached process (nohup) to safely kill old session.

CCCBOT_DIR="$HOME/.cccbot"
PID_FILE="$CCCBOT_DIR/.ccc-pid"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] CCC restart triggered"

# Detect WSL
IS_WSL=false
if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
    echo "WSL environment detected"
fi

# Wait for Claude to finish its reply
sleep 3

# Kill old session via PID file
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE" | tr -d '[:space:]')
    if [ -n "$OLD_PID" ] && ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "Killing previous session (PID: $OLD_PID)..."
        # Kill children first, then parent
        pkill -P "$OLD_PID" 2>/dev/null
        kill "$OLD_PID" 2>/dev/null
        sleep 2
        # Force kill if still alive
        if ps -p "$OLD_PID" > /dev/null 2>&1; then
            echo "Force killing PID $OLD_PID..."
            kill -9 "$OLD_PID" 2>/dev/null
        fi
    else
        echo "No active session found"
    fi
    rm -f "$PID_FILE"
    sleep 3
fi

# Start new session (skip --continue, force fresh start)
if [ "$IS_WSL" = true ]; then
    # WSL: must open a new terminal window via Windows side
    if command -v wt.exe &>/dev/null; then
        echo "Starting new session via Windows Terminal..."
        wt.exe wsl.exe bash -l -c "CCC_FRESH=1 '$CCCBOT_DIR/start.sh'"
    else
        echo "Starting new session via cmd.exe..."
        cmd.exe /c start "" wsl.exe bash -l -c "CCC_FRESH=1 '$CCCBOT_DIR/start.sh'"
    fi
else
    export CCC_FRESH=1
    exec "$CCCBOT_DIR/start.sh"
fi
