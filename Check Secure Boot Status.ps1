# Checks the Registry for Secure Boot Status
# Returns a 0 if secure boot is disabled and 1 if it is enabled
Get-ItemProperty -Path 'hklm:\System\CurrentControlSet\Control\SecureBoot\State' | Select-Object UEFISecureBootEnabled
