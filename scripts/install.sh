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
    for f in CLAUDE.md SOUL.md BOOT.md HEARTBEAT.md JOBS.yaml .mcp.json .gitignore cccbot.json; do
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
    for f in CLAUDE.md SOUL.md BOOT.md HEARTBEAT.md JOBS.yaml .mcp.json .gitignore cccbot.json; do
        [ -f "$BACKUP_DIR/$f" ] && cp "$BACKUP_DIR/$f" "$INSTALL_DIR/"
    done
    # Migrate: if old start.sh had custom CHANNELS and no cccbot.json exists, create one
    if [ -f "$BACKUP_DIR/start.sh" ] && [ ! -f "$INSTALL_DIR/cccbot.json" ]; then
        OLD_CHANNELS=$(grep -o 'CHANNELS=.*plugin:[^"]*' "$BACKUP_DIR/start.sh" | sed 's/CHANNELS="${CHANNELS:-//;s/}$//' | head -1)
        if [ -n "$OLD_CHANNELS" ] && [ "$OLD_CHANNELS" != "plugin:telegram@claude-plugins-official" ]; then
            echo "{" > "$INSTALL_DIR/cccbot.json"
            echo "  \"workspace\": \"workspace\"," >> "$INSTALL_DIR/cccbot.json"
            echo "  \"channels\": \"$OLD_CHANNELS\"" >> "$INSTALL_DIR/cccbot.json"
            echo "}" >> "$INSTALL_DIR/cccbot.json"
            echo -e "  ${GREEN}Migrated:${NC} channels from start.sh → cccbot.json"
        fi
    fi
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

# --- Channel selection (skip on update if cccbot.json exists) ---
if [ "$IS_UPDATE" = true ] && [ -f "cccbot.json" ]; then
    echo "  Keeping existing channel config"
else
    echo ""
    echo "=== Channel Setup ==="
    echo ""
    echo "Which messaging channel will CCCBot use?"
    echo ""
    echo -e "  ${GREEN}1) Telegram${NC} (default)"
    echo -e "  ${YELLOW}2) Discord${NC}"
    echo -e "  3) Both"
    echo ""

    while true; do
        read -rp "Select channel [1/2/3] (default: 1): " CHAN_CHOICE
        CHAN_CHOICE="${CHAN_CHOICE:-1}"
        case "$CHAN_CHOICE" in
            1|telegram)
                CCC_CHANNELS="plugin:telegram@claude-plugins-official"
                echo -e "  → ${GREEN}Telegram${NC} selected"
                break
                ;;
            2|discord)
                CCC_CHANNELS="plugin:discord@claude-plugins-official"
                echo -e "  → ${YELLOW}Discord${NC} selected"
                break
                ;;
            3|both)
                CCC_CHANNELS="plugin:telegram@claude-plugins-official plugin:discord@claude-plugins-official"
                echo -e "  → ${GREEN}Telegram${NC} + ${YELLOW}Discord${NC} selected"
                break
                ;;
            *)
                echo -e "  ${RED}Invalid choice. Enter 1, 2, or 3.${NC}"
                ;;
        esac
    done
fi

# --- cccbot.json (with selected channel) ---
if [ ! -f "cccbot.json" ]; then
    cat > "cccbot.json" <<CCCJSON
{
  "workspace": "workspace",
  "channels": "$CCC_CHANNELS"
}
CCCJSON
    echo -e "  ${GREEN}Created:${NC} cccbot.json (channels: $CCC_CHANNELS)"
else
    echo "  Skipped (exists): cccbot.json"
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

# Create default workspace and lib directories
mkdir -p workspace
mkdir -p scripts/lib

# --- Git setup (after all files are in place) ---
if ! git rev-parse --git-dir &>/dev/null; then
    git init
    # Set fallback git identity if not configured (needed for initial commit)
    if ! git config user.name &>/dev/null; then
        git config user.name "CCCBot"
        git config user.email "cccbot@localhost"
    fi
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

# --- CLI command setup ---
mkdir -p "$INSTALL_DIR/bin"
chmod +x "$INSTALL_DIR/bin/cccbot"

# Add to PATH in shell profiles (idempotent)
PATH_LINE='export PATH="$HOME/.cccbot/bin:$PATH"'
PATH_ADDED=false
for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.profile"; do
    [ ! -f "$rc" ] && continue
    grep -qF '.cccbot/bin' "$rc" && continue
    echo "" >> "$rc"
    echo "# CCCBot" >> "$rc"
    echo "$PATH_LINE" >> "$rc"
    PATH_ADDED=true
done
if [ "$PATH_ADDED" = true ]; then
    echo -e "  ${GREEN}Added cccbot to PATH${NC}"
fi

# Done
echo ""
echo -e "${GREEN}CCCBot ${VERSION} installed to: $INSTALL_DIR${NC}"
echo ""
echo "  Restart your terminal, then run: cccbot"
echo "  Update later with: cccbot update"
echo ""

# Launch
exec bash "$INSTALL_DIR/start.sh"
