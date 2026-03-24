---
name: ccc-restart
description: Restart the CCC session — reply confirmation via Telegram, then launch restart script outside process tree via wmic
---

# Restart Skill

Restarts the CCC session. Triggered by user saying "再起動して", "restart", etc.

## Steps

1. Send a confirmation message via Telegram `reply` tool: "再起動します"
2. Detect OS and launch restart-session outside the current process tree:
   - **Native Windows** (no `/proc/version`):
     ```
     powershell -noprofile -command "[void](([wmiclass]'Win32_Process').Create('cmd /c \"'+$env:USERPROFILE+'\.cccbot\scripts\restart-session.bat\"'))"
     ```
   - **WSL** (`/proc/version` contains "microsoft"):
     ```
     nohup "$HOME/.cccbot/scripts/restart-session.sh" > /tmp/ccc-restart.log 2>&1 &
     ```
     (restart-session.sh auto-detects WSL and opens a new terminal window via `wt.exe` or `cmd.exe`)
   - **macOS/Linux** (everything else):
     ```
     nohup "$HOME/.cccbot/scripts/restart-session.sh" > /tmp/ccc-restart.log 2>&1 &
     ```
3. Exit immediately. The restart script will kill this session after 3 seconds.

## Important

- MUST use `wmic` (not `Start-Process`) on native Windows — Start-Process creates a child process that gets killed along with the parent tree.
- On WSL, restart-session.sh handles opening a new terminal window (via `wt.exe` or `cmd.exe /c start`).
- The confirmation message MUST be sent BEFORE launching the restart.
- restart-session scripts wait 3s, kill old session via PID file, then start a new session.
