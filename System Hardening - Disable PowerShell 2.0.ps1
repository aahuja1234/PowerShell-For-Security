#sets a variable to look for Powershell 2.0 versions
$check=Get-WindowsOptionalFeature -Online | Where-Object {$_.FeatureName -match "PowerShellv2"}

#uses a condition to look for PowerShell 2.0
if ($check.State -match "Enabled") {
 #Prints a message on users' screen if PowerShell 2.0 is enabled
 Write-Host "PowerShell 2.0 is enabled. Disabling PowerShell version 2.0..."
 
 #Disables PowerShell 2.0 if it was in enabled state
 Get-WindowsOptionalFeature -Online | Where-Object {$_.FeatureName -match "PowerShellv2"} | ForEach-Object {Disable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -Remove}
 Break
 }
 
# If PowerShell 2.0 is not enabled, provides a feedback to the user.
else {Write-Host "PowerShell Version 2.0 is not enabled on this system"}
