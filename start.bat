@echo off
rem CCCBot Workspace Launcher
rem Start Claude Code Channels session

set "CCCBOT_DIR=%USERPROFILE%\.cccbot"
set "PID_FILE=%CCCBOT_DIR%\.ccc-pid"

rem Read user config from cccbot.json
set "CFG_CHANNELS="
set "CFG_WORKSPACE="
if exist "%CCCBOT_DIR%\cccbot.json" (
    for /f "usebackq delims=" %%i in (`powershell -noprofile -command "try { $j = Get-Content '%CCCBOT_DIR%\cccbot.json' -Raw | ConvertFrom-Json; if ($j.channels) { $j.channels } } catch { Write-Error 'invalid'; exit 1 }" 2^>nul`) do set "CFG_CHANNELS=%%i"
    if errorlevel 1 echo Warning: cccbot.json is invalid JSON. Using defaults.
    for /f "usebackq delims=" %%i in (`powershell -noprofile -command "try { $j = Get-Content '%CCCBOT_DIR%\cccbot.json' -Raw | ConvertFrom-Json; if ($j.workspace) { $j.workspace } } catch {}" 2^>nul`) do set "CFG_WORKSPACE=%%i"
)

rem Priority: env var > cccbot.json > default
if not defined CHANNELS if defined CFG_CHANNELS set "CHANNELS=%CFG_CHANNELS%"
if not defined CHANNELS set "CHANNELS=plugin:telegram@claude-plugins-official"
if not defined WORKSPACE if defined CFG_WORKSPACE set "WORKSPACE=%CFG_WORKSPACE%"
if not defined WORKSPACE set "WORKSPACE=workspace"

rem Check workspace exists
if exist "%CCCBOT_DIR%" goto :workspace_ok
echo Error - CCCBot workspace not found at %CCCBOT_DIR%
echo Run the installer first.
exit /b 1

:workspace_ok
cd /d "%CCCBOT_DIR%"

rem Resolve workspace path and add to additionalDirectories if external
powershell -noprofile -command "$ws='%WORKSPACE%';$cb='%CCCBOT_DIR%';if($ws-match'^[a-zA-Z]:'  -or $ws.StartsWith('/')-or $ws.StartsWith('\')){$abs=$ws}elseif($ws.StartsWith('~/')){$abs=Join-Path $env:USERPROFILE $ws.Substring(2)}else{$abs=Join-Path $cb $ws};if(-not(Test-Path $abs)){New-Item -ItemType Directory -Path $abs -Force|Out-Null};if(-not $abs.StartsWith($cb)){$f=Join-Path $cb '.claude\settings.local.json';$cfg=@{};if(Test-Path $f){$cfg=Get-Content $f -Raw|ConvertFrom-Json -AsHashtable};if(-not $cfg.permissions){$cfg.permissions=@{}};if(-not $cfg.permissions.additionalDirectories){$cfg.permissions.additionalDirectories=@()};if($abs -notin $cfg.permissions.additionalDirectories){$cfg.permissions.additionalDirectories+=$abs;$cfg|ConvertTo-Json -Depth 10|Set-Content $f}};Write-Host $abs" > "%TEMP%\ccc-workspace.tmp"
set /p WORKSPACE_ABS=<"%TEMP%\ccc-workspace.tmp"
del "%TEMP%\ccc-workspace.tmp" 2>nul

rem Ensure settings.json exists (may be missing after update)
if not exist ".claude\settings.json" (
    if not exist ".claude" mkdir ".claude"
    copy scripts\templates\settings.json.default .claude\settings.json >nul
    echo Created default .claude\settings.json
)

rem Save this cmd.exe's PID (parent of powershell = this cmd.exe)
powershell -noprofile -command "(Get-CimInstance Win32_Process -Filter \"ProcessId=$PID\").ParentProcessId | Set-Content '%PID_FILE%'"

echo Starting Claude Code Channels session...
echo Workspace: %CD%
echo Work dir:  %WORKSPACE_ABS%
echo Channels:  %CHANNELS%

rem Start session (--continue unless CCC_FRESH is set)
if defined CCC_FRESH (
    echo Starting fresh session...
    set "CCC_FRESH="
    claude "/ccc-boot" --channels %CHANNELS% --remote-control
) else (
    claude "/ccc-boot" --continue --channels %CHANNELS% --remote-control
    if %errorlevel% neq 0 (
        echo Previous session not found. Starting fresh...
        claude "/ccc-boot" --channels %CHANNELS% --remote-control
    )
)

rem Clean up PID file on exit
del "%PID_FILE%" 2>nul
