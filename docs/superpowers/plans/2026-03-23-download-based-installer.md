# Download-Based Installer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace git-clone installation with GitHub Releases archive download, creating independent user workspaces.

**Architecture:** Installer scripts download a release archive (tar.gz/zip) from GitHub Releases, extract to a temp directory, copy files to the install directory, then `git init` a fresh independent repo. Update flow overwrites core files while preserving user config.

**Tech Stack:** Bash (install.sh), Windows Batch + PowerShell (install.bat), GitHub Releases API

**Spec:** `docs/superpowers/specs/2026-03-23-download-based-installer-design.md`

---

### Task 1: Rewrite install.sh — replace git clone with release download

**Files:**

- Modify: `scripts/install.sh`

**Context:** The current install.sh uses `git clone "$REPO_URL" "$INSTALL_DIR"` (line 35). Replace the entire clone section with: version resolution → archive download → extraction → file placement. Keep the permission mode selection, settings.json setup, and template copy logic. Add git-clone migration detection and update flow support.

- [ ] **Step 1: Replace argument parsing and add version resolution**

Replace lines 4-5 with version-aware argument parsing. The first argument is now an optional version tag (e.g., `v1.0.0`), and install directory stays `$HOME/.cccbot`.

```bash
REPO="lucianlamp/CCCBot"
VERSION="${1:-}"
INSTALL_DIR="$HOME/.cccbot"

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
```

- [ ] **Step 2: Replace clone section with archive download and extraction**

Replace the current clone block (lines 29-40) with download + extraction logic. Handle both fresh install and update scenarios.

```bash
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

# Move extracted files to install directory
EXTRACTED_DIR=$(ls -d "$TMPDIR"/CCCBot-* 2>/dev/null | head -1)
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
```

- [ ] **Step 3: Add git-clone migration detection and set TEMPLATES_DIR**

After `cd "$INSTALL_DIR"`, detect if this was a git-clone workspace and remove the remote. Also define `TEMPLATES_DIR`.

```bash
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
```

- [ ] **Step 4: Wrap permission mode selection in update-skip conditional**

The existing permission mode selection (lines 44-75) should be skipped on update when `.claude/settings.json` already exists. Wrap the entire block:

```bash
# --- Permission mode selection (skip on update) ---
if [ "$IS_UPDATE" = true ] && [ -f ".claude/settings.json" ]; then
    echo "  Keeping existing settings"
else
    echo ""
    echo "=== Permission Mode ==="
    # ... (existing prompt code unchanged) ...
fi
```

- [ ] **Step 5: Reorder — .gitignore, settings.json, templates BEFORE git init/commit**

This is critical: all config files must be in place before `git add -A`. Keep the existing `.gitignore`, `settings.json`, and `copy_if_missing` template logic as-is (they already check for existence), but ensure they run BEFORE the git section.

The `copy_if_missing` function and its calls (CLAUDE.md, JOBS.yaml, BOOT.md, HEARTBEAT.md) should remain unchanged.

- [ ] **Step 6: Git init or update commit (AFTER all files are placed)**

```bash
# --- Git setup (after all files are in place) ---
if ! git rev-parse --git-dir &>/dev/null; then
    git init
    git add -A
    git commit -m "CCCBot ${VERSION} installed" --quiet
    echo -e "  ${GREEN}Initial commit created${NC}"
else
    if [ "$IS_UPDATE" = true ]; then
        git add -A
        git commit -m "CCCBot updated to ${VERSION}" --quiet 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}Update committed${NC}"
        else
            echo "  No changes to commit"
        fi
    fi
fi
```

- [ ] **Step 7: Remove old REPO_URL variable, update done message**

Replace:
```bash
REPO_URL="https://github.com/lucianlamp/CCCBot"
```

With version display in done message:
```bash
echo -e "${GREEN}CCCBot ${VERSION} installed to: $INSTALL_DIR${NC}"
```

- [ ] **Step 8: Verify install.sh has correct full structure**

