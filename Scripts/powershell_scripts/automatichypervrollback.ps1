# This script automatically rolls back a Hyper-V VM to the most recent checkpoint if it is powered off. Recommend using this with Task Scheduler.

$VMs = Get-VM | Where {$_.State -eq 'OFF'} | Select Name

ForEach($VM in $VMs)
{
    $Snapshot = $VM.Name | Get-VMSnapshot | Sort CreationTime | Select -Last 1
    Write-Host $Snapshot.Name
    Restore-VMSnapshot -Name $Snapshot.Name -VMName $VM.name -Confirm:$false
    Start-Sleep -Seconds 30
    Start-VM $VM.name
}