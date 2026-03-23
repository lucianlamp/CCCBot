@echo off
rem CCC Session Restart Script
rem Called by heartbeat when MCP disconnection is detected.
rem Runs as a detached process: kills the old session, then starts a new one.

set "CCCBOT_DIR=%USERPROFILE%\.cccbot"
set "PID_FILE=%CCCBOT_DIR%\.claude\ccc-session.pid"
set "START_BAT=%~dp0..\start.bat"

echo [%date% %time%] CCC restart triggered

rem Wait for the calling process to finish its cleanup
timeout /t 3 /nobreak >nul

rem Read PID and kill the old session process tree
if not exist "%PID_FILE%" (
    echo No PID file found. Skipping kill.
    goto :start_new
)

set /p OLD_PID=<"%PID_FILE%"
echo Killing old session (PID: %OLD_PID%) and its process tree...
taskkill /PID %OLD_PID% /T /F >nul 2>&1

rem Wait for process to fully terminate
timeout /t 2 /nobreak >nul

:start_new
echo Starting new session...
call "%START_BAT%"
