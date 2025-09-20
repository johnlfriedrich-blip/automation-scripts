# Define source and destination paths
$source = "$env:USERPROFILE\Downloads"
$destination = "$env:USERPROFILE\Documents\ArchivedDownloads"
$logPath = "C:\Scripts\Automation\SortDownloads.log"

# Create destination folder if it doesn't exist
if (!(Test-Path $destination)) {
    New-Item -Path $destination -ItemType Directory
    Add-Content -Path $logPath -Value "$(Get-Date): Created ArchivedDownloads folder"
}

# Start logging
Add-Content -Path $logPath -Value "$(Get-Date): Script started"

# Define file types to include and exclude
$includeExtensions = @(".pdf", ".docx", ".xlsx", ".zip", ".txt", ".pptx")
$excludeExtensions = @(".exe", ".msi", ".iso", ".bat", ".cmd")

# Scan and process files
Get-ChildItem -Path $source -File | ForEach-Object {
    $ext = $_.Extension.ToLower()
    if ($includeExtensions -contains $ext -and -not ($excludeExtensions -contains $ext)) {
        $target = Join-Path $destination $_.Name
        try {
            Move-Item $_.FullName -Destination $target -Force
            Add-Content -Path $logPath -Value "$(Get-Date): Moved $($_.Name)"
        } catch {
            Add-Content -Path $logPath -Value "$(Get-Date): Error moving $($_.Name): $($_.Exception.Message)"
        }
    } else {
        Add-Content -Path $logPath -Value "$(Get-Date): Skipped $($_.Name)"
    }
}

# End logging
Add-Content -Path $logPath -Value "$(Get-Date): Script completed"