Read the complete file and verify the flow is:
1. Colors + version resolution
2. Dependency check
3. Download + extract + file placement (with update preservation)
4. `cd` to install dir + set `TEMPLATES_DIR`
5. Migration detection
6. Permission mode selection (skip on update if settings.json exists)
7. .gitignore (if missing)
8. settings.json (if missing)
9. Template files via `copy_if_missing` (if missing)
10. Git init or update commit (AFTER all files placed)
11. Done message + launch

- [ ] **Step 9: Commit**

```bash
git add scripts/install.sh
git commit -m "feat: replace git clone with release download in install.sh"
```

---

### Task 2: Rewrite install.bat — replace git clone with release download

**Files:**

- Modify: `scripts/install.bat`

**Context:** Apply the same changes as Task 1 but for Windows batch. Use PowerShell for GitHub API calls and zip extraction. Remember bat pitfalls: use `rem` not `::`, use `goto` flow not `if/else` blocks, avoid colons in echo.

- [ ] **Step 1: Replace argument parsing with version resolution**

Replace the current argument handling (lines 4-9). First arg is now version, install dir is always `%USERPROFILE%\.cccbot`.

```bat
set "REPO=lucianlamp/CCCBot"
set "VERSION=%~1"
set "INSTALL_DIR=%USERPROFILE%\.cccbot"

rem Resolve latest version if not specified
if not "%VERSION%"=="" goto :version_set
echo Fetching latest release...
for /f "tokens=*" %%v in ('powershell -NoProfile -Command "(Invoke-RestMethod 'https://api.github.com/repos/%REPO%/releases/latest').tag_name"') do set "VERSION=%%v"
if "%VERSION%"=="" (
    echo Error - Could not determine latest release.
    echo Specify a version manually, e.g. install.bat v1.0.0
    exit /b 1
)
echo   Latest release -- %VERSION%
:version_set
```

- [ ] **Step 2: Replace clone section with archive download and extraction**

Replace clone block with download + PowerShell extraction + xcopy. Handle update flow with file preservation.

```bat
rem Download and extract release archive
set "TMPDIR=%TEMP%\cccbot-%RANDOM%"
mkdir "%TMPDIR%"
set "ARCHIVE_URL=https://github.com/%REPO%/archive/refs/tags/%VERSION%.zip"

echo Downloading CCCBot %VERSION%...
powershell -NoProfile -Command "Invoke-WebRequest '%ARCHIVE_URL%' -OutFile '%TMPDIR%\cccbot.zip'"
if %ERRORLEVEL% neq 0 (
    echo Error - Download failed. Check version tag %VERSION%
    rd /s /q "%TMPDIR%"
    exit /b 1
)

echo Extracting...
powershell -NoProfile -Command "Expand-Archive -Force '%TMPDIR%\cccbot.zip' '%TMPDIR%\extract'"
if %ERRORLEVEL% neq 0 (
    echo Error - Extraction failed.
    rd /s /q "%TMPDIR%"
    exit /b 1
)

rem Check for existing installation (update mode)
set "IS_UPDATE=0"
if exist "%INSTALL_DIR%\start.bat" set "IS_UPDATE=1"

rem On update, back up user config files
if "%IS_UPDATE%"=="0" goto :skip_backup
set "BACKUP_DIR=%TEMP%\cccbot-backup-%RANDOM%"
mkdir "%BACKUP_DIR%"
for %%f in (CLAUDE.md SOUL.md BOOT.md HEARTBEAT.md JOBS.yaml .mcp.json .gitignore) do (
    if exist "%INSTALL_DIR%\%%f" copy "%INSTALL_DIR%\%%f" "%BACKUP_DIR%\" >nul
)
if exist "%INSTALL_DIR%\.claude\settings.json" (
    mkdir "%BACKUP_DIR%\.claude" 2>nul
    copy "%INSTALL_DIR%\.claude\settings.json" "%BACKUP_DIR%\.claude\" >nul
)
if exist "%INSTALL_DIR%\.claude\settings.local.json" (
    mkdir "%BACKUP_DIR%\.claude" 2>nul
    copy "%INSTALL_DIR%\.claude\settings.local.json" "%BACKUP_DIR%\.claude\" >nul
)
if exist "%INSTALL_DIR%\memory" xcopy "%INSTALL_DIR%\memory" "%BACKUP_DIR%\memory\" /E /Q >nul

:skip_backup
rem Copy extracted files to install dir
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
for /d %%d in ("%TMPDIR%\extract\CCCBot-*") do xcopy "%%d\*" "%INSTALL_DIR%\" /E /Y /Q >nul

rem Restore user config files on update
if "%IS_UPDATE%"=="0" goto :skip_restore
for %%f in (CLAUDE.md SOUL.md BOOT.md HEARTBEAT.md JOBS.yaml .mcp.json .gitignore) do (
    if exist "%BACKUP_DIR%\%%f" copy "%BACKUP_DIR%\%%f" "%INSTALL_DIR%\" >nul
)
if exist "%BACKUP_DIR%\.claude\settings.json" copy "%BACKUP_DIR%\.claude\settings.json" "%INSTALL_DIR%\.claude\" >nul
if exist "%BACKUP_DIR%\.claude\settings.local.json" copy "%BACKUP_DIR%\.claude\settings.local.json" "%INSTALL_DIR%\.claude\" >nul
if exist "%BACKUP_DIR%\memory" xcopy "%BACKUP_DIR%\memory" "%INSTALL_DIR%\memory\" /E /Y /Q >nul
rd /s /q "%BACKUP_DIR%"

:skip_restore
rem Cleanup temp
rd /s /q "%TMPDIR%"
```

