# Returns the parent process ID of the calling process
param([int]$ChildPid = $PID)
$proc = Get-CimInstance Win32_Process -Filter "ProcessId=$ChildPid"
Write-Output $proc.ParentProcessId
