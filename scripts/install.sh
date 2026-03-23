#!/bin/bash
# CCCBot — Claude Code Channels Bot Installer

REPO_URL="https://github.com/lucianlamp/CCCBot"
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

# Run shared setup (template copy, gitignore, etc.)
echo ""
bash "$INSTALL_DIR/scripts/setup.sh"

# Done
echo ""
echo -e "${GREEN}CCC installed to: $INSTALL_DIR${NC}"
echo ""
echo "Docs: $REPO_URL"
echo ""

# Launch
exec bash "$INSTALL_DIR/start.sh"
