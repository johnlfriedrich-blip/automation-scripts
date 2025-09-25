# Audit-SystemHealth.ps1
# Checks BitLocker status, recovery key presence, and Windows updates
# Logs results to OneDrive\Scripts\Logs

# Ensure PSWindowsUpdate is available
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Cyan
    Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
}
Import-Module PSWindowsUpdate

# Create log path
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$logPath = "$env:USERPROFILE\OneDrive\Scripts\Logs\SystemHealth_$timestamp.txt"
New-Item -ItemType File -Path $logPath -Force | Out-Null

# --- BitLocker Audit ---
Write-Host "`n🔐 Checking BitLocker status..." -ForegroundColor Yellow
$bitlockerStatus = Get-BitLockerVolume

foreach ($vol in $bitlockerStatus) {
    $volInfo = @"
Drive: $($vol.VolumeLetter)
Protection Status: $($vol.ProtectionStatus)
Encryption Method: $($vol.EncryptionMethod)
Key Protectors: $($vol.KeyProtector)
Auto Unlock Enabled: $($vol.AutoUnlockEnabled)
"@
    $volInfo | Out-File -FilePath $logPath -Append
    Write-Host $volInfo -ForegroundColor Cyan
}

# --- Recovery Key Check ---
Write-Host "`n🔑 Checking for recovery key backups..." -ForegroundColor Yellow
$recoveryKeyPath = "$env:USERPROFILE\OneDrive\Documents\BitLockerKeys"
$vaultPath = "$env:USERPROFILE\OneDrive\PersonalVault"

$recoveryKeyFound = Test-Path $recoveryKeyPath -or Test-Path $vaultPath
$recoveryStatus = if ($recoveryKeyFound) { "✅ Recovery key backup found." } else { "❌ No recovery key backup detected." }

$recoveryStatus | Out-File -FilePath $logPath -Append
Write-Host $recoveryStatus -ForegroundColor ($recoveryKeyFound ? "Green" : "Red")

# --- Windows Update Audit ---
Write-Host "`n📦 Checking for Windows updates..." -ForegroundColor Yellow
$updates = Get-WindowsUpdate
$updates | Out-File -FilePath $logPath -Append

if ($updates.Count -eq 0) {
    Write-Host "✅ No updates available." -ForegroundColor Green
} else {
    Write-Host "🔔 Updates available:" -ForegroundColor Magenta
    $updates | Format-Table -Property Title, KB, Size, AutoSelectOnWebSites
}

# --- Optional Install Prompt ---
$install = Read-Host "`nDo you want to install these updates now? (Y/N)"
if ($install -match '^[Yy]$') {
    Write-Host "`nInstalling updates..." -ForegroundColor Cyan
    Install-WindowsUpdate -AcceptAll -AutoReboot -Verbose | Tee-Object -FilePath $logPath -Append
    Write-Host "`n✅ Updates installed. System may reboot if required." -ForegroundColor Green
} else {
    Write-Host "`n❌ Installation skipped. You can run this script again later." -ForegroundColor DarkYellow
}

# --- Final Log Summary ---
Write-Host "`n📄 Full audit log saved to:`n$logPath" -ForegroundColor Blue