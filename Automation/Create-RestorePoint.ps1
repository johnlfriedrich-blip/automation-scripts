# Create-RestorePoint.ps1

function Write-RestoreLog {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logPath = "$PSScriptRoot\RestoreAudit_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Add-Content -Path $logPath -Value "$timestamp - $Message"
    Write-Host $Message
}

function New-SystemRestorePoint {
    $description = "Pre-change snapshot - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    Write-RestoreLog "Creating restore point: $description"

    $result = Checkpoint-Computer -Description $description -RestorePointType "MODIFY_SETTINGS"

    if ($null -eq $result) {
        Write-RestoreLog "✅ Restore point created successfully."
    } else {
        Write-RestoreLog "⚠️ Restore point creation returned: $result"
    }
}

# Run the module
New-SystemRestorePoint