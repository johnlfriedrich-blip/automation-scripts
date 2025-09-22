# Audit-RecoveryKeys.ps1

$searchRoot = "$env:OneDrive\Scripts"
$pattern = "*BitLockerRecoveryKey*.txt"

# Step 1: Find all matching files
$files = Get-ChildItem -Path $searchRoot -Filter $pattern -File -Recurse |
    Sort-Object CreationTime -Descending

if (-not $files) {
    Write-Host "⚠️ No recovery key files found in $searchRoot"
    return
}

# Step 2: Display audit summary
Write-Host "`n🧾 Recovery Key Audit Summary:`n"
foreach ($file in $files) {
    $created = $file.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "📄 $($file.Name) — Created: $created"
}

# Step 3: Optional purge logic
$thresholdDays = 30
$cutoffDate = (Get-Date).AddDays(-$thresholdDays)

$oldFiles = $files | Where-Object { $_.CreationTime -lt $cutoffDate }

if ($oldFiles.Count -gt 0) {
    Write-Host "`n🧹 Found $($oldFiles.Count) recovery key files older than $thresholdDays days:"
    foreach ($file in $oldFiles) {
        Write-Host "🗑️ $($file.FullName)"
        # Uncomment below to actually delete
        # Remove-Item -Path $file.FullName -Force
    }
} else {
    Write-Host "`n✅ No recovery key files older than $thresholdDays days."
}