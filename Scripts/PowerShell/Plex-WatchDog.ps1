# Created by github.com/alexandzors
# Updated 11-19-2019
$HTTP_Request = [System.Net.WebRequest]::Create('http://localhost:32400/web/index.html')
$HTTP_Request.Timeout = 15000
$HTTP_Response = try {$HTTP_Request.GetResponse()} catch {"Webpage Timeout"}
$HTTP_Status = try {[int]$HTTP_Response.StatusCode} catch {"Webpage Timeout"}
#Create a discord webhook for your status channel and paste it between the single quotes:
$WebHookURL = ''
#Fill in your offline message between the @"@":
$MessageBody1 = @"

"@
#Fill in your online message between the @"@":
$MessageBody2 = @"

"@
[System.Collections.ArrayList]$embedArray = @()
[System.Collections.ArrayList]$embedArray2 = @()
#Embed object for offline message. You can add more embed fields as well as change the embed highlight color/add icons:
$embedObject1 = [PSCustomObject]@{
    color = 'c40404'
    title = 'Server Status'
    description = $MessageBody1
}
#Embed object for online message. You can add more embed fields as well as change the embed highlight color/add icons:
$embedObject2 = [PSCustomObject]@{
    color = '4289797'
    title = 'Server Status'
    description = $MessageBody2
}
$PayLoad = [PSCustomObject]@{
    embeds = $embedArray2
}
$PayLoad2 = [PSCustomObject]@{
    embeds = $embedArray
}
$embedArray.Add($embedObject1)
$embedArray.Add($embedObject2)
try {
If ($HTTP_Status -eq 200) { 
    Write-Host "Plex is currently responding.. Sleeping for 15 minutes.."
    Invoke-RestMethod -Uri $WebHookURL -Body ($PayLoad2 | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'
    Write-EventLog -LogName PlexWatchDog -Source Plex -EventID 100 -EntryType Information -Message 'Plex is currently responding.. Sleeping for 15 minutes..' 
    }
Else {
    write-host "Plex is currently not responding! Restarting plex service..."
    Invoke-RestMethod -Uri $WebHookURL -Body ($PayLoad | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'
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