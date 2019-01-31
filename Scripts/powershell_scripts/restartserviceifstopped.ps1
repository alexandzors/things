# THIS IS AN OLD SCRIPT. PLEASE SEE checkservices.ps1 FOR A NEWER SCRIPT.

#This will need to be run as admin in order for it to interact with services.
$Service = Get-Service -Name 'name of service'
while ($Service.Status -ne 'Running')
{
    Start-Service $Service
    Start-Sleep -Seconds 60
    $Service.Refresh()
    if ($Service.Status -eq 'Running')
    {
        Write-Host $Service 'is now running'
    }
}