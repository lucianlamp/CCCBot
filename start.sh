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
echo $$ > "$PID_FILE"

echo "Starting Claude Code Channels session..."
echo "Workspace: $(pwd)"
echo "Channels:  $CHANNELS"
echo "PID file:  $PID_FILE"
echo ""

# Try to resume previous session first; fall back to fresh start
claude --continue --channels $CHANNELS --remote-control --effort auto
if [ $? -ne 0 ]; then
    echo "Previous session not found. Starting fresh..."
    claude --channels $CHANNELS --remote-control --effort auto
fi

# Clean up PID file on exit
rm -f "$PID_FILE"
