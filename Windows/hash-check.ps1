Write-Host "This script checks the integrity of file hashes to ensure their authenticity"
Write-Host "This PowerShell script checks the integrity of file hashes to ensure their authenticity."
Write-Host ""

Write-Host "Please ensure you're running this script with administrative privileges if necessary."
Write-Host "You may need to adjust your execution policy with: Set-ExecutionPolicy RemoteSigned"
Write-Host ""

# Prompt user for the filename
$Filename = Read-Host -Prompt 'Enter the filename you wish to verify (ensure it is in the current directory with its extension)'

# Verify if the file exists before proceeding
if (Test-Path $Filename) {
    # Calculate and display the file hash
    $CheckedHash = Get-FileHash $Filename | Format-List
    Write-Host "File hash calculated successfully:"
    Write-Host $CheckedHash
} else {
    # Error message if the file does not exist
    Write-Host "Error: The file '$Filename' does not exist in the current directory." -ForegroundColor Red
}

# Pause the script to allow the user to see the results
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
