@echo off
:: CCCBot Workspace Launcher
:: Start Claude Code Channels session

set "CCCBOT_DIR=%USERPROFILE%\.cccbot"

:: Channels to enable
if not defined CHANNELS set "CHANNELS=plugin:telegram@claude-plugins-official"

:: First run: install if .cccbot doesn't exist
if not exist "%CCCBOT_DIR%" (
    echo .cccbot not found. Running installer...
    call "%~dp0scripts\install.bat"
    if %ERRORLEVEL% neq 0 (
        echo Install failed. Exiting.
        exit /b 1
    )
)
cd /d "%CCCBOT_DIR%"

echo Starting Claude Code Channels session...
echo Workspace: %CD%
echo Channels:  %CHANNELS%

echo Trying --continue...
claude --continue --channels %CHANNELS% --remote-control
if %ERRORLEVEL% neq 0 (
    echo No previous session found, starting fresh...
    claude --channels %CHANNELS% --remote-control
)
