#!/bin/bash
# CCCBot — Claude Code Channels Bot Installer

REPO_URL="https://github.com/YOUR_USERNAME/ccc"
INSTALL_DIR="${1:-$HOME/.cccbot}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "CCCBot — Claude Code Channels Bot Installer"
echo "============================================"
echo ""

# Check dependencies
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git not found. Please install git first.${NC}"
    exit 1
fi

if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: claude CLI not found.${NC}"
    echo "Install it from: https://claude.ai/code"
    exit 1
fi

# Clone repo
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Directory already exists: $INSTALL_DIR${NC}"
    echo "Skipping clone. Updating templates only."
else
    echo "Cloning to $INSTALL_DIR..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Clone failed.${NC}"
        exit 1
    fi
fi

cd "$INSTALL_DIR"

# Copy template files (skip if already exists)
echo ""
echo "Setting up personal config files..."
TEMPLATES_DIR=".claude/skills/setup/templates"
CREATED=()

copy_if_missing() {
    local src="$1"
    local dst="$2"
    if [ ! -f "$dst" ]; then
        cp "$src" "$dst"
        CREATED+=("$dst")
        echo -e "  ${GREEN}Created:${NC} $dst"
    else
        echo "  Skipped (exists): $dst"
    fi
}

copy_if_missing "$TEMPLATES_DIR/.mcp.json.example"     ".mcp.json"
copy_if_missing "$TEMPLATES_DIR/SOUL.example.md"       "SOUL.md"
copy_if_missing "$TEMPLATES_DIR/IDENTITY.example.md"   "IDENTITY.md"
copy_if_missing "$TEMPLATES_DIR/USER.example.md"       "USER.md"
copy_if_missing "$TEMPLATES_DIR/CRONS.example.md"      "CRONS.md"
copy_if_missing "$TEMPLATES_DIR/BOOT.example.md"       "BOOT.md"
copy_if_missing "$TEMPLATES_DIR/HEARTBEAT.example.md"  "HEARTBEAT.md"
copy_if_missing "$TEMPLATES_DIR/TOOLS.example.md"      "TOOLS.md"

# Done
echo ""
echo -e "${GREEN}CCC installed to: $INSTALL_DIR${NC}"
echo ""
echo "Next steps:"
echo "  1. Edit .mcp.json       — add your Telegram bot token"
echo "  2. Edit USER.md         — describe yourself and your projects"
echo "  3. Edit SOUL.md         — customize the assistant persona (optional)"
echo "  4. Edit CRONS.md        — set up scheduled jobs (optional)"
echo "  5. Run: bash ~/.cccbot/start.sh   — start the assistant"
echo ""
echo "Docs: $REPO_URL"
