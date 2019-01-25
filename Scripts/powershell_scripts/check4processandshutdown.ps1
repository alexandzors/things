#This script waits for a process to exit before shutting down the host. You can change $TIMEOUT to any value you'd like in seconds. It checks every 10 seconds for the process exit.
$Aproc = "ProcessName"
$TIMEOUT = 240
$process = Get-Process | Where-Object {$_.ProcessName -eq $Aproc}
while ($true)
{
    while (!($process))
    {
        $process = Get-Process | Where-Object {$_.ProcessName -eq $Aproc}
        Start-Sleep -Seconds 10 <# Change this value if you want it to take longer or shorter to check. #>
    }
    if ($process)
    {
        $process.WaitForExit()
        Start-Sleep -Seconds 2 
        $process = Get-Process | Where-Object {$_.ProcessName -eq $Aproc}
        Write-Host "$Aproc has closed, 4 minutes to shutdown."
        Start-Sleep -Seconds $TIMEOUT
        Stop-Computer
    }
}