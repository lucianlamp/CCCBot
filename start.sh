#!/bin/bash
# CCC Workspace Launcher
# Start Claude Code Channels session

cd "$(dirname "$0")"

echo "Starting Claude Code Channels session..."
echo "Workspace: $(pwd)"
echo ""

echo "Trying --continue..."
claude --continue --channels plugin:telegram@claude-plugins-official --remote-control
if [ $? -ne 0 ]; then
    echo "No previous session found, starting fresh..."
    claude --channels plugin:telegram@claude-plugins-official --remote-control
fi
