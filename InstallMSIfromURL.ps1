# Get the current host name
$hostName = [System.Net.Dns]::GetHostName()


$logFilePath = "C:\Temp\installLog.txt"
$installLogPath = "C:\Temp\msi_install_log.log"

$installerUrl = "your url"
$localInstallerPath = "C:\Temp\install path"


$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"


if ($hostName -like "*MRDS*") {

    "$timestamp $hostName - Downloading installer." | Out-File $logFilePath -Append
    
    Invoke-WebRequest -Uri $installerUrl -OutFile $localInstallerPath

    "$timestamp $hostName - Installation started." | Out-File $logFilePath -Append

    Start-Process "msiexec.exe" -ArgumentList "/i `"$localInstallerPath`" /qn /l*v `"$installLogPath`"" -NoNewWindow -Wait

    "$timestamp $hostName - Installation complete." | Out-File $logFilePath -Append
} else {
    "$timestamp $hostName - Host name does not meet the criteria. Exiting script without action." | Out-File $logFilePath -Append
}