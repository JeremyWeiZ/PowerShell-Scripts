# Load Veeam PowerShell Snap-In
asnp "VeeamPSSnapIn" -ErrorAction SilentlyContinue
$veeamServer = "your Veeam server name"
Connect-VBRServer -Server $veeamServer

# Retrieve the entire vCenter VM hierarchy, focusing on VMs and Templates for object paths
$vmsandtemplates = Find-VBRViEntity -VMsAndTemplates
$vmfoldertree = $vmsandtemplates | Where-Object {$_.Type -eq "Vm"}
$vmfolders = $vmsandtemplates | Where-Object {$_.Type -eq "Folder"}

# Initialize a list to store the result
$results = @()

# Retrieve backup jobs that start with the key word you like: BM in this case
$jobs = Get-VBRJob | Where-Object {$_.Name -like "BM*"}

foreach ($job in $jobs) {
    # Retrieve all included objects in the job (assuming single folders for simplicity)
    $jobobjs = $job.GetObjectsInJob() | Where-Object {$_.Type -eq "Include"}

    foreach ($jobobj in $jobobjs) {
        $jobobjid = $jobobj.GetObject().Info.HostId.ToString() + "_" + $jobobj.GetObject().Info.ObjectId
        $jobobjpath = ($vmfolders | Where-Object {$_.Id -eq "$jobobjid"}).Path
        
        # Get subset of VMs that are in the identified folder
        $vmsinfolder = $vmfoldertree | Where-Object {$_.Path -like "$jobobjpath*"} | Sort-Object -Property Name

        foreach ($vm in $vmsinfolder) {
    $results += New-Object PSObject -Property ([ordered]@{
        JobName = $job.Name
        FolderPath = $jobobjpath
        VMName = $vm.Name
        })
        }
    }
}

# Disconnect from Veeam Backup & Replication server
Disconnect-VBRServer

# Check if the C:/temp directory exists, if not, create it
if (-not (Test-Path -Path 'C:\temp')) {
    New-Item -ItemType Directory -Path 'C:\temp'
}

# Export the results to a CSV file
$results | Export-Csv -Path "C:\temp\veeam_jobs.csv" -NoTypeInformation
