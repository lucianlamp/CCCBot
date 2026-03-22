@echo off
:: CCCBot — Claude Code Channels Bot Installer

set "REPO_URL=https://github.com/lucianlamp/CCCBot"
if "%~1"=="" (
    set "INSTALL_DIR=%USERPROFILE%\.cccbot"
) else (
    set "INSTALL_DIR=%~1"
)

echo CCCBot -- Claude Code Channels Bot Installer
echo =============================================
echo.

:: Check dependencies
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: git not found. Please install git first.
    exit /b 1
)

where claude >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: claude CLI not found.
    echo Install it from: https://claude.ai/code
    exit /b 1
)

:: Clone repo
if exist "%INSTALL_DIR%" (
    echo Directory already exists: %INSTALL_DIR%
    echo Skipping clone. Updating templates only.
) else (
    echo Cloning to %INSTALL_DIR%...
    git clone "%REPO_URL%" "%INSTALL_DIR%"
    if %ERRORLEVEL% neq 0 (
        echo Error: Clone failed.
        exit /b 1
    )
)

cd /d "%INSTALL_DIR%"

:: Copy template files (skip if already exists)
echo.
echo Setting up personal config files...
set "T=.claude\skills\setup\templates"

call :copy_if_missing "%T%\.mcp.json.example"    ".mcp.json"
call :copy_if_missing "%T%\SOUL.example.md"      "SOUL.md"
call :copy_if_missing "%T%\IDENTITY.example.md"  "IDENTITY.md"
call :copy_if_missing "%T%\USER.example.md"      "USER.md"
call :copy_if_missing "%T%\CRONS.example.md"     "CRONS.md"
call :copy_if_missing "%T%\BOOT.example.md"      "BOOT.md"
call :copy_if_missing "%T%\HEARTBEAT.example.md" "HEARTBEAT.md"
call :copy_if_missing "%T%\TOOLS.example.md"     "TOOLS.md"

:: Done
echo.
echo CCC installed to: %INSTALL_DIR%
echo.
echo Next steps:
echo   1. Edit .mcp.json       -- add your Telegram bot token
echo   2. Edit USER.md         -- describe yourself and your projects
echo   3. Edit SOUL.md         -- customize the assistant persona (optional)
echo   4. Edit CRONS.md        -- set up scheduled jobs (optional)
echo   5. Run: start.bat       -- start the assistant
echo.
echo Docs: %REPO_URL%
goto :eof

:copy_if_missing
if not exist "%~2" (
    copy "%~1" "%~2" >nul
    echo   Created: %~2
) else (
    echo   Skipped (exists): %~2
)
goto :eof
