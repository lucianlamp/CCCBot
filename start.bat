@echo off
rem CCCBot Workspace Launcher
rem Start Claude Code Channels session

set "CCCBOT_DIR=%USERPROFILE%\.cccbot"
set "PID_FILE=%CCCBOT_DIR%\.claude\ccc-session.pid"

rem Channels to enable
if not defined CHANNELS set "CHANNELS=plugin:telegram@claude-plugins-official"

rem Check workspace exists
if exist "%CCCBOT_DIR%" goto :workspace_ok
echo Error - CCCBot workspace not found at %CCCBOT_DIR%
echo Run the installer first.
exit /b 1

:workspace_ok
cd /d "%CCCBOT_DIR%"

rem Ensure settings.json exists (may be missing after update)
if not exist ".claude\settings.json" (
    if not exist ".claude" mkdir ".claude"
    copy scripts\templates\settings.json.default .claude\settings.json >nul
    echo Created default .claude\settings.json
)

rem Write this cmd.exe's PID to file (for restart-session.bat to kill)
title CCC-Session
for /f %%a in ('powershell -noprofile -ExecutionPolicy Bypass -File "%~dp0scripts\get-parent-pid.ps1"') do (
    echo %%a> "%PID_FILE%"
)

echo Starting Claude Code Channels session...
echo Workspace: %CD%
echo Channels:  %CHANNELS%
echo PID file:  %PID_FILE%

rem Try to resume previous session first; fall back to fresh start
claude --continue --channels %CHANNELS% --remote-control
if %errorlevel% neq 0 (
    echo Previous session not found. Starting fresh...
    claude --channels %CHANNELS% --remote-control
)

rem Clean up PID file on exit
del "%PID_FILE%" 2>nul
