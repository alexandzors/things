echo
cd /d %windir%/system32
takeown /f musnotification.exe
icacls musnotification.exe /deny Everyone:(X)
takeown /f musnotificationux.exe
icacls musnotificationux.exe /deny Everyone:(X)
pause