@echo off
rem CCC Session Restart
rem Launched via wmic (outside process tree) to safely kill old session.

set "CCCBOT_DIR=%USERPROFILE%\.cccbot"
set "PID_FILE=%CCCBOT_DIR%\.ccc-pid"

echo [%date% %time%] CCC restart triggered

rem Wait for Claude to finish its reply
timeout /t 3 /nobreak >nul

rem Kill old session via PID file
if exist "%PID_FILE%" (
    powershell -noprofile -command "$p=(Get-Content '%PID_FILE%').Trim(); if($p -and (Get-Process -Id $p -ErrorAction SilentlyContinue)){echo \"Killing PID $p\"; taskkill /PID $p /T /F}else{echo 'No active session'}; Remove-Item '%PID_FILE%' -ErrorAction SilentlyContinue"
    timeout /t 5 /nobreak >nul
)

rem Start new session (skip --continue, force fresh start)
set "CCC_FRESH=1"
call "%CCCBOT_DIR%\start.bat"
