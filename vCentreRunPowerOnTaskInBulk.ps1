# Import VMware PowerCLI module
# Import-Module VMware.PowerCLI

# Ensure the log directory exists
$logDirectory = "C:\temp\PowerCLI"
if (-not (Test-Path -Path $logDirectory)) {
    New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
}

# Prepare log file with timestamp
$logPath = $logDirectory + "\VM_PowerOn_Log.txt"
$date= Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
Function LogWrite {
    Param ([string]$logString)
    $timestampedLogString = $date + " " + $logString
    Add-Content $logPath -Value $timestampedLogString
}


$credential = Get-Credential -Message "Password please"
try {
    Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
    Connect-VIServer -Server YOURHOSTNAME -Credential $credential -ErrorAction Stop
    
    LogWrite Connected to vCenter YOURHOSTNAME
} catch {
    LogWrite Error connecting to vCenter YOURHOSTNAME Error $_
    exit
}

# Path to your CSV file
$csvPath = 'c:\temp\PowerCLI\test.csv'


$csvPath = 'c:\temp\PowerCLI\test.csv'

Import-Csv -Path $csvPath | ForEach-Object {
    $vmName = $_.VMName
    try {
        $vm = Get-VM -Name $vmName -ErrorAction Stop
        if ($vm.PowerState -eq "PoweredOff") {
            Start-VM -VM $vm -Confirm:$false
            LogWrite "Powered on VM $vmName"
        } else {
            LogWrite "VM already powered on $vmName"
        }
    } catch {
        LogWrite "VM not found or error powering on VM $vmName. Error $_"
    }
}

# Disconnect from vCenter
Disconnect-VIServer -Server hc-vc.horizoncloud.local -Confirm:$false -ErrorAction SilentlyContinue
LogWrite Disconnected from vCenter hc-vc.horizoncloud.local