# Purge-RecoveryKeys.ps1

$searchRoot = "$env:OneDrive\Scripts"
$pattern = "*BitLockerRecoveryKey*.txt"
$thresholdDays = 30
$cutoffDate = (Get-Date).AddDays(-$thresholdDays)

# Step 1: Find old recovery key files
$oldFiles = Get-ChildItem -Path $searchRoot -Filter $pattern -File -Recurse |
    Where-Object { $_.CreationTime -lt $cutoffDate }

if (-not $oldFiles) {
    Write-Host "✅ No recovery key files older than $thresholdDays days found."
    return
}

# Step 2: Archive before purge (optional)
$archiveName = "$searchRoot\ArchivedRecoveryKeys_$((Get-Date).ToString('yyyyMMdd_HHmmss')).zip"
Compress-Archive -Path $oldFiles.FullName -DestinationPath $archiveName
Write-Host "📦 Archived $($oldFiles.Count) files to: $archiveName"

# Step 3: Purge old files
foreach ($file in $oldFiles) {
    Remove-Item -Path $file.FullName -Force
    Write-Host "🗑️ Deleted: $($file.FullName)"
}

Write-Host "`n🧹 Purge complete. Archived and removed $($oldFiles.Count) recovery key files older than $thresholdDays days."