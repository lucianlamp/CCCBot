@echo off
:: CCC Workspace Launcher
:: Start Claude Code Channels session

:: Use ~/.cccbot/ as workspace directory (create if missing)
set "CCCBOT_DIR=%USERPROFILE%\.cccbot"
if not exist "%CCCBOT_DIR%" (
    echo Creating workspace directory: %CCCBOT_DIR%
    mkdir "%CCCBOT_DIR%"
)
cd /d "%CCCBOT_DIR%"

echo Starting Claude Code Channels session...
echo Workspace: %CD%
echo.

echo Trying --continue...
claude --continue --channels plugin:telegram@claude-plugins-official --remote-control
if %ERRORLEVEL% neq 0 (
    echo No previous session found, starting fresh...
    claude --channels plugin:telegram@claude-plugins-official --remote-control
)
