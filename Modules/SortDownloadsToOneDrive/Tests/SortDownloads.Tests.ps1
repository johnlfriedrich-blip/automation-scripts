Import-Module "$PSScriptRoot\..\SortDownloads.psm1" -Force

$testDest = "$env:OneDrive\ArchivedDownloads\TestRun"
$testLog = "$PSScriptRoot\..\SortDownloads.log"

Invoke-SortDownloads -DestinationRoot $testDest -DryRun -UseTimestampedFolder

if (Test-Path $testLog) {
    $lines = Get-Content $testLog
    $dryRunLines = $lines | Where-Object { $_ -like "*[DryRun]*" }
    Write-Host "✅ Dry-run entries: $($dryRunLines.Count)"
} else {
    Write-Host "❌ Log file not found"
}