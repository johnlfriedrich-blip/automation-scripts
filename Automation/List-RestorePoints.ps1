# List-RestorePoints.ps1

function Write-RestoreAudit {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logPath = "$PSScriptRoot\RestorePoints_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Add-Content -Path $logPath -Value "$timestamp - $Message"
    Write-Host $Message
}

function Get-SystemRestorePoints {
    $restorePoints = Get-ComputerRestorePoint | Sort-Object CreationTime -Descending

    if (-not $restorePoints) {
        Write-RestoreAudit "⚠️ No restore points found."
        return
    }

    Write-RestoreAudit "🧾 Restore Point Summary:`n"

    foreach ($rp in $restorePoints) {
        $entry = "ID: $($rp.SequenceNumber) | Type: $($rp.Description) | Created: $($rp.CreationTime)"
        Write-RestoreAudit $entry
    }
}

# Run the module
Get-SystemRestorePoints