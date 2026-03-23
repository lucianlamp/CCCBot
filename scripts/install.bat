@echo off
rem CCCBot - Claude Code Channels Bot Installer

set "REPO=lucianlamp/CCCBot"
set "VERSION=%~1"
set "INSTALL_DIR=%USERPROFILE%\.cccbot"

echo CCCBot -- Claude Code Channels Bot Installer
echo =============================================

rem Check dependencies
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error - git not found. Please install git first.
    exit /b 1
)

where claude >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error - claude CLI not found.
    echo Install it from https://claude.ai/code
    exit /b 1
)

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

rem Validate version format to prevent command injection
echo %VERSION% | findstr /r "^v[0-9]" >nul
if %ERRORLEVEL% neq 0 (
    echo Error - Invalid version format: %VERSION%
    echo Version must start with v followed by a number, e.g. v1.0.0
    exit /b 1
)

rem Download and extract release archive
set "TMPDIR=%TEMP%\cccbot-%RANDOM%%RANDOM%"
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
echo Existing installation detected. Updating...
set "BACKUP_DIR=%TEMP%\cccbot-backup-%RANDOM%%RANDOM%"
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

cd /d "%INSTALL_DIR%"
set "TEMPLATES_DIR=%INSTALL_DIR%\scripts\templates"

rem Migrate from git-clone workspace
git rev-parse --git-dir >nul 2>&1
if %ERRORLEVEL% neq 0 goto :no_migration
set "REMOTE_URL="
for /f "tokens=*" %%u in ('git remote get-url origin 2^>nul') do set "REMOTE_URL=%%u"
if "%REMOTE_URL%"=="" goto :no_migration
echo %REMOTE_URL% | findstr /i "lucianlamp/CCCBot" >nul 2>&1
if %ERRORLEVEL% neq 0 goto :no_migration
echo Detected old git-clone workspace. Removing dev remote...
git remote remove origin
:no_migration

rem --- Permission mode selection (skip on update) ---
if "%IS_UPDATE%"=="0" goto :show_perm_prompt
if exist ".claude\settings.json" goto :perm_done
:show_perm_prompt
echo.
echo === Permission Mode ===
echo.
echo Claude Code needs permission settings to control tool execution.
echo.
echo   1) bypass -- All tools run without confirmation (full autonomy)
echo      Best for experienced users, background bot operation
echo.
echo   2) allowEdits -- File edits auto-approved, Bash/dangerous tools require confirmation
echo      Best for first-time users, security-conscious setups
echo.

:ask_perm
set "PERM_CHOICE="
set /p "PERM_CHOICE=Select permission mode [1/2] (default 1) "
if "%PERM_CHOICE%"=="" set "PERM_CHOICE=1"
if "%PERM_CHOICE%"=="1" goto :perm_bypass
if "%PERM_CHOICE%"=="bypass" goto :perm_bypass
if "%PERM_CHOICE%"=="2" goto :perm_allowedits
if "%PERM_CHOICE%"=="allowEdits" goto :perm_allowedits
echo   Invalid choice. Enter 1 or 2.
goto :ask_perm

:perm_bypass
set "CCC_PERMISSION_MODE=bypassPermissions"
echo   -^> bypass mode selected
goto :perm_done

:perm_allowedits
set "CCC_PERMISSION_MODE=allowEdits"
echo   -^> allowEdits mode selected
goto :perm_done

:perm_done

rem --- .gitignore ---
if exist ".gitignore" goto :skip_gitignore
copy "%TEMPLATES_DIR%\.gitignore.default" ".gitignore" >nul
echo   Created .gitignore
goto :gitignore_done

:skip_gitignore
echo   Skipped, already exists .gitignore

:gitignore_done

rem --- settings.json (with selected permission mode) ---
if not exist ".claude" mkdir ".claude"
if exist ".claude\settings.json" goto :skip_settings
copy "%TEMPLATES_DIR%\settings.json.default" ".claude\settings.json" >nul
powershell -NoProfile -Command "(Get-Content '.claude\settings.json') -replace '\"defaultMode\": \"bypassPermissions\"', '\"defaultMode\": \"%CCC_PERMISSION_MODE%\"' | Set-Content '.claude\settings.json'"
echo   Created .claude\settings.json (mode %CCC_PERMISSION_MODE%)
goto :settings_done

:skip_settings
echo   Skipped, already exists .claude\settings.json

:settings_done

rem --- Template files ---
call :copy_if_missing "%TEMPLATES_DIR%\CLAUDE.example.md"    "CLAUDE.md"
call :copy_if_missing "%TEMPLATES_DIR%\JOBS.example.yaml"    "JOBS.yaml"
call :copy_if_missing "%TEMPLATES_DIR%\BOOT.example.md"      "BOOT.md"
call :copy_if_missing "%TEMPLATES_DIR%\HEARTBEAT.example.md" "HEARTBEAT.md"

rem --- Git setup (after all files are in place) ---
git rev-parse --git-dir >nul 2>&1
if %ERRORLEVEL% equ 0 goto :git_exists

git init
rem Set fallback git identity if not configured
git config user.name >nul 2>&1 || git config user.name "CCCBot"
git config user.email >nul 2>&1 || git config user.email "cccbot@localhost"
rem NOTE: git add -A is safe here — .gitignore is already in place, excluding secrets and user config
git add -A
git commit -m "CCCBot %VERSION% installed" --quiet
echo   Initial commit created
goto :git_done

:git_exists
if "%IS_UPDATE%"=="0" goto :git_done
rem NOTE: git add -A is safe here — .gitignore is in place and user config files are preserved
git add -A
git commit -m "CCCBot updated to %VERSION%" --quiet 2>nul
if %ERRORLEVEL% neq 0 goto :no_changes
echo   Update committed
goto :git_done
:no_changes
echo   No changes to commit

:git_done

rem Done
echo.
echo CCCBot %VERSION% installed to %INSTALL_DIR%
echo.

rem Launch
call "%INSTALL_DIR%\start.bat"
goto :eof

:copy_if_missing
if exist "%~2" goto :copy_skip
copy "%~1" "%~2" >nul
echo   Created %~2
goto :eof

:copy_skip
echo   Skipped, already exists %~2
goto :eof
