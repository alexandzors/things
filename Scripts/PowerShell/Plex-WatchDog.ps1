# Created by github.com/alexandzors
# Updated 10-09-2019
$HTTP_Request = [System.Net.WebRequest]::Create('http://localhost:32400/web/index.html')
$HTTP_Request.Timeout = 15000
$HTTP_Response = try {$HTTP_Request.GetResponse()} catch {"Webpage Timeout"}
$HTTP_Status = try {[int]$HTTP_Response.StatusCode} catch {"Webpage Timeout"}
try {
If ($HTTP_Status -eq 200) { 
Write-Host "Plex is currently responding.. Sleeping for 15 minutes.."
Write-EventLog -LogName PlexWatchDog -Source Plex -EventID 100 -EntryType Information -Message 'Plex is currently responding.. Sleeping for 15 minutes..' 
}
Else {
write-host "Plex is currently not responding! Restarting plex service...";
Write-EventLog -LogName PlexWatchDog -Source Plex -EventID 101 -EntryType Warning -Message 'Plex is currently not responding! Checking for update serivce. If service is not running then restarting Plex Media Server...'
$UpdateCheck = Get-Process "Plex Update Service" -ErrorAction SilentlyContinue
If ($null -eq $UpdateCheck) {
Stop-Process -processname "Plex*"; Start-Process 'C:\Program Files (x86)\Plex\Plex Media Server\Plex Media Server.exe' -WorkingDirectory "C:\Program Files (x86)\Plex\Plex Media Server\" ; Start-Sleep -Seconds 5
}
Else {
Write-EventLog -LogName PlexWatchDog -Source Plex -EventID 102 -EntryType Warning -Message 'Plex Update Service is running... Sleeping for 15 minutes...'
} 
}
}
catch {
$ErrorMessage = $_.Exception.Message
Write-EventLog -LogName PlexWatchDog -Source Plex -EventId 103 -EntryType Error -Message $ErrorMessage
}