# Compare-EdgeAudit.ps1
# Logs Edge background behavior, settings, and scheduled tasks

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$logFolder = "$env:USERPROFILE\Desktop\EdgeAudit_$timestamp"
New-Item -Path $logFolder -ItemType Directory -Force | Out-Null

# 1. Active Edge Processes
Get-Process | Where-Object { $_.Name -like "*msedge*" } |
    Select Name, Id, StartTime |
    Out-File "$logFolder\ActiveProcesses.txt"

# 2. Startup Boost and Background Extensions
$boostPath = "HKCU:\Software\Microsoft\Edge\StartupBoostEnabled"
$backgroundPath = "HKCU:\Software\Microsoft\Edge\BackgroundModeEnabled"

$boost = Get-ItemProperty -Path $boostPath -ErrorAction SilentlyContinue
$background = Get-ItemProperty -Path $backgroundPath -ErrorAction SilentlyContinue

"Startup Boost: $($boost.StartupBoostEnabled)" | Out-File "$logFolder\EdgeSettings.txt"
"Background Extensions: $($background.BackgroundModeEnabled)" | Add-Content "$logFolder\EdgeSettings.txt"

# 3. Sync Settings
$syncPath = "HKCU:\Software\Microsoft\Edge\Sync"
$syncStatus = Get-ItemProperty -Path $syncPath -ErrorAction SilentlyContinue
"Sync Enabled: $($syncStatus.SyncEnabled)" | Add-Content "$logFolder\EdgeSettings.txt"

# 4. Default PDF Viewer
$pdfPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf\UserChoice"
$defaultPDF = Get-ItemProperty -Path $pdfPath -ErrorAction SilentlyContinue
"Default PDF Viewer: $($defaultPDF.ProgId)" | Add-Content "$logFolder\EdgeSettings.txt"

# 5. Scheduled Tasks Related to Edge
Get-ScheduledTask | Where-Object { $_.TaskName -like "*Edge*" } |
    Select TaskName, State |
    Out-File "$logFolder\EdgeTasks.txt"

# 6. Completion Message
"Audit complete. Logs saved to: $logFolder" | Out-File "$logFolder\AuditStatus.txt"