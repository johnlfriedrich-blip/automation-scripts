# Set working directory
Set-Location "$env:OneDrive\Scripts"

# Log setup
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$logPath = "$env:OneDrive\Scripts\GitRoutineLog_$timestamp.txt"
"[$(Get-Date)] Starting Git routine..." | Out-File $logPath

# Placeholder registry
$placeholders = @(
    "Modules/ArchiveDownloads.ps1",
    "Modules/LogSummary.ps1",
    "Modules/ValidateSync.ps1"
)

# Step 1: Restore missing placeholders
foreach ($file in $placeholders) {
    $fullPath = Join-Path $PWD $file
    if (-not (Test-Path $fullPath)) {
        "[$(Get-Date)] MISSING: $file — recreating zero-byte placeholder." | Out-File $logPath -Append
        New-Item $fullPath -ItemType File | Out-Null
    }
}

# Step 2: Pin placeholders locally
foreach ($file in $placeholders) {
    $fullPath = Join-Path $PWD $file
    attrib -P +U $fullPath  # Pin file locally
}

# Step 3: Git status audit
$gitStatus = git status --porcelain
$deletions = $gitStatus | Where-Object { $_ -match "^ D " }

# Step 4: Block deletion of placeholders
$flagged = @()
foreach ($line in $deletions) {
    $deletedFile = $line -replace "^ D\s+", ""
    if ($placeholders -contains $deletedFile) {
        $flagged += $deletedFile
    }
}

if ($flagged.Count -gt 0) {
    "[$(Get-Date)] BLOCKED: Git attempted to delete placeholder files:" | Out-File $logPath -Append
    $flagged | Out-File $logPath -Append
    Write-Host "`n⚠️ Git attempted to delete placeholder files:`n$($flagged -join "`n")"
    $confirm = Read-Host "Do you want to override and allow deletion? (y/n)"
    if ($confirm -ne 'y') {
        "[$(Get-Date)] Git deletion aborted by user." | Out-File $logPath -Append
        exit
    }
}

# Step 5: Stage and commit
git add .
git commit -m "Daily sync $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

# Step 6: Validate remote and upstream
$remoteUrl = git remote get-url origin
if (-not $remoteUrl) {
    Write-Host "`n❌ No remote 'origin' found. Please add one:"
    Write-Host "git remote add origin https://github.com/<your-username>/<repo>.git"
    exit
}

$branch = git rev-parse --abbrev-ref HEAD
$tracking = git rev-parse --symbolic-full-name --verify --quiet "@{u}"

if (-not $tracking) {
    Write-Host "`n🔗 No upstream set for '$branch'. Linking to origin/$branch..."
    git push --set-upstream origin $branch
} else {
    git push
}

"[$(Get-Date)] Git routine completed." | Out-File $logPath -Append