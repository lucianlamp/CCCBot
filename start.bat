@echo off
:: CCC Workspace Launcher
:: Start Claude Code Channels session

cd /d "%~dp0"

echo Starting Claude Code Channels session...
echo Workspace: %CD%
echo.

echo Trying --continue...
claude --continue --channels plugin:telegram@claude-plugins-official --remote-control
if %ERRORLEVEL% neq 0 (
    echo No previous session found, starting fresh...
    claude --channels plugin:telegram@claude-plugins-official --remote-control
)
