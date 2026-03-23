# Returns the parent process ID of the calling process.
# Call chain: start.bat -> powershell -> this script.
# PowerShell's $PID is PowerShell itself, so ParentProcessId gives cmd.exe (start.bat).
param([int]$ChildPid = $PID)
$proc = Get-CimInstance Win32_Process -Filter "ProcessId=$ChildPid"
Write-Output $proc.ParentProcessId
