Write-EventLog -LogName PlexWatchDog -Source Plex -EventId 97 -EntryType Information -Message "Beginning Plex Directory Folder Cleanup.."
Get-ChildItem 'P:\Plex Media Server\Updates' -Directory | Sort-Object CreationTime -Descending | Select-Object -Skip 1 | ForEach-Object {
    $file = $_
    try {
        Remove-Item $file.FullName -Recurse -Force
    } catch {
        $ErrorMessage = $_.Exception.Message
        Write-EventLog -LogName PlexWatchDog -Source Plex -EventId 99 -EntryType Error -Message $ErrorMessage
    }}
    Write-EventLog -LogName PlexWatchDog -Source Plex -EventId 98 -EntryType SuccessAudit -Message "Plex Directory Cleanup Complete!"