@echo off
:: CCCBot - First-run setup
:: Copies template files to project root if they don't exist.
:: Called by install.bat and boot skill.

setlocal

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
    copy "%TEMPLATES_DIR%\.gitignore.default" ".gitignore" >nul
    echo   Created: .gitignore
)

:: --- Settings ---
if not exist ".claude" mkdir ".claude"
if not exist ".claude\settings.json" (
    copy "%TEMPLATES_DIR%\settings.json.default" ".claude\settings.json" >nul
    echo   Created: .claude\settings.json
) else (
    echo   Skipped [exists]: .claude\settings.json
)

:: --- Template files ---
:: Structural files only. SOUL.md is created by /ccc-setup interactively.
call :copy_if_missing "%TEMPLATES_DIR%\CLAUDE.example.md"    "CLAUDE.md"
call :copy_if_missing "%TEMPLATES_DIR%\JOBS.example.yaml"    "JOBS.yaml"
call :copy_if_missing "%TEMPLATES_DIR%\BOOT.example.md"      "BOOT.md"
call :copy_if_missing "%TEMPLATES_DIR%\HEARTBEAT.example.md" "HEARTBEAT.md"

:: --- Summary ---
echo Setup complete.

endlocal
goto :eof

:copy_if_missing
if not exist "%~2" (
    copy "%~1" "%~2" >nul
    echo   Created: %~2
) else (
    echo   Skipped [exists]: %~2
)
goto :eof
