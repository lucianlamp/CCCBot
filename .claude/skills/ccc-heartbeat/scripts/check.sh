#!/bin/bash
# Heartbeat context check script
# Outputs current state for Claude to evaluate

WORKSPACE_DIR="$(cd "$(dirname "$0")/../../../.." && pwd)"
echo "=== HEARTBEAT CHECK: $(date '+%Y-%m-%d %H:%M') ==="
echo ""

# 1. List today's memory file if it exists
TODAY=$(date '+%Y-%m-%d')
YESTERDAY=$(date -d 'yesterday' '+%Y-%m-%d' 2>/dev/null || date -v-1d '+%Y-%m-%d' 2>/dev/null)
MEMORY_DIR="$WORKSPACE_DIR/memory"

echo "--- Memory ---"
[ -f "$MEMORY_DIR/$TODAY.md" ] && echo "Today: $MEMORY_DIR/$TODAY.md" || echo "Today: (none)"
[ -f "$MEMORY_DIR/$YESTERDAY.md" ] && echo "Yesterday: $MEMORY_DIR/$YESTERDAY.md" || echo "Yesterday: (none)"
echo ""

echo "=== END CHECK ==="
