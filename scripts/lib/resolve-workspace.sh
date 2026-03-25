#!/bin/bash
# resolve_workspace — expand workspace path to absolute
# Usage: resolve_workspace <raw_path> <base_dir>
# Outputs absolute path to stdout.
# Rules:
#   /absolute/path  → as-is
#   ~/relative       → $HOME/relative
#   relative         → base_dir/relative
resolve_workspace() {
    local raw="$1" base="$2"
    if [ "$raw" = "~" ]; then
        echo "$HOME"
    elif echo "$raw" | grep -q '^~/'; then
        echo "${HOME}/${raw#\~/}"
    elif echo "$raw" | grep -q '^/'; then
        echo "$raw"
    else
        echo "$base/$raw"
    fi
}
