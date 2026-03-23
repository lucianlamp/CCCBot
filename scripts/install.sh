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

# --- Permission mode selection ---
echo ""
echo "=== Permission Mode ==="
echo ""
echo "Claude Code needs permission settings to control tool execution."
echo ""
echo -e "  ${GREEN}1) bypass${NC} — All tools run without confirmation (full autonomy)"
echo -e "     Best for: experienced users, background bot operation"
echo ""
echo -e "  ${YELLOW}2) allowEdits${NC} — File edits auto-approved, Bash/dangerous tools require confirmation"
echo -e "     Best for: first-time users, security-conscious setups"
echo ""

while true; do
    read -rp "Select permission mode [1/2] (default: 1): " PERM_CHOICE
    PERM_CHOICE="${PERM_CHOICE:-1}"
    case "$PERM_CHOICE" in
        1|bypass)
            PERM_MODE="bypassPermissions"
            echo -e "  → ${GREEN}bypass${NC} mode selected"
            break
            ;;
        2|allowEdits)
            PERM_MODE="allowEdits"
            echo -e "  → ${YELLOW}allowEdits${NC} mode selected"
            break
            ;;
        *)
            echo -e "  ${RED}Invalid choice. Enter 1 or 2.${NC}"
            ;;
    esac
done

TEMPLATES_DIR="$INSTALL_DIR/scripts/templates"

# --- Git setup ---
if ! git rev-parse --git-dir &>/dev/null; then
    echo "Initializing git repository..."
    git init
fi

# --- .gitignore ---
if [ ! -f ".gitignore" ]; then
    cp "$TEMPLATES_DIR/.gitignore.default" ".gitignore"
    echo -e "  ${GREEN}Created:${NC} .gitignore"
else
    echo "  Skipped (exists): .gitignore"
fi

# --- settings.json (with selected permission mode) ---
mkdir -p .claude
if [ ! -f ".claude/settings.json" ]; then
    cp "$TEMPLATES_DIR/settings.json.default" ".claude/settings.json"
    sed -i "s/\"defaultMode\": \"bypassPermissions\"/\"defaultMode\": \"$PERM_MODE\"/" ".claude/settings.json"
    echo -e "  ${GREEN}Created:${NC} .claude/settings.json (mode: $PERM_MODE)"
else
    echo "  Skipped (exists): .claude/settings.json"
fi

# --- Template files ---
copy_if_missing() {
    local src="$1" dst="$2"
    if [ ! -f "$dst" ]; then
        cp "$src" "$dst"
        echo -e "  ${GREEN}Created:${NC} $dst"
    else
        echo "  Skipped (exists): $dst"
    fi
}

copy_if_missing "$TEMPLATES_DIR/CLAUDE.example.md"    "CLAUDE.md"
copy_if_missing "$TEMPLATES_DIR/JOBS.example.yaml"    "JOBS.yaml"
copy_if_missing "$TEMPLATES_DIR/BOOT.example.md"      "BOOT.md"
copy_if_missing "$TEMPLATES_DIR/HEARTBEAT.example.md" "HEARTBEAT.md"

# Done
echo ""
echo -e "${GREEN}CCC installed to: $INSTALL_DIR${NC}"
echo ""
echo "Docs: $REPO_URL"
echo ""

# Launch
exec bash "$INSTALL_DIR/start.sh"
