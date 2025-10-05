# Dot-source the class definition
. "$env:OneDrive\Scripts\Classes\SortDownloads\SortDownloads.psm1"
Write-Host "🔍 Attempting to import module from: $env:OneDrive\Scripts\Classes\SortDownloads\SortDownloads.psm1" -ForegroundColor Gray
Write-Host "✅ Module 'SortDownloads imported successfully." -ForegroundColor Green

# Instantiate and run
#$sorter = [SortDownloads]::new($true)
#$sorter.Run()