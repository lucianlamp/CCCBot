#!/bin/bash
# CCC Workspace Launcher
# Start Claude Code Channels session

CCCBOT_DIR="$HOME/.cccbot"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# First run: install if ~/.cccbot doesn't exist
if [ ! -d "$CCCBOT_DIR" ]; then
    echo "~/.cccbot not found. Running installer..."
    bash "$SCRIPT_DIR/scripts/install.sh"
    if [ $? -ne 0 ]; then
        echo "Install failed. Exiting."
        exit 1
    fi
fi
cd "$CCCBOT_DIR"

echo "Starting Claude Code Channels session..."
echo "Workspace: $(pwd)"
echo ""

echo "Trying --continue..."
claude --continue --channels plugin:telegram@claude-plugins-official --remote-control
if [ $? -ne 0 ]; then
    echo "No previous session found, starting fresh..."
    claude --channels plugin:telegram@claude-plugins-official --remote-control
fi
