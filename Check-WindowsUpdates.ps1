# Check-WindowsUpdates.ps1
# Modular update checker with logging and optional install

# Ensure PSWindowsUpdate module is available
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Cyan
    Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
}

Import-Module PSWindowsUpdate

# Create log path
$logPath = "$env:USERPROFILE\OneDrive\Scripts\Logs\WindowsUpdateLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
New-Item -ItemType File -Path $logPath -Force | Out-Null

# Check for updates
Write-Host "`nChecking for Windows updates..." -ForegroundColor Yellow
$updates = Get-WindowsUpdate

# Log results
$updates | Out-File -FilePath $logPath
Write-Host "`nUpdate check complete. Results logged to:`n$logPath" -ForegroundColor Green

# Display summary
if ($updates.Count -eq 0) {
    Write-Host "`n✅ No updates available." -ForegroundColor Green
} else {
    Write-Host "`n🔔 Updates available:" -ForegroundColor Magenta
    $updates | Format-Table -Property Title, KB, Size, AutoSelectOnWebSites
}

# Optional install prompt
$install = Read-Host "`nDo you want to install these updates now? (Y/N)"
if ($install -match '^[Yy]$') {
    Write-Host "`nInstalling updates..." -ForegroundColor Cyan
    Install-WindowsUpdate -AcceptAll -AutoReboot -Verbose | Tee-Object -FilePath $logPath -Append
    Write-Host "`n✅ Updates installed. System may reboot if required." -ForegroundColor Green
} else {
    Write-Host "`n❌ Installation skipped. You can run this script again later." -ForegroundColor DarkYellow
}