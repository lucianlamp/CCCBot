@echo off
rem CCCBot - Claude Code Channels Bot Installer

set "REPO_URL=https://github.com/lucianlamp/CCCBot"
if "%~1"=="" (
    set "INSTALL_DIR=%USERPROFILE%\.cccbot"
) else (
    set "INSTALL_DIR=%~1"
)

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

rem Clone repo
if exist "%INSTALL_DIR%" goto :skip_clone
echo Cloning to %INSTALL_DIR%...
git clone "%REPO_URL%" "%INSTALL_DIR%"
if %ERRORLEVEL% neq 0 (
    echo Error - Clone failed.
    exit /b 1
)
goto :clone_done

:skip_clone
echo Directory already exists - %INSTALL_DIR%
echo Skipping clone. Updating templates only.

:clone_done
cd /d "%INSTALL_DIR%"

rem --- Permission mode selection ---
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
set "TEMPLATES_DIR=%INSTALL_DIR%\scripts\templates"

rem --- Git setup ---
git rev-parse --git-dir >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Initializing git repository...
    git init
)

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

rem Done
echo.
echo CCC installed to %INSTALL_DIR%
echo Docs %REPO_URL%
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