- [ ] **Step 3: Add git-clone migration detection and set TEMPLATES_DIR**

After `cd /d "%INSTALL_DIR%"`:

```bat
set "TEMPLATES_DIR=%INSTALL_DIR%\scripts\templates"

rem Migrate from git-clone workspace
git rev-parse --git-dir >nul 2>&1
if %ERRORLEVEL% neq 0 goto :no_migration
for /f "tokens=*" %%u in ('git remote get-url origin 2^>nul') do set "REMOTE_URL=%%u"
echo %REMOTE_URL% | findstr /i "lucianlamp/CCCBot" >nul 2>&1
if %ERRORLEVEL% neq 0 goto :no_migration
echo Detected old git-clone workspace. Removing dev remote...
git remote remove origin
:no_migration
```

- [ ] **Step 4: Wrap permission mode selection in update-skip conditional**

Skip permission mode prompt on update when `.claude\settings.json` already exists:

```bat
rem --- Permission mode selection (skip on update) ---
if "%IS_UPDATE%"=="0" goto :show_perm_prompt
if exist ".claude\settings.json" goto :perm_done
:show_perm_prompt
rem ... (existing permission prompt code) ...
```

- [ ] **Step 5: Reorder — .gitignore, settings.json, templates BEFORE git init/commit**

Same as Task 1: all config files must be placed before `git add -A`. Keep existing `.gitignore`, `settings.json`, and `copy_if_missing` logic.

- [ ] **Step 6: Git init or update commit (AFTER all files placed, goto-based flow)**

```bat
rem --- Git setup (after all files are in place) ---
git rev-parse --git-dir >nul 2>&1
if %ERRORLEVEL% equ 0 goto :git_exists

git init
git add -A
git commit -m "CCCBot %VERSION% installed" --quiet
echo   Initial commit created
goto :git_done

:git_exists
if "%IS_UPDATE%"=="0" goto :git_done
git add -A
git commit -m "CCCBot updated to %VERSION%" --quiet 2>nul
if %ERRORLEVEL% neq 0 goto :no_changes
echo   Update committed
goto :git_done
:no_changes
echo   No changes to commit

:git_done
```

- [ ] **Step 7: Update done message with version**

```bat
echo.
echo CCCBot %VERSION% installed to %INSTALL_DIR%
echo.
```

- [ ] **Step 8: Verify install.bat has correct full structure**

Same verification as Task 1 Step 8, adapted for bat syntax. Ensure no `::` comments, no colons in echo, `goto`-based flow control throughout.

- [ ] **Step 9: Commit**

```bash
git add scripts/install.bat
git commit -m "feat: replace git clone with release download in install.bat"
```

---

### Task 3: Update start.sh and start.bat — remove clone-era assumptions

**Files:**

- Modify: `start.sh`
- Modify: `start.bat`

