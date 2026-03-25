@echo off
set "CCCBOT_DIR=%USERPROFILE%\.cccbot"
set "REPO=lucianlamp/CCCBot"

if "%~1"=="" goto :start
if /i "%~1"=="update" goto :update
echo Usage: cccbot [update [version]]
exit /b 1

:start
if not exist "%CCCBOT_DIR%\start.bat" (
    echo Error: CCCBot not found at %CCCBOT_DIR%
    echo Run the installer first: https://github.com/%REPO%
    exit /b 1
)
call "%CCCBOT_DIR%\start.bat"
goto :eof

:update
set "VERSION=%~2"
echo Updating CCCBot...
set "INSTALL_URL=https://raw.githubusercontent.com/%REPO%/master/scripts/install.bat"
set "TMPFILE=%TEMP%\cccbot-update-%RANDOM%.bat"
powershell -NoProfile -Command "Invoke-WebRequest '%INSTALL_URL%' -OutFile '%TMPFILE%'"
call "%TMPFILE%" %VERSION%
del "%TMPFILE%" 2>nul
exit /b 0
