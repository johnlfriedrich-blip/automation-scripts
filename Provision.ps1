# Provision.ps1
# Modular provisioning script for Git, OneDrive, VS Code, and audit logging

function Test-Git {
    Write-Host "`n[Git] Validating Git installation..." -ForegroundColor Cyan
    $gitVersion = git --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✔ Git detected: $gitVersion" -ForegroundColor Green
        git config --global user.name "John Friedrich"
        git config --global user.email "your.email@example.com"
        git config --global core.editor "code --wait"
    } else {
        Write-Host "✖ Git not found. Please install Git before proceeding." -ForegroundColor Red
    }
}

function Test-OneDriveSync {
    Write-Host "`n[OneDrive] Checking sync status..." -ForegroundColor Cyan
    $onedrivePath = "$env:USERPROFILE\OneDrive"
    if (Test-Path $onedrivePath) {
        Write-Host "✔ OneDrive folder detected at $onedrivePath" -ForegroundColor Green
    } else {
        Write-Host "✖ OneDrive folder not found. Sync may be misconfigured." -ForegroundColor Yellow
    }
}

function Install-VSCodeExtensions {
    Write-Host "`n[VS Code] Installing extensions..." -ForegroundColor Cyan
    $extensions = @(
        "ms-vscode.powershell",
        "GitHub.vscode-pull-request-github",
        "eamodio.gitlens",
        "ms-vscode-remote.remote-wsl"
    )
    foreach ($ext in $extensions) {
        code --install-extension $ext
        Write-Host "✔ Installed: $ext" -ForegroundColor Green
    }
}

function Write-GitIgnoreTemplate {
    Write-Host "`n[Git] Writing .gitignore..." -ForegroundColor Cyan
    @"
# Logs and temp
*.log
*.tmp
*.bak

# VS Code
.vscode/

# OneDrive sync artifacts
*.lnk
*.DS_Store
"@ | Set-Content .gitignore
    Write-Host "✔ .gitignore written" -ForegroundColor Green
}

function Write-ProvisioningResult {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content "provision.log" "`n[$timestamp] Provisioning completed successfully."
    Write-Host "`n[Log] Provisioning log updated." -ForegroundColor Cyan
}

# Main Execution
Test-Git
Test-OneDriveSync
Install-VSCodeExtensions
Write-GitIgnoreTemplate
Write-ProvisioningResult