# Set working directory
Set-Location "$env:OneDrive"

# Log setup
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$logPath = "$env:OneDrive\HydrationAuditLog_$timestamp.txt"
"[$(Get-Date)] Starting OneDrive hydration audit..." | Out-File $logPath

# Scan all files recursively
$files = Get-ChildItem -Recurse -File

# Categorize
$cloudOnly = $files | Where-Object { $_.Attributes -match "Offline" }
$hydrated   = $files | Where-Object { $_.Attributes -notmatch "Offline" }

# Log results
"[$(Get-Date)] Cloud-only files:" | Out-File $logPath -Append
$cloudOnly.FullName | Out-File $logPath -Append

"[$(Get-Date)] Hydrated files:" | Out-File $logPath -Append
$hydrated.FullName | Out-File $logPath -Append

# Summary
$cloudCount = $cloudOnly.Count
$hydratedCount = $hydrated.Count
$total = $files.Count

Write-Host "`n📊 Hydration Summary:"
Write-Host "  Total files scanned: $total"
Write-Host "  Hydrated (local):    $hydratedCount"
Write-Host "  Cloud-only:          $cloudCount"
Write-Host "`n📁 Log saved to: $logPath"