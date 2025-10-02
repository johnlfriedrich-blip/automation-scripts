function Invoke-SortDownloads {
    [CmdletBinding()]
    param (
        [string]$Source = "$env:USERPROFILE\Downloads",
        [string]$DestinationRoot = "$env:OneDrive\ArchivedDownloads",
        [switch]$UseTimestampedFolder,
        [switch]$DryRun
    )

    $logPath = Join-Path $PSScriptRoot "SortDownloads.log"
    if (!(Test-Path $logPath)) {
        New-Item -Path $logPath -ItemType File -Force | Out-Null
        Add-Content -Path $logPath -Value "$(Get-Date): Log file created"
    }

    $destination = if ($UseTimestampedFolder) {
        $timestamp = Get-Date -Format "yyyy-MM-dd"
        Join-Path $DestinationRoot $timestamp
    } else {
        $DestinationRoot
    }

    if (!(Test-Path $destination)) {
        New-Item -Path $destination -ItemType Directory -Force | Out-Null
        Add-Content -Path $logPath -Value "$(Get-Date): Created folder $destination"
    }

    Add-Content -Path $logPath -Value "$(Get-Date): Script started"

    $includeExtensions = @(".pdf", ".docx", ".xlsx", ".zip", ".txt", ".pptx")
    $excludeExtensions = @(".exe", ".msi", ".iso", ".bat", ".cmd")

    $moved = 0; $skipped = 0; $errors = 0

    Get-ChildItem -Path $Source -File | ForEach-Object {
        $ext = $_.Extension.ToLower()
        if ($includeExtensions -contains $ext -and -not ($excludeExtensions -contains $ext)) {
            $target = Join-Path $destination $_.Name
            $meta = "Size: $($_.Length) bytes, Created: $($_.CreationTime), Modified: $($_.LastWriteTime)"
            if ($DryRun) {
                Add-Content -Path $logPath -Value "$(Get-Date): [DryRun] Would move $($_.Name) [$meta]"
            } else {
                try {
                    Move-Item $_.FullName -Destination $target -Force
                    Add-Content -Path $logPath -Value "$(Get-Date): Moved $($_.Name) [$meta]"
                    $moved++
                } catch {
                    Add-Content -Path $logPath -Value "$(Get-Date): Error moving $($_.Name): $($_.Exception.Message)"
                    $errors++
                }
            }
        } else {
            Add-Content -Path $logPath -Value "$(Get-Date): Skipped $($_.Name)"
            $skipped++
        }
    }

    Add-Content -Path $logPath -Value "$(Get-Date): Summary - Moved: $moved, Skipped: $skipped, Errors: $errors"
    Add-Content -Path $logPath -Value "$(Get-Date): Script completed"
}
Export-ModuleMember -Function Invoke-SortDownloads