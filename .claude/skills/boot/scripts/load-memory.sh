#!/bin/bash
# Boot memory loader script
# Lists available memory files for today and yesterday

WORKSPACE_DIR="$(cd "$(dirname "$0")/../../../.." && pwd)"
MEMORY_DIR="$WORKSPACE_DIR/memory"
TODAY=$(date '+%Y-%m-%d')
YESTERDAY=$(date -d 'yesterday' '+%Y-%m-%d' 2>/dev/null || date -v-1d '+%Y-%m-%d' 2>/dev/null)

echo "=== BOOT: $(date '+%Y-%m-%d %H:%M') ==="
echo ""

echo "--- Memory Files ---"
if [ -f "$MEMORY_DIR/$TODAY.md" ]; then
  echo "[TODAY] $MEMORY_DIR/$TODAY.md"
  cat "$MEMORY_DIR/$TODAY.md"
else
  echo "[TODAY] none"
fi
echo ""
if [ -f "$MEMORY_DIR/$YESTERDAY.md" ]; then
  echo "[YESTERDAY] $MEMORY_DIR/$YESTERDAY.md"
  cat "$MEMORY_DIR/$YESTERDAY.md"
else
  echo "[YESTERDAY] none"
fi
echo ""

echo "--- Long-term Memory ---"
if [ -f "$WORKSPACE_DIR/MEMORY.md" ]; then
  cat "$WORKSPACE_DIR/MEMORY.md"
else
  echo "(none)"
fi
echo ""

echo "=== END BOOT ==="
