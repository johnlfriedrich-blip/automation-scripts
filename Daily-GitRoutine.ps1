# Daily-GitRoutine.ps1 — Modular Git Routine for Audit-Ready Workflows

$repoPath = "$env:USERPROFILE\OneDrive\Scripts"
Set-Location $repoPath

Write-Host "`n🔄 Syncing with origin..." -ForegroundColor Cyan
git pull --rebase

Write-Host "`n📋 Git status:" -ForegroundColor Cyan
git status

Write-Host "`n🧭 Recent commits:" -ForegroundColor Cyan
git log --oneline --graph --decorate -n 10

Write-Host "`n🧪 Running scoped test harness..." -ForegroundColor Cyan
# Replace with your actual test harness logic
if (Test-Path ".\tests\run_tests.py") {
    python .\tests\run_tests.py
} else {
    Write-Host "⚠️ No test harness found." -ForegroundColor Yellow
}

Write-Host "`n📝 Interactive staging..." -ForegroundColor Cyan
git add -p

Write-Host "`n🔐 Committing changes..." -ForegroundColor Cyan
$commitMsg = Read-Host "Enter commit message"
if ($commitMsg) {
    git commit -m "$commitMsg"
} else {
    Write-Host "⚠️ No commit message entered. Skipping commit." -ForegroundColor Yellow
}

Write-Host "`n🚀 Pushing to origin..." -ForegroundColor Cyan
git push origin main

Write-Host "`n🏷️ Tagging release (optional)..." -ForegroundColor Cyan
$tag = Read-Host "Enter tag (or leave blank to skip)"
if ($tag) {
    git tag -a $tag -m "$commitMsg"
    git push origin $tag
}

Write-Host "`n🧹 Auditing untracked files..." -ForegroundColor Cyan
git status --untracked-files=all > .\GitUntracked.log
Write-Host "🔍 Untracked files logged to GitUntracked.log"

Write-Host "`n🧪 Previewing cleanup..." -ForegroundColor Cyan
git clean -n -d

$confirm = Read-Host "Proceed with cleanup of untracked files? (y/n)"
if ($confirm -eq "y") {
    Write-Host "`n🧨 Cleaning untracked files..." -ForegroundColor Cyan
    git clean -f -d
} else {
    Write-Host "❌ Cleanup skipped." -ForegroundColor Yellow
}