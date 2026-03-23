@echo off
rem CCCBot Workspace Launcher
rem Start Claude Code Channels session

set "CCCBOT_DIR=%USERPROFILE%\.cccbot"

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

echo Starting Claude Code Channels session...
echo Workspace: %CD%
echo Channels:  %CHANNELS%

claude --channels %CHANNELS% --remote-control
