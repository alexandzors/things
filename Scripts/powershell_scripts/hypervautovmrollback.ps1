# This can be used to automatically roll back Hyper-V VMs to a specified checkpoint if the script detects they are shut down.

$CHECKPOINT="Insert Checkpoint Name Here"
$VMs = Get-VM | Where {$_.State -eq 'OFF'} | Select Name

ForEach($VM in $VMs)
{
    Restore-VMSnapshot -Name $CHECKPOINT -Confirm:$false -VMName $VM.name
    Start-Sleep -Seconds 30
    Start-VM $VM.name
}