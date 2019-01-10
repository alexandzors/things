#This can be used in conjunction with the hypervautovmrollback.ps1 

$Process = Get-Process INSERTPROCESSNAMEHERE
if ($Process -ne $null)
{
    <#This loop waits for the specfied process to end before continuing.#>
    Write-Host "Waiting for $Process to close.."
    Start-Sleep -Seconds 20
}
Write-Host "4 minute timeout till system shutdown."
Start-Sleep -Seconds 240 <#Change this amount to whatever you want. Default is 240 seconds i.e. 4 minutes.#>
Stop-Computer