# Download-Based Installer Design

## Problem

The current installer uses `git clone` to copy the entire development repository into the user's workspace (`~/.cccbot`). This means:

- The user's workspace IS a clone of the dev repo (shared git history, remote pointing to dev repo)
- `git log` shows development commits, not the user's changes
- No clean separation between "CCCBot the tool" and "the user's workspace"

## Solution

Replace `git clone` with GitHub Releases archive download. After extraction, `git init` creates an independent repository for the user's workspace.

## Installation Flow

```
1. Check dependencies (git, claude CLI)
2. Resolve version (argument → specific tag, default → latest release via GitHub API)
3. Download source archive from GitHub Releases (tar.gz on Linux/macOS, zip on Windows)
4. Extract to temp directory, move contents to INSTALL_DIR
5. Interactive permission mode selection (bypass / allowEdits)
6. Place .gitignore from template
7. git init + initial commit (clean history, no remote)
8. Generate user config files from templates (only if missing)
9. Launch via start.sh / start.bat
```

## Version Resolution

- **Default**: Query GitHub API for latest release tag
  - Linux/macOS: `curl -s https://api.github.com/repos/lucianlamp/CCCBot/releases/latest | grep tag_name`
  - Windows: `(Invoke-WebRequest ...).Content | ConvertFrom-Json | Select tag_name`
- **Explicit**: `install.sh v1.0.0` or `install.bat v1.0.0` pins to a specific version
- URL pattern: `https://github.com/lucianlamp/CCCBot/archive/refs/tags/{tag}.tar.gz` (or `.zip`)

## Archive Handling

### Linux/macOS (install.sh)
```bash
curl -fsSL "https://github.com/lucianlamp/CCCBot/archive/refs/tags/${VERSION}.tar.gz" -o /tmp/cccbot.tar.gz
tar xzf /tmp/cccbot.tar.gz -C /tmp
# Archive extracts to CCCBot-{version}/ (without leading 'v' if tag is v1.0.0)
mv /tmp/CCCBot-*/* "$INSTALL_DIR/"
rm -rf /tmp/cccbot.tar.gz /tmp/CCCBot-*
```

### Windows (install.bat)
```bat
powershell -NoProfile -Command "Invoke-WebRequest 'https://github.com/lucianlamp/CCCBot/archive/refs/tags/%VERSION%.zip' -OutFile '%TEMP%\cccbot.zip'"
powershell -NoProfile -Command "Expand-Archive -Force '%TEMP%\cccbot.zip' '%TEMP%\cccbot-extract'"
rem Move contents from extracted CCCBot-{version}\ to INSTALL_DIR
```

## Git Init (Independent Workspace)

After file extraction:
```bash
git init
git add -A
git commit -m "CCCBot ${VERSION} installed"
```

- No remote configured — workspace is fully independent from dev repo
- User's subsequent changes (SOUL.md edits, CLAUDE.md tweaks) are tracked in their own history
- `.gitignore` placed before `git add -A` to exclude secrets/runtime files

## Update Flow

Re-running the installer on an existing directory:
1. Download new version archive
2. Overwrite core files (skills, scripts, templates, launchers, README)
3. Preserve user config files (CLAUDE.md, SOUL.md, BOOT.md, HEARTBEAT.md, JOBS.yaml, .claude/settings.json) — skip if exists
4. `git add -A && git commit -m "CCCBot updated to ${VERSION}"` to record the update

### Files overwritten on update (core)
- `.claude/skills/**`
- `scripts/**`
- `start.sh`, `start.bat`
- `README.md`, `README.ja.md`
- `LICENSE`

### Files preserved on update (user config)
- `CLAUDE.md`, `SOUL.md`, `BOOT.md`, `HEARTBEAT.md`, `JOBS.yaml`
- `.claude/settings.json`, `.claude/settings.local.json`
- `.mcp.json`
- `memory/`

## Installer Distribution

The installer scripts themselves live in `scripts/install.sh` and `scripts/install.bat` in the dev repo. Users execute them via raw URL one-liner (unchanged from current approach):

```bash
# macOS / Linux
bash <(curl -fsSL https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.sh)
```

```powershell
# Windows
$f="$env:TEMP\cccbot-install.bat"; (Invoke-WebRequest https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.bat).Content | Set-Content -Encoding ASCII $f; & $f
```

## README Changes

- Quick Start section: unchanged (same one-liner commands)
- Update section: change from `git pull` to "re-run the installer"
- Add version pinning example: `bash <(curl -fsSL ...) v1.0.0`

## Release Workflow

Developers create releases via `gh release create` or GitHub UI:
1. Tag the commit (e.g., `v1.0.0`)
2. Create GitHub Release — Source code archives are auto-generated
3. Users running `install.sh` without arguments get this latest release

No CI/CD or custom asset build required.
