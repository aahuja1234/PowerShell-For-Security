# Import the Active Directory module if not already loaded
Import-Module ActiveDirectory

# Get the current date
$today = Get-Date

# Define the threshold for disabled days (360 days)
$threshold = (Get-Date).AddDays(-360)

# Get disabled users that were disabled more than 90 days ago
$disabledUsers = Get-ADUser -Filter {Enabled -eq $false -and whenChanged -le $threshold} -Properties whenChanged

# Display the results
$disabledUsers | Select-Object Name, SamAccountName, Enabled, whenChanged | Format-Table -AutoSize
$disabledUsers | Select-Object Name, SamAccountName, Enabled, whenChanged | Export-Csv -Path "C:\DisabledMoreThan360DaysAgo.csv" -NoTypeInformation