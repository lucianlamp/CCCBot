#!/bin/bash
# CCCBot — First-run setup
# Copies template files to project root if they don't exist.
# Called by install.sh and boot skill.

set -euo pipefail

# Resolve paths relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd "$PROJECT_DIR"

# --- Git setup ---
if ! git rev-parse --git-dir &>/dev/null; then
    echo "Initializing git repository..."
    git init
fi

if [ ! -f ".gitignore" ]; then
    cp "$TEMPLATES_DIR/.gitignore.default" ".gitignore"
    echo -e "  ${GREEN}Created:${NC} .gitignore"
fi

# --- Template files ---
# Structural files only. SOUL.md and USER.md are created by /ccc-setup interactively.
# Format: "template_name:target_path"
FILES=(
    "CLAUDE.example.md:CLAUDE.md"
    "CRONS.example.md:CRONS.md"
    "BOOT.example.md:BOOT.md"
    "HEARTBEAT.example.md:HEARTBEAT.md"
)

CREATED=()

for entry in "${FILES[@]}"; do
    src="${entry%%:*}"
    dst="${entry##*:}"
    if [ ! -f "$dst" ]; then
        cp "$TEMPLATES_DIR/$src" "$dst"
        CREATED+=("$dst")
        echo -e "  ${GREEN}Created:${NC} $dst"
    else
        echo "  Skipped (exists): $dst"
    fi
done

# --- Summary ---
echo ""
if [ ${#CREATED[@]} -eq 0 ]; then
    echo "All config files already exist. Nothing to do."
else
    echo -e "${GREEN}Setup complete.${NC} Created ${#CREATED[@]} file(s)."
fi
