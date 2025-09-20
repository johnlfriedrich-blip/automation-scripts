$onedriveRoot = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive\Accounts\Personal").UserFolder
Write-Host "OneDrive sync root: $onedriveRoot"