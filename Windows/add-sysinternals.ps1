Write-Host "This script checks adds SysInternals to your Windows Machine and adds them to your PATH for ease of accessibility"
Write-Host ""

# Define the URL for the Sysinternals Suite ZIP and the target directory
$sysinternalsUrl = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
$targetDir = "C:\Sysinternals"

# Create the target directory if it doesn't exist
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

# Download the Sysinternals Suite ZIP file
$zipPath = Join-Path -Path $targetDir -ChildPath "SysinternalsSuite.zip"
Invoke-WebRequest -Uri $sysinternalsUrl -OutFile $zipPath

# Extract the ZIP file
Expand-Archive -Path $zipPath -DestinationPath $targetDir -Force

# Remove the ZIP file after extraction
Remove-Item -Path $zipPath

# Function to add a new path to the system PATH environment variable if it's not already included
function Add-ToSystemPath($newPath) {
    $systemPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    if ($systemPath -notcontains $newPath) {
        $newSystemPath = $systemPath + ";" + $newPath
        [System.Environment]::SetEnvironmentVariable("Path", $newSystemPath, [System.EnvironmentVariableTarget]::Machine)
    }
}

# Add the Sysinternals directory to the system PATH environment variable
Add-ToSystemPath -newPath $targetDir

# Output a message indicating completion
Write-Host "Sysinternals Suite has been downloaded, extracted, and added to your system PATH."
Write-Host "Please restart your CLI to apply changes."
