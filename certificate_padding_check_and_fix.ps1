﻿## Created by Akash Ahuja

## Naming a variable to check if the registry exists
$EnableCertPaddingCheck = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Cryptography\Wintrust\Config" -Name "EnableCertPaddingCheck" -ErrorAction SilentlyContinue).EnableCertPaddingCheck

#Checking availability of the variable.If the registry does not exist or DWORD is not found, creating
if (-not $EnableCertPaddingCheck -or $EnableCertPaddingCheck -eq 0) {Write-Output "Certificate Padding not Enabled.. Device is vulnerable to cve-2013-3900.. Applying Fix..."
  New-ItemProperty -Path "HKLM:\Software\Microsoft\Cryptography\Wintrust\Config" -Name "EnableCertPaddingCheck" -PropertyType DWORD -Value 1 -Force
  New-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config" -Name "EnableCertPaddingCheck" -PropertyType DWORD -Value 1 -Force
  }

Write-Output "Certificate Padding Vulnerability Fixed.. Thank you for using Akash's Vulnerability Management Automation!"