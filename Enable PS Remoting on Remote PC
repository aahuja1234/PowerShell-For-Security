<#

.SYNOPSIS

Enables PowerShell Remoting on a remote computer. Requires that the machine
responds to WMI requests, and that its operating system is Windows Vista or
later.

.EXAMPLE

PS > Enable-RemotePsRemoting <Computer>

#>

param(
    ## The computer on which to enable remoting
    $Computername,

    [Switch] $SkipNetworkProfileCheck,

    ## The credential to use when connecting
    [PSCredential] $Credential
)

$Computername = "<enter computer name>"
$Credential = "<enter username>"

Set-StrictMode -Version 3

$VerbosePreference = "Continue"

Write-Verbose "Configuring $computername"
$skipNetworkProfileCheckFlag = '$' + $SkipNetworkProfileCheck.IsPresent
$command = "powershell -NoProfile -Command" +
    "Enable-PSRemoting -SkipNetworkProfileCheck:$skipNetworkProfileCheckFlag -Force"

if($Credential)
{
    $null = Invoke-WmiMethod -Computer $computername -Credential $credential `
        Win32_Process Create -Args $command

    Start-Sleep -Seconds 10

    Write-Verbose "Testing connection"
    Invoke-Command $computername {
        Get-WmiObject Win32_ComputerSystem } -Credential $credential
}
else {
    $null = Invoke-WmiMethod -Computer $computername Win32_Process Create -Args $command
    Start-Sleep -Seconds 10

    Write-Verbose "Testing connection"
    Invoke-Command $computername { Get-WmiObject Win32_ComputerSystem }
}
