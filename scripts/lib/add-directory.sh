#!/bin/bash
# add_additional_directory — safely add a path to settings.local.json additionalDirectories
# Usage: add_additional_directory <dir_path> <cccbot_dir>
# Idempotent: skips if already present. Requires python3 or node.
add_additional_directory() {
    local dir="$1"
    local cccbot_dir="$2"
    local settings="$cccbot_dir/.claude/settings.local.json"

    mkdir -p "$cccbot_dir/.claude"

    if command -v python3 &>/dev/null; then
        python3 -c "
import json, os
f = '$settings'
d = '$dir'
cfg = {}
if os.path.exists(f):
    with open(f) as fh:
        cfg = json.load(fh)
perms = cfg.setdefault('permissions', {})
dirs = perms.setdefault('additionalDirectories', [])
if d not in dirs:
    dirs.append(d)
    with open(f, 'w') as fh:
        json.dump(cfg, fh, indent=2)
"
    elif command -v node &>/dev/null; then
        node -e "
const fs=require('fs'), f='$settings', d='$dir';
let cfg={}; try{cfg=JSON.parse(fs.readFileSync(f,'utf8'))}catch{}
const p=cfg.permissions=cfg.permissions||{};
const a=p.additionalDirectories=p.additionalDirectories||[];
if(!a.includes(d)){a.push(d);fs.writeFileSync(f,JSON.stringify(cfg,null,2))}
"
    else
        echo -e "\033[1;33mWarning: Cannot add workspace to additionalDirectories (python3/node not found).\033[0m"
        echo "  Add manually to .claude/settings.local.json:"
        echo "  \"additionalDirectories\": [\"$dir\"]"
    fi
}
