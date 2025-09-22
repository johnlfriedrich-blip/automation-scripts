$bitlockerVolume = Get-BitLockerVolume -MountPoint "C:"
$recoveryProtector = $bitlockerVolume.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }

$identifier = $recoveryProtector.KeyProtectorId
$recoveryKey = $recoveryProtector.RecoveryPassword

$output = @"
BitLocker Recovery Key Backup
Identifier: $identifier
Recovery Key: $recoveryKey
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@

Set-Content -Path "$env:OneDrive\Scripts\BitLockerRecoveryKey.txt" -Value $output