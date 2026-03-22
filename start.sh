#!/bin/bash
# CCC Workspace Launcher
# Start Claude Code Channels session

# Use ~/.cccbot/ as workspace directory (create if missing)
CCCBOT_DIR="$HOME/.cccbot"
if [ ! -d "$CCCBOT_DIR" ]; then
    echo "Creating workspace directory: $CCCBOT_DIR"
    mkdir -p "$CCCBOT_DIR"
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
