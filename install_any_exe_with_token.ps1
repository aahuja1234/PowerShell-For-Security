# Define the URL of the EXE installer and license key
$installerUrl = "https://example.com/path/to/installer.exe"
$licenseKey = "YOUR_LICENSE_KEY_HERE"

# Define the temporary folder path
$tempFolder = "C:\temp_install"

# Define the path to save the installer
$installerPath = Join-Path $tempFolder "installer.exe"

# Define the path for the log file
$logFilePath = Join-Path $tempFolder "install_log.txt"

# Create the temporary folder
New-Item -ItemType Directory -Path $tempFolder | Out-Null

# Download the EXE installer
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Construct the command to run the installer with parameters (if needed)
$installerCommand = "$installerPath /silent /licensekey:$licenseKey"

# Start the installation process
Start-Process -FilePath $installerCommand -Wait

# Remove the temporary folder and all its contents
Remove-Item -Path $tempFolder -Recurse -Force