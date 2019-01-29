# This can be used with task scheduler to automatically restart a service every few minutes if it shuts off. This does not auto detect the service status until it is run. 
# aka no watchdog
# Service name needs to be what is displayed in the service properties window. IT IS CASE SENSITIVE!
# Some services require Admin priviledges to start. So I recommend running this with " Run with highest privileges" checked in task scheduler.

$ServiceName = 'ENTER SERVICE NAME HERE'
$Service = Get-Service -Name $ServiceName
write-host $Service "is not running"
while ($Service.Status -ne 'Running')
{
    Start-Service $Service
    Start-Sleep -Seconds 30
    $Service.Refresh()
    if ($Service.Status -eq 'Running')
    {
        Write-Host $Service 'is now running'
        Exit
    }
}