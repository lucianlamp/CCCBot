#!/bin/bash
# CCCBot Workspace Launcher
# Start Claude Code Channels session

CCCBOT_DIR="$HOME/.cccbot"
PID_FILE="$CCCBOT_DIR/.ccc-pid"

# Load shared libs
source "$CCCBOT_DIR/scripts/lib/json-parse.sh" 2>/dev/null
source "$CCCBOT_DIR/scripts/lib/resolve-workspace.sh" 2>/dev/null
source "$CCCBOT_DIR/scripts/lib/add-directory.sh" 2>/dev/null

# Validate JSON file (returns 0 if valid or no validator available)
validate_json() {
    local file="$1"
    if command -v python3 &>/dev/null; then
        python3 -m json.tool "$file" >/dev/null 2>&1
    elif command -v node &>/dev/null; then
        node -e "JSON.parse(require('fs').readFileSync('$file','utf8'))" 2>/dev/null
    else
        return 0
    fi
}

# Read user config from cccbot.json
CFG_CHANNELS="" CFG_WORKSPACE=""
if [ -f "$CCCBOT_DIR/cccbot.json" ]; then
    if validate_json "$CCCBOT_DIR/cccbot.json"; then
        CFG_CHANNELS=$(json_get channels "$CCCBOT_DIR/cccbot.json")
        CFG_WORKSPACE=$(json_get workspace "$CCCBOT_DIR/cccbot.json")
    else
        echo -e "\033[1;33mWarning: cccbot.json is invalid JSON. Using defaults.\033[0m"
    fi
fi

# Priority: env var > cccbot.json > default
CHANNELS="${CHANNELS:-${CFG_CHANNELS:-plugin:telegram@claude-plugins-official}}"
WORKSPACE_RAW="${WORKSPACE:-${CFG_WORKSPACE:-workspace}}"

# Check workspace exists
if [ ! -d "$CCCBOT_DIR" ]; then
    echo "Error: CCCBot workspace not found at $CCCBOT_DIR"
    echo "Run the installer first:"
    echo "  bash <(curl -fsSL https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.sh)"
    exit 1
fi
cd "$CCCBOT_DIR"

# Resolve workspace path
WORKSPACE_ABS=$(resolve_workspace "$WORKSPACE_RAW" "$CCCBOT_DIR")
mkdir -p "$WORKSPACE_ABS"

# Add to additionalDirectories if workspace is outside CCCBOT_DIR
case "$WORKSPACE_ABS" in
    "$CCCBOT_DIR"/*) ;;
    *)
        add_additional_directory "$WORKSPACE_ABS" "$CCCBOT_DIR"
        ;;
esac

# Ensure settings.json exists (may be missing after update)
if [ ! -f ".claude/settings.json" ]; then
    mkdir -p .claude
    cp scripts/templates/settings.json.default .claude/settings.json
    echo "Created default .claude/settings.json"
fi

# Save this shell's PID to file
echo $$ > "$PID_FILE"
trap 'rm -f "$PID_FILE"' EXIT

echo "Starting Claude Code Channels session..."
echo "Workspace: $(pwd)"
echo "Work dir:  $WORKSPACE_ABS"
echo "Channels:  $CHANNELS"
echo ""

# NOTE: $CHANNELS is intentionally unquoted to allow word splitting for multi-channel support.

# Start session (--continue unless CCC_FRESH is set)
if [ -n "$CCC_FRESH" ]; then
    echo "Starting fresh session..."
    unset CCC_FRESH
    claude "/ccc-boot" --channels $CHANNELS --remote-control
else
    claude "/ccc-boot" --continue --channels $CHANNELS --remote-control
    if [ $? -ne 0 ]; then
        echo "Previous session not found. Starting fresh..."
        claude "/ccc-boot" --channels $CHANNELS --remote-control
    fi
fi
