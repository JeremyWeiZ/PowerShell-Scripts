$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -Command `"& 'C:\temp\uninstalla1.ps1'`""
$trigger = New-ScheduledTaskTrigger -Daily -At '2:45PM'
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount


$taskName = "UnstallActionOneOnMRDS"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal | Out-Null


$task = Get-ScheduledTask -TaskName $taskName


$task.Settings.RestartCount = 3 # Number of retries
$task.Settings.RestartInterval = "PT10M" # Retry interval in ISO 8601 format (PT10M = 10 minutes)


Set-ScheduledTask -TaskName $taskName -Settings $task.Settings

"Task '$taskName' registered and configured to retry on failure." | Out-File -FilePath "C:\Temp\TaskSchedulerLog.txt" -Append