**Context:** The launcher scripts currently auto-run the installer if `~/.cccbot` doesn't exist (assuming it will clone). With the download-based installer, the launcher should NOT auto-install because the user needs to run the installer explicitly (with optional version arg). Also update the "Ensure settings.json exists" comment.

- [ ] **Step 1: Update start.sh**

Replace the auto-install block (lines 16-21) with a message directing the user to run the installer.

```bash
# Check workspace exists
if [ ! -d "$CCCBOT_DIR" ]; then
    echo "Error: CCCBot workspace not found at $CCCBOT_DIR"
    echo "Run the installer first:"
    echo "  bash <(curl -fsSL https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.sh)"
    exit 1
fi
```

Update the settings.json comment from "may be missing after git pull" to "may be missing after manual update".

- [ ] **Step 2: Update start.bat**

Same change for Windows. Also replace ALL `::` comments with `rem` throughout the file (lines 2-3, 7-8, 10, 14, 19 in current start.bat):

```bat
rem Check workspace exists
if exist "%CCCBOT_DIR%" goto :workspace_ok
echo Error - CCCBot workspace not found at %CCCBOT_DIR%
echo Run the installer first.
exit /b 1

:workspace_ok
```

Update settings.json comment from "may be missing after git pull" to "may be missing after manual update".

- [ ] **Step 3: Commit**

```bash
git add start.sh start.bat
git commit -m "feat: update launchers for download-based installer"
```

---

### Task 4: Update README.md and README.ja.md

**Files:**

- Modify: `README.md`
- Modify: `README.ja.md`

**Context:** Update the Updating section and add version pinning documentation. Quick Start section stays the same.

- [ ] **Step 1: Update README.md Updating section**

Replace the `git pull` update instructions with re-run installer:

```markdown
## Updating

Re-run the installer to update to the latest release:

\`\`\`bash
# macOS / Linux
bash <(curl -fsSL https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.sh)
\`\`\`

\`\`\`powershell
# Windows (PowerShell)
$f="$env:TEMP\cccbot-install.bat"; (Invoke-WebRequest https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.bat).Content | Set-Content -Encoding ASCII $f; & $f
\`\`\`

To install a specific version:

\`\`\`bash
bash <(curl -fsSL https://raw.githubusercontent.com/lucianlamp/CCCBot/master/scripts/install.sh) v1.0.0
\`\`\`

Skills, scripts, and templates are updated. Your personal config files (`SOUL.md`, `CLAUDE.md`, `JOBS.yaml`, `BOOT.md`, `HEARTBEAT.md`) and settings are preserved.
```

- [ ] **Step 2: Update README.ja.md Updating section**

Same changes in Japanese.

- [ ] **Step 3: Commit**

```bash
git add README.md README.ja.md
git commit -m "docs: update README for download-based installer"
```

---

### Task 5: Create initial GitHub Release

**Context:** The installer needs at least one release to download. Create the first release tag so the installer can resolve `latest`.

- [ ] **Step 1: Push all changes to remote**

```bash
git push
```

- [ ] **Step 2: Create v1.0.0 release**

```bash
gh release create v1.0.0 --title "v1.0.0" --notes "Initial release with download-based installer."
```

- [ ] **Step 3: Verify release archive is accessible**

```bash
curl -fsSL -o /dev/null -w "%{http_code}" "https://github.com/lucianlamp/CCCBot/archive/refs/tags/v1.0.0.tar.gz"
```

Expected: `200`

---

### Task 6: End-to-end test

- [ ] **Step 1: Test fresh install on Windows**

Delete `%USERPROFILE%\.cccbot` if it exists, then run:

```bat
scripts\install.bat
```

Verify:
- Latest version is resolved and displayed
- Archive is downloaded and extracted
- Permission mode prompt works
- `git init` creates a fresh repo with no remote
- User config files are generated from templates
- `git log` shows only the install commit

- [ ] **Step 2: Test update on Windows**

Run `scripts\install.bat` again on the existing installation.

Verify:
- Detects existing installation
- Core files updated, user config preserved
- Update committed to git

- [ ] **Step 3: Test version pinning**

```bat
scripts\install.bat v1.0.0
```

Verify specific version is downloaded.

- [ ] **Step 4: Commit any fixes**

If any issues are found during testing, fix and commit.
