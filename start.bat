@echo off
rem CCCBot Workspace Launcher
rem Start Claude Code Channels session

set "CCCBOT_DIR=%USERPROFILE%\.cccbot"
set "PID_FILE=%CCCBOT_DIR%\.ccc-pid"

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

rem Save this cmd.exe's PID (parent of powershell = this cmd.exe)
powershell -noprofile -command "(Get-CimInstance Win32_Process -Filter \"ProcessId=$PID\").ParentProcessId | Set-Content '%PID_FILE%'"

echo Starting Claude Code Channels session...
echo Workspace: %CD%
echo Channels:  %CHANNELS%

rem Start session (--continue unless CCC_FRESH is set)
if defined CCC_FRESH (
    echo Starting fresh session...
    set "CCC_FRESH="
    claude "/ccc-boot" --channels %CHANNELS% --remote-control
) else (
    claude "/ccc-boot" --continue --channels %CHANNELS% --remote-control
    if %errorlevel% neq 0 (
        echo Previous session not found. Starting fresh...
        claude "/ccc-boot" --channels %CHANNELS% --remote-control
    )
)

rem Clean up PID file on exit
del "%PID_FILE%" 2>nul
