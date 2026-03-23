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

:: --- Template files ---
call :copy_if_missing "%TEMPLATES_DIR%\CLAUDE.example.md"    "CLAUDE.md"
call :copy_if_missing "%TEMPLATES_DIR%\SOUL.example.md"      "SOUL.md"
call :copy_if_missing "%TEMPLATES_DIR%\USER.example.md"      "USER.md"
call :copy_if_missing "%TEMPLATES_DIR%\CRONS.example.md"     "CRONS.md"
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
