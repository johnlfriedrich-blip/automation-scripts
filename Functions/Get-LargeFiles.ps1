function Get-LargeFiles {
        
    param (
        [string]$FolderToQuery,
        [int]$MinSize,
        [string]$Ext,
        [string]$SortBy
    )

    $RootPath = [Environment]::GetFolderPath("UserProfile") + "\OneDrive\"
    $QueryPath = $RootPath + $FolderToQuery
    $LogPath = Join-Path -Path $PWD -ChildPath "Logs"
    
    if (!(Test-Path -Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath | Out-Null
    }
    if (-not $FolderToQuery) { throw "FolderToQuery is required." }
    if (-not $Ext) { throw "Extension filter is required." }
    if (-not $SortBy) { $SortBy = "Length" }  # Default fallback
    if (-not $MinSize) { $MinSize = 5 }     # Default fallback

    $WorkingSet = Get-ChildItem -Path $QueryPath -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Length -gt ($MinSize * 1MB) -and $_.Extension -match $Ext } |
        Sort-Object -Property $SortBy -Descending |
        Select-Object -Property FullName, Length, LastWriteTime |
        Format-Table FullName, Length, LastWriteTime -AutoSize |
        Tee-Object -FilePath (Join-Path -Path $LogPath -ChildPath "LargeFiles_$(Get-Date -Format 'yyyyMMdd_HHmmss').log") 

    Return $WorkingSet
}
# Example usage:
# Get-LargeFiles -FolderToQuery "Documents" -MinSize 100 -Ext ".txt" -SortBy "Length"