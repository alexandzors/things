# Created by github.com/alexandzors
# Updated 10-09-2019
$VMs = Get-VM | Where-Object {$_.State -eq 'OFF'} | Select-Object Name
Try {
    ForEach($VM in $VMs)
    {
        $Snapshot = $VM.Name | Get-VMSnapshot | Sort-Object CreationTime | Select-Object -Last 1
        Write-EventLog -LogName VMRollBack -Source HyperV -EventID 101 -EntryType Information -Message "Rolling back VM: $VM to checkpoint: $Snapshot"
        Write-Host $Snapshot.Name
        Restore-VMSnapshot -Name $Snapshot.Name -VMName $VM.name -Confirm:$false
        Start-Sleep -Seconds 30
        Start-VM $VM.name
    } 
}
Catch {
    $ErrorMsg = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-EventLog -LogName VMRollBack -Source HyperV -EventID 103 -EntryType Critical -Message "There was an exception during runtime: $ErrorMsg |||| $FailedItem"
}