#!/bin/bash
# CCCBot Workspace Launcher
# Start Claude Code Channels session

CCCBOT_DIR="$HOME/.cccbot"

# Channels to enable — space-separated list of plugins.
# Add or remove channels here:
#   Telegram: plugin:telegram@claude-plugins-official
#   Discord:  plugin:discord@claude-plugins-official
# Example (both): CHANNELS="plugin:telegram@claude-plugins-official plugin:discord@claude-plugins-official"
CHANNELS="${CHANNELS:-plugin:telegram@claude-plugins-official}"

# Check workspace exists
if [ ! -d "$CCCBOT_DIR" ]; then
    echo "Error: CCCBot workspace not found at $CCCBOT_DIR"
    echo "Run the installer first:"
    echo "  bash <(curl -fsSL https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.sh)"
    exit 1
fi
cd "$CCCBOT_DIR"

# Ensure settings.json exists (may be missing after update)
if [ ! -f ".claude/settings.json" ]; then
    mkdir -p .claude
    cp scripts/templates/settings.json.default .claude/settings.json
    echo "Created default .claude/settings.json"
fi

# Write this shell's PID to file (for restart-session.sh to kill)
PID_FILE="$CCCBOT_DIR/.claude/ccc-session.pid"

# Prevent double-launch: check if another session is already running
if [ -f "$PID_FILE" ]; then
    EXISTING_PID=$(cat "$PID_FILE")
    if ps -p "$EXISTING_PID" > /dev/null 2>&1; then
        echo "Error: CCC session already running (PID: $EXISTING_PID)"
        echo "Use scripts/restart-session.sh to restart."
        exit 1
    fi
    echo "Warning: Stale PID file found (PID $EXISTING_PID not running). Cleaning up."
    rm -f "$PID_FILE"
fi

echo $$ > "$PID_FILE"
# Clean up PID file on any exit (including signals)
trap 'rm -f "$PID_FILE"' EXIT

echo "Starting Claude Code Channels session..."
echo "Workspace: $(pwd)"
echo "Channels:  $CHANNELS"
echo "PID file:  $PID_FILE"
echo ""

# NOTE: $CHANNELS is intentionally unquoted to allow word splitting for multi-channel support.
# Each space-separated plugin URI becomes a separate argument to --channels.

# Try to resume previous session first; fall back to fresh start
claude --continue --channels $CHANNELS --remote-controlif [ $? -ne 0 ]; then
    echo "Previous session not found. Starting fresh..."
    claude --channels $CHANNELS --remote-controlfi

# PID file cleanup is handled by the EXIT trap above
