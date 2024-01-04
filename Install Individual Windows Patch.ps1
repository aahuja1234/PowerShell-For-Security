# Define the download URL for the <KB****> patch
$downloadUrl = "<LINK TO THE PATCH FILE FROM WINDOWS UPDATE CATALOG>"

# Define the path to the temporary directory to download the patch to
$tempDir = "c:\Windows\Temp"

# Download the patch to the temporary directory
$patchName = "patch.msu"
$patchPath = Join-Path $tempDir $patchName
Write-Host "Downloading patch $patchName"
Invoke-WebRequest -Uri $downloadUrl -OutFile $patchPath

# Install the patch using the Windows Update Standalone Installer
Write-Host "Installing patch $patchName"
Start-Process -FilePath "wusa.exe" -ArgumentList $patchPath,"/Verbose","/norestart" -Wait
