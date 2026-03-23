@echo off
:: CCCBot — First-run setup
:: Copies template files to project root if they don't exist.
:: Called by install.bat and boot skill.

setlocal enabledelayedexpansion

:: Resolve paths relative to this script
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "PROJECT_DIR=%%~fI"
set "TEMPLATES_DIR=%SCRIPT_DIR%\templates"

cd /d "%PROJECT_DIR%"

:: --- Git setup ---
git rev-parse --git-dir >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Initializing git repository...
    git init
)

if not exist ".gitignore" (
    echo Creating .gitignore...
    (
        echo # MCP config ^(contains bot tokens^)
        echo .mcp.json
        echo.
        echo # Personal configuration ^(use *.example.md as templates^)
        echo CLAUDE.md
        echo CRONS.md
        echo USER.md
        echo SOUL.md
        echo MEMORY.md
        echo BOOT.md
        echo HEARTBEAT.md
        echo.
        echo # Runtime / session data
        echo memory/
        echo .claude/scheduled_tasks.lock
        echo.
        echo # Local machine overrides
        echo .claude/settings.local.json
        echo.
        echo # Security: Telegram access list
        echo .claude/access.json
        echo **/access.json
        echo.
        echo # Secrets and credentials
        echo .env
        echo **/*.key
        echo **/*.pem
        echo **/*.secret
        echo **/secrets.*
        echo **/credentials.*
    ) > .gitignore
    echo   Created: .gitignore
)

:: --- Template files ---
set "COUNT=0"

call :copy_if_missing "%TEMPLATES_DIR%\CLAUDE.example.md"    "CLAUDE.md"
call :copy_if_missing "%TEMPLATES_DIR%\SOUL.example.md"      "SOUL.md"
call :copy_if_missing "%TEMPLATES_DIR%\USER.example.md"      "USER.md"
call :copy_if_missing "%TEMPLATES_DIR%\CRONS.example.md"     "CRONS.md"
call :copy_if_missing "%TEMPLATES_DIR%\BOOT.example.md"      "BOOT.md"
call :copy_if_missing "%TEMPLATES_DIR%\HEARTBEAT.example.md" "HEARTBEAT.md"

:: --- Summary ---
echo.
if %COUNT% equ 0 (
    echo All config files already exist. Nothing to do.
) else (
    echo Setup complete. Created %COUNT% file(s).
)

endlocal
goto :eof

:copy_if_missing
if not exist "%~2" (
    copy "%~1" "%~2" >nul
    set /a COUNT+=1
    echo   Created: %~2
) else (
    echo   Skipped (exists^): %~2
)
goto :eof
