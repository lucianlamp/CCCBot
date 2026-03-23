#!/bin/bash
# CCCBot — Claude Code Channels Bot Installer

REPO="lucianlamp/CCCBot"
VERSION="${1:-}"
INSTALL_DIR="$HOME/.cccbot"

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

# Resolve version
if [ -z "$VERSION" ]; then
    echo "Fetching latest release..."
    VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
    if [ -z "$VERSION" ]; then
        echo -e "${RED}Error: Could not determine latest release.${NC}"
        echo "Specify a version manually: install.sh v1.0.0"
        exit 1
    fi
    echo -e "  Latest release: ${GREEN}${VERSION}${NC}"
fi

# Validate version format
if ! echo "$VERSION" | grep -qE '^v[0-9]'; then
    echo -e "${RED}Error: Invalid version format: ${VERSION}${NC}"
    echo "Version must start with v followed by a number, e.g. v1.0.0"
    exit 1
fi

# Download and extract release archive
TMPDIR=$(mktemp -d)
ARCHIVE_URL="https://github.com/$REPO/archive/refs/tags/${VERSION}.tar.gz"

echo "Downloading CCCBot ${VERSION}..."
curl -fsSL "$ARCHIVE_URL" -o "$TMPDIR/cccbot.tar.gz"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Download failed. Check version tag: ${VERSION}${NC}"
    rm -rf "$TMPDIR"
    exit 1
fi

echo "Extracting..."
tar xzf "$TMPDIR/cccbot.tar.gz" -C "$TMPDIR"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Extraction failed.${NC}"
    rm -rf "$TMPDIR"
    exit 1
fi

# Find extracted directory
EXTRACTED_DIR=$(ls -d "$TMPDIR"/CCCBot-* 2>/dev/null | head -1)
# Fallback: some archive formats may use different naming
if [ -z "$EXTRACTED_DIR" ]; then
    EXTRACTED_DIR=$(find "$TMPDIR" -mindepth 1 -maxdepth 1 -type d | head -1)
fi
if [ -z "$EXTRACTED_DIR" ]; then
    echo -e "${RED}Error: Unexpected archive structure.${NC}"
    rm -rf "$TMPDIR"
    exit 1
fi

mkdir -p "$INSTALL_DIR"

# On update: preserve user config files by moving them aside temporarily
IS_UPDATE=false
if [ -f "$INSTALL_DIR/CLAUDE.md" ] || [ -f "$INSTALL_DIR/start.sh" ]; then
    IS_UPDATE=true
    echo -e "${YELLOW}Existing installation detected. Updating...${NC}"
    BACKUP_DIR=$(mktemp -d)
    for f in CLAUDE.md SOUL.md BOOT.md HEARTBEAT.md JOBS.yaml .mcp.json .gitignore; do
        [ -f "$INSTALL_DIR/$f" ] && cp "$INSTALL_DIR/$f" "$BACKUP_DIR/"
    done
    [ -f "$INSTALL_DIR/.claude/settings.json" ] && mkdir -p "$BACKUP_DIR/.claude" && cp "$INSTALL_DIR/.claude/settings.json" "$BACKUP_DIR/.claude/"
    [ -f "$INSTALL_DIR/.claude/settings.local.json" ] && mkdir -p "$BACKUP_DIR/.claude" && cp "$INSTALL_DIR/.claude/settings.local.json" "$BACKUP_DIR/.claude/"
    [ -d "$INSTALL_DIR/memory" ] && cp -r "$INSTALL_DIR/memory" "$BACKUP_DIR/"
fi

# Copy all files from archive (overwrites core files)
cp -r "$EXTRACTED_DIR"/* "$INSTALL_DIR/"
cp -r "$EXTRACTED_DIR"/.[!.]* "$INSTALL_DIR/" 2>/dev/null

# Restore preserved user config files
if [ "$IS_UPDATE" = true ]; then
    for f in CLAUDE.md SOUL.md BOOT.md HEARTBEAT.md JOBS.yaml .mcp.json .gitignore; do
        [ -f "$BACKUP_DIR/$f" ] && cp "$BACKUP_DIR/$f" "$INSTALL_DIR/"
    done
    [ -f "$BACKUP_DIR/.claude/settings.json" ] && cp "$BACKUP_DIR/.claude/settings.json" "$INSTALL_DIR/.claude/"
    [ -f "$BACKUP_DIR/.claude/settings.local.json" ] && cp "$BACKUP_DIR/.claude/settings.local.json" "$INSTALL_DIR/.claude/"
    [ -d "$BACKUP_DIR/memory" ] && cp -r "$BACKUP_DIR/memory" "$INSTALL_DIR/"
    rm -rf "$BACKUP_DIR"
fi

# Cleanup temp
rm -rf "$TMPDIR"

cd "$INSTALL_DIR"
TEMPLATES_DIR="$INSTALL_DIR/scripts/templates"

# Migrate from git-clone workspace
if git rev-parse --git-dir &>/dev/null; then
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || true)
    if echo "$REMOTE_URL" | grep -q "lucianlamp/CCCBot"; then
        echo -e "${YELLOW}Detected old git-clone workspace. Removing dev remote...${NC}"
        git remote remove origin
    fi
fi

# --- Permission mode selection (skip on update) ---
if [ "$IS_UPDATE" = true ] && [ -f ".claude/settings.json" ]; then
    echo "  Keeping existing settings"
else
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
    # Portable sed: macOS sed -i requires backup extension, so use temp file instead
    sed "s/\"defaultMode\": \"bypassPermissions\"/\"defaultMode\": \"$PERM_MODE\"/" ".claude/settings.json" > ".claude/settings.json.tmp" && mv ".claude/settings.json.tmp" ".claude/settings.json"
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

# --- Git setup (after all files are in place) ---
if ! git rev-parse --git-dir &>/dev/null; then
    git init
    # NOTE: git add -A is safe here — .gitignore is already in place, excluding secrets and user config
    git add -A
    git commit -m "CCCBot ${VERSION} installed" --quiet
    echo -e "  ${GREEN}Initial commit created${NC}"
else
    if [ "$IS_UPDATE" = true ]; then
        # NOTE: git add -A is safe here — .gitignore is in place and user config files are preserved
        git add -A
        git commit -m "CCCBot updated to ${VERSION}" --quiet 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}Update committed${NC}"
        else
            echo "  No changes to commit"
        fi
    fi
fi

# Done
echo ""
echo -e "${GREEN}CCCBot ${VERSION} installed to: $INSTALL_DIR${NC}"
echo ""

# Launch
exec bash "$INSTALL_DIR/start.sh"
