#!/bin/bash
# CCCBot Workspace Launcher
# Start Claude Code Channels session

CCCBOT_DIR="$HOME/.cccbot"
PID_FILE="$CCCBOT_DIR/.ccc-pid"

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

# Save this shell's PID to file
echo $$ > "$PID_FILE"
trap 'rm -f "$PID_FILE"' EXIT

echo "Starting Claude Code Channels session..."
echo "Workspace: $(pwd)"
echo "Channels:  $CHANNELS"
echo ""

# NOTE: $CHANNELS is intentionally unquoted to allow word splitting for multi-channel support.

# Start session (--continue unless CCC_FRESH is set)
if [ -n "$CCC_FRESH" ]; then
    echo "Starting fresh session..."
    unset CCC_FRESH
    claude "/ccc-boot" --channels $CHANNELS --remote-control
else
    claude "/ccc-boot" --continue --channels $CHANNELS --remote-control
    if [ $? -ne 0 ]; then
        echo "Previous session not found. Starting fresh..."
        claude "/ccc-boot" --channels $CHANNELS --remote-control
    fi
fi
