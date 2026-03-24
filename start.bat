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

rem Prevent double-launch: check if another session is already running
if not exist "%PID_FILE%" goto :no_existing
set /p EXISTING_PID=<"%PID_FILE%"
tasklist /FI "PID eq %EXISTING_PID%" /NH 2>nul | findstr /r "[0-9]" >nul
if %ERRORLEVEL% neq 0 goto :stale_pid
echo Error - CCC session already running (PID: %EXISTING_PID%)
echo Use scripts\restart-session.bat to restart.
exit /b 1
:stale_pid
echo Warning - Stale PID file found. Cleaning up.
del "%PID_FILE%" 2>nul
:no_existing

rem Guard: verify scripts directory exists
if not exist "%~dp0scripts\get-parent-pid.ps1" (
    echo Error - scripts directory not found relative to start.bat
    exit /b 1
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
claude "/ccc-boot" --continue --channels %CHANNELS% --remote-control
if %errorlevel% neq 0 (
    echo Previous session not found. Starting fresh...
    claude "/ccc-boot" --channels %CHANNELS% --remote-control
)

rem Clean up PID file on exit
del "%PID_FILE%" 2>nul
