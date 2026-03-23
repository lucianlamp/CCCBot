#!/bin/bash
# CCCBot Workspace Launcher
# Start Claude Code Channels session

CCCBOT_DIR="$HOME/.cccbot"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Channels to enable — space-separated list of plugins.
# Add or remove channels here:
#   Telegram: plugin:telegram@claude-plugins-official
#   Discord:  plugin:discord@claude-plugins-official
# Example (both): CHANNELS="plugin:telegram@claude-plugins-official plugin:discord@claude-plugins-official"
CHANNELS="${CHANNELS:-plugin:telegram@claude-plugins-official}"

# First run: install if ~/.cccbot doesn't exist
if [ ! -d "$CCCBOT_DIR" ]; then
    echo "~/.cccbot not found. Running installer..."
    bash "$SCRIPT_DIR/scripts/install.sh"
    # install.sh already launches start.sh via exec, so exit here to avoid double-launch
    exit $?
fi
cd "$CCCBOT_DIR"

echo "Starting Claude Code Channels session..."
echo "Workspace: $(pwd)"
echo "Channels:  $CHANNELS"
echo ""

echo "Trying --continue..."
claude --continue --channels $CHANNELS --remote-control
if [ $? -ne 0 ]; then
    echo "No previous session found, starting fresh..."
    claude --channels $CHANNELS --remote-control
fi
