$sourceScripts = "C:\Scripts"
$targetScripts = "$env:OneDrive\Scripts"
$logDir = "$env:OneDrive\Documents\SyncLogs"

# Ensure target folders exist
foreach ($path in @($targetScripts, $logDir)) {
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

# Timestamped log
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath = "$logDir\backup_scripts_log_$timestamp.txt"

# Mirror scripts
robocopy $sourceScripts $targetScripts /MIR /XF "sync_probe.txt" /LOG:"$logPath"

Set-Content "$targetScripts\sync_probe.txt" -Value "Backup checkpoint: $(Get-Date)"