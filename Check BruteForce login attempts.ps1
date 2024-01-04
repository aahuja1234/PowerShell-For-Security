#Requires -Version 5.1

<#
.SYNOPSIS
    Condition for helping detect brute force login attempts.
.DESCRIPTION
    Condition for helping detect brute force login attempts.
.EXAMPLE
     -Hours 10
    Number of hours back in time to look through in the event log.
    Default is 1 hour.
.EXAMPLE
    -Attempts 100
    Number of login attempts to trigger at or above this number.
    Default is 8 attempts.
.OUTPUTS
    PSCustomObject[]
.NOTES
    Minimum OS Architecture Supported: Windows 10, Windows Server 2016
    Release Notes:
    Initial Release
#>

[CmdletBinding()]
param (
    [Parameter()]
    [int]
    $Hours = 168,
    [Parameter()]
    [int]
    $Attempts = 5
)

begin {
    function Test-IsElevated {
        $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $p = New-Object System.Security.Principal.WindowsPrincipal($id)
        $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    function Test-StringEmpty {
        param([string]$Text)
        # Returns true if string is empty, null, or whitespace
        process { [string]::IsNullOrEmpty($Text) -or [string]::IsNullOrWhiteSpace($Text) }
    }
    if (-not $(Test-StringEmpty -Text $env:Hours)) {
        $Hours = $env:Hours
    }
    if (-not $(Test-StringEmpty -Text $env:Attempts)) {
        $Attempts = $env:Attempts
    }
}
process {
    if (-not (Test-IsElevated)) {
        Write-Error -Message "Access Denied. Please run with Administrator privileges."
        exit 1
    }

    if ($(auditpol.exe /get /category:* | Where-Object { $_ -like "*Logon*Success and Failure" })) {
        Write-Information "Audit Policy for Logon is set to: Success and Failure"
    }
    else {
        Write-Error "Audit Policy for Logon is NOT set to: Success and Failure"
        exit 1
        # Write-Host "Setting Logon to: Success and Failure"
        # auditpol.exe /set /subcategory:"Logon" /success:enable /failure:enable
        # Write-Host "Future failed login attempts will be captured."
    }

    $StartTime = (Get-Date).AddHours(0 - $Hours)
    $EventId = 4625

    # Get failed login attempts
    try {
        $Events = Get-WinEvent -FilterHashtable @{LogName = "Security"; ID = $EventId; StartTime = $StartTime } -ErrorAction Stop | ForEach-Object {
            $Message = $_.Message -split [System.Environment]::NewLine
            $Account = $($Message | Where-Object { $_ -Like "*Account Name:*" }) -split '\s+' | Select-Object -Last 1
            [int]$LogonType = $($Message | Where-Object { $_ -Like "Logon Type:*" }) -split '\s+' | Select-Object -Last 1
            $SourceNetworkAddress = $($Message | Where-Object { $_ -Like "*Source Network Address:*" }) -split '\s+' | Select-Object -Last 1
            [PSCustomObject]@{
                Account              = $Account
                LogonType            = $LogonType
                SourceNetworkAddress = $SourceNetworkAddress
            }
        } | Where-Object { $_.LogonType -in @(2, 7, 10) }
    }
    catch {
        if ($_.Exception.Message -like "No events were found that match the specified selection criteria.") {
            Write-Host "No failed logins found in the past $Hours hour(s)."
            exit 0
        }
        else {
            Write-Error $_
            exit 1
        }
    }

    # Build a list of accounts 
    $UsersAccounts = [System.Collections.Generic.List[String]]::new()
    try {
        $ErrorActionPreference = "Stop"
        Get-LocalUser | Select-Object -ExpandProperty Name | ForEach-Object { $UsersAccounts.Add($_) }
        $ErrorActionPreference = "Continue"
    }
    catch {
        $NetUser = net.exe user
        $(
            $NetUser | Select-Object -Skip 4 | Select-Object -SkipLast 2
            # Join each line with a ","
            # Replace and spaces with a ","
            # Split everything by ","
        ) -join ',' -replace '\s+', ',' -split ',' |
            # Sort and remove any duplicates
            Sort-Object -Descending -Unique |
            # Filter out empty strings
            Where-Object { -not [string]::IsNullOrEmpty($_) -and -not [string]::IsNullOrWhiteSpace($_) } |
            ForEach-Object {
                $UsersAccounts.Add($_)
            }
    }
    $Events | Select-Object -ExpandProperty Account | ForEach-Object { $UsersAccounts.Add($_) }

    $Results = $UsersAccounts | Select-Object -Unique | ForEach-Object {
        $Account = $_
        $AccountEvents = $Events | Where-Object { $_.Account -like $Account }
        $AttemptCount = $AccountEvents.Count
        $SourceNetworkAddress = $AccountEvents | Select-Object -ExpandProperty SourceNetworkAddress -Unique
        if ($AttemptCount -gt 0) {
            [PSCustomObject]@{
                Account              = $Account
                Attempts             = $AttemptCount
                SourceNetworkAddress = $SourceNetworkAddress
            }
        }
    }

    # Get only the accounts with fail login attempts at or over $Attempts
    $BruteForceAttempts = $Results | Where-Object { $_.Attempts -ge $Attempts }
    if ($BruteForceAttempts) {
        $BruteForceAttempts | Out-String | Write-Host
        exit 1
    }
    $Results | Out-String | Write-Host
    exit 0
}
end {
    $ScriptVariables = @(
        [PSCustomObject]@{
            name           = "Hours"
            calculatedName = "hours" # Must be lowercase and no spaces
            required       = $false
            defaultValue   = [PSCustomObject]@{ # If not default value, then remove
                type  = "TEXT"
                value = "1"
            }
            valueType      = "TEXT"
            valueList      = $null
            description    = "Number of hours back in time to look through in the event log."
        }
        [PSCustomObject]@{
            name           = "Attempts"
            calculatedName = "attempts" # Must be lowercase and no spaces
            required       = $false
            defaultValue   = [PSCustomObject]@{ # If not default value, then remove
                type  = "TEXT"
                value = "8"
            }
            valueType      = "TEXT"
            valueList      = $null
            description    = "Number of login attempts to trigger at or above this number."
        }
    )
}
