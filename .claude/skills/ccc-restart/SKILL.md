---
name: ccc-restart
description: Restart the CCC session — reply confirmation via Telegram, then launch restart script outside process tree via wmic
---

# Restart Skill

Restarts the CCC session. Triggered by user saying "再起動して", "restart", etc.

## Steps

1. Send a confirmation message via Telegram `reply` tool: "再起動します"
2. Detect OS and launch restart-session via wmic (creates process OUTSIDE current tree):
   - Windows:
     ```
     powershell -noprofile -command "[void](([wmiclass]'Win32_Process').Create('cmd /c \"'+$env:USERPROFILE+'\.cccbot\scripts\restart-session.bat\"'))"
     ```
   - macOS/Linux:
     ```
     nohup "$HOME/.cccbot/scripts/restart-session.sh" > /tmp/ccc-restart.log 2>&1 &
     ```
3. Exit immediately. The restart script will kill this session after 3 seconds.

## Important

- MUST use `wmic` (not `Start-Process`) on Windows — Start-Process creates a child process that gets killed along with the parent tree.
- The confirmation message MUST be sent BEFORE launching the restart.
- restart-session.bat waits 3s, kills old session via PID file, then calls start.bat.
