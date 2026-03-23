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
    :: install.bat already launches start.bat, so exit here to avoid double-launch
    exit /b %ERRORLEVEL%
)
cd /d "%CCCBOT_DIR%"

echo Starting Claude Code Channels session...
echo Workspace: %CD%
echo Channels:  %CHANNELS%

claude --channels %CHANNELS% --remote-control "/ccc-boot"
