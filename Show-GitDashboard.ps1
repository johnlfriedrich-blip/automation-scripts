function Show-GitDashboard {
    param (
        [int]$CommitCount = 10
    )

    Write-Host "`n📦 Git Dashboard for $PWD`n" -ForegroundColor Cyan

    # Repo Summary
    $branch = git rev-parse --abbrev-ref HEAD
    $lastCommit = git log -1 --pretty=format:"%h - %an - %s"
    $remote = git remote get-url origin
    $totalCommits = git rev-list --count HEAD

    Write-Host "🔹 Branch: $branch"
    Write-Host "🔹 Last Commit: $lastCommit"
    Write-Host "🔹 Total Commits: $totalCommits"
    Write-Host "🔹 Remote: $remote`n"

    # Commit History
    Write-Host "🕓 Recent Commits:`n"
    git log -$CommitCount --pretty=format:"%C(yellow)%h%Creset - %C(cyan)%an%Creset - %s (%Cgreen%cr%Creset)" | ForEach-Object { Write-Host $_ }

    # Sync Status
    Write-Host "`n🔄 Sync Status:`n"
    git status -sb

    # Tags
    Write-Host "`n🏷️ Tags:`n"
    git tag --sort=-creatordate | ForEach-Object {
        $tagCommit = git rev-list -n 1 $_
        Write-Host "$_ → $tagCommit"
    }

    Optional: Export to log
    Out-File -FilePath "GitDashboard_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
}