@echo off
:: CCCBot — Claude Code Channels Bot Installer

set "REPO_URL=https://github.com/lucianlamp/CCCBot"
if "%~1"=="" (
    set "INSTALL_DIR=%USERPROFILE%\.cccbot"
) else (
    set "INSTALL_DIR=%~1"
)

echo CCCBot -- Claude Code Channels Bot Installer
echo =============================================
echo(

:: Check dependencies
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: git not found. Please install git first.
    exit /b 1
)

where claude >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: claude CLI not found.
    echo Install it from: https://claude.ai/code
    exit /b 1
)

:: Clone repo
if exist "%INSTALL_DIR%" (
    echo Directory already exists: %INSTALL_DIR%
    echo Skipping clone. Updating templates only.
) else (
    echo Cloning to %INSTALL_DIR%...
    git clone "%REPO_URL%" "%INSTALL_DIR%"
    if %ERRORLEVEL% neq 0 (
        echo Error: Clone failed.
        exit /b 1
    )
)

cd /d "%INSTALL_DIR%"

:: Run shared setup (template copy, gitignore, etc.)
echo(
call "%INSTALL_DIR%\scripts\setup.bat"

:: Done
echo(
echo CCC installed to: %INSTALL_DIR%
echo(
echo Docs: %REPO_URL%
echo(

:: Launch
call "%INSTALL_DIR%\start.bat"
