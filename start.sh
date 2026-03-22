#!/bin/bash
# CCC Workspace Launcher
# Start Claude Code Channels session

cd "$(dirname "$0")"

echo "Starting Claude Code Channels session..."
echo "Workspace: $(pwd)"
echo ""

claude --channels plugin:telegram@claude-plugins-official --remote-control
