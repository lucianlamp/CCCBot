@echo off
:: CCC Workspace Launcher
:: Start Claude Code Channels session

set "CCCBOT_DIR=%USERPROFILE%\.cccbot"

:: First run: install if .cccbot doesn't exist
if not exist "%CCCBOT_DIR%" (
    echo .cccbot not found. Running installer...
    call "%~dp0install.bat"
    if %ERRORLEVEL% neq 0 (
        echo Install failed. Exiting.
        exit /b 1
    )
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
