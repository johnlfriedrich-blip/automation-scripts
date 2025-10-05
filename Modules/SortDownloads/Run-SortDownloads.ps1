# Define module path
$modulePath = "$env:OneDrive\Scripts\Modules\SortDownloads"

# Import the module
Import-Module $modulePath -Force

# Confirm module load
Write-Host "✅ Module loaded from: $modulePath" -ForegroundColor Green
Write-Host "🔍 Host: $($Host.Name)" -ForegroundColor Gray
Write-Host "🔍 PowerShell Edition: $($PSVersionTable.PSEdition)" -ForegroundColor Gray

# Optional: List available commands in the module
Get-Command -Module SortDownloads | Format-Table Name, CommandType

# Invoke the function
#Invoke-SortDownloads -DryRun

# Confirm completion
#Write-Host "✅ SortDownloads execution completed" -ForegroundColor Cyan