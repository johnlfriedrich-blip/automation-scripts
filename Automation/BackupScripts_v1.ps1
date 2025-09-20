$logDir = "$env:OneDrive\Documents\SyncLogs"
if (!(Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$sourceScripts = "$env:USERPROFILE\Scripts"
$targetScripts = "$env:OneDrive\Scripts"

$sourceLogs = "$env:USERPROFILE\Documents\SyncLogs"
$targetLogs = "$env:OneDrive\Documents\SyncLogs"

# Mirror Scripts
robocopy $sourceScripts $targetScripts /MIR /LOG:"$targetLogs\backup_scripts_log.txt"

# Mirror Logs
robocopy $sourceLogs $targetLogs /MIR /LOG:"$targetLogs\backup_logs_log.txt"

robocopy "C:\Users\JohnFriedrich\Scripts" "C:\Users\JohnFriedrich\OneDrive\Scripts" /MIR /LOG:"C:\Users\JohnFriedrich\OneDrive\Documents\SyncLogs\backup_scripts_log.txt"

$probeDir = "$env:OneDrive\Scripts"
if (!(Test-Path $probeDir)) {
    New-Item -ItemType Directory -Path $probeDir | Out-Null
}
Set-Content "$probeDir\sync_probe.txt" -Value "Backup checkpoint: $(Get-Date)"
