### This directory includes useful PowerShell scripts 
as well as supporting files

---
# Clean-Plex-Data-Directory.ps1
This script cleans junk files out of the plex data directory to reduce bloat. Currently cleans out the "Updates" folder while leaving the most recent installer file.

This script writes to the same Event Log as `Plex-Watchdog.ps1`.

---
# Mount-Media-Directory.ps1
This script mounts a media directory at login. This is useful for when Windows does not automatically reconnect to the shared drive after boot.

# Mount-Plex-Media-Directory.ps1
Same as above but set for a directory named Plex.

---
# Plex-Watchdog.ps1
Invoked by `Plex-Watchdog-Invoker.vbs`. This script checks to see if Plex is running by querying the plex web UI for the local server. If it returns a HTTP 500 error (aka a timeout) the script will automatically terminate the `Plex Media Server` service as well as any associated child services. It will then attempt to restart the `Plex Media Server` service executable. 

This script also checks for the `Plex Media Server Update` process. If detected it will return to a sleep state.

This script writes to the Windows Event log under Event Viewer > Applications > PlexWatchDog.

Please run `New-EventLog -source Plex -LogName PlexWatchDog` in an elevated PowerShell session before running this script!

***Note:*** `Plex-Watchdog-Invoker.vbs`, and `Plex-Watchdog.ps1` must be in the same directory!

## Plex-WatchDog-Invoker.vbs
Used to invoke the Plex-Watchdog.ps1 script. Allows the script to run without a UI popup.

## Plex-Watchdog-Task.xml
XML file that can be imported into Windows Task Scheduler to automatically run the Plex-Watchdog-Invoker.vbs script.

---
# HyperV-Rollback.ps1
Automatically rolls back VMs to their latest checkpoints after being shutdown. Useful for automated tasks.

You will need to run `New-EventLog -LogName VMRollBack -Source HyperV` in an elevated PowerShell session for the Event logging to work!

***Note:*** This script can be edited to exclude VMs by checking the returned name against an Array of excluded VMs to skip!

## HyperV-Rollback.xml
This file is for importing into Windows Task Scheduler.

***Note:*** This task requires a privileged session in order for it to interact with the HyperV management services!

---
# ServiceChecking.ps1
Can check and restart any number of defined services.

***Note:*** Must be run with elevated privileges.