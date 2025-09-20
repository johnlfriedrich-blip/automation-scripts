$localScriptPath = "C:\Scripts\WSL\sync_check.sh"
if (!(Test-Path $localScriptPath)) {
    Write-Host "WSL script not found at $localScriptPath"
    exit 1
}

$wslScriptPath = "/mnt/c/Scripts/WSL/sync_check.sh"
$wslLogPath = "/mnt/c/Users/JohnFriedrich/Documents/SyncLogs/wsl_sync_log.txt"

wsl bash -c "$wslScriptPath >> $wslLogPath"

$syncLogFolder = "$env:USERPROFILE\Documents\SyncLogs"
if (!(Test-Path $syncLogFolder)) {
    New-Item -ItemType Directory -Path $syncLogFolder
}

$downloads = "$env:USERPROFILE\Downloads"
$archive = "$env:USERPROFILE\Documents\ArchivedDownloads"
$logPath = "$env:USERPROFILE\Documents\SyncLogs\sync_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Ensure archive folder exists
if (!(Test-Path $archive)) { New-Item -ItemType Directory -Path $archive }

# Archive files older than 30 days
Get-ChildItem -Path $downloads -File | Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddDays(-30)
} | ForEach-Object {
    $dest = Join-Path $archive $_.Name
    Move-Item $_.FullName $dest
    Add-Content $logPath "Archived: $($_.Name) at $(Get-Date)"
}

# Trigger WSL sync check
wsl bash -c "./sync_check.sh >> /mnt/c/Users/JohnFriedrich/Documents/SyncLogs/wsl_sync_log.txt"
