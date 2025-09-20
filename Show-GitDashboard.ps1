# Write-Log helper function
function Write-Log {
    param ([string]$Message)
    Write-Host $Message
    Add-Content -Path $logPath -Value $Message
}

# Main dashboard function
function Show-GitDashboard {
    param (
        [int]$CommitCount = 10
    )

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logPath = "$PSScriptRoot\GitDashboard_$timestamp.log"

    Write-Log "`n📦 Git Dashboard for $PWD`n"

    # Repo Summary
    $branch = git rev-parse --abbrev-ref HEAD
    $lastCommit = git log -1 --pretty=format:"%h - %an - %s"
    $remote = git remote get-url origin
    $totalCommits = git rev-list --count HEAD

    Write-Log "🔹 Branch: $branch"
    Write-Log "🔹 Last Commit: $lastCommit"
    Write-Log "🔹 Total Commits: $totalCommits"
    Write-Log "🔹 Remote: $remote`n"

    # Commit History
    Write-Log "🕓 Recent Commits:`n"
    git log -$CommitCount --pretty=format:"%h - %an - %s (%cr)" | ForEach-Object { Write-Log $_ }

    # Sync Status
    Write-Log "`n🔄 Sync Status:`n"
    git status -sb | ForEach-Object { Write-Log $_ }

    # Tags
    Write-Log "`n🏷️ Tags:`n"
    git tag --sort=-creatordate | ForEach-Object {
        $tagCommit = git rev-list -n 1 $_
        Write-Log "$_ → $tagCommit"
    }
}

# Auto-run the dashboard
Show-GitDashboard -CommitCount 10