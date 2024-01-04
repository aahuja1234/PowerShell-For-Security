##This script shows all software installed on a given system along with the dates that they were installed.
Get-WinEvent -ProviderName msiinstaller | where id -eq 1033 | select timecreated,message | FL *
