Write-Host "✅ FileAudit class loaded"
class FileAuditEntry {
    [string]$FullName
    [int64]$Length
    [datetime]$LastWriteTime
    [string]$Extension

    FileAuditEntry([System.IO.FileInfo]$file) {
        $this.FullName = $file.FullName
        $this.Length = $file.Length
        $this.LastWriteTime = $file.LastWriteTime
        $this.Extension = $file.Extension.TrimStart('.').ToLower()
    }

    [bool]IsLarge([int64]$minSizeBytes) {
        return $this.Length -ge $minSizeBytes
    }

    [bool]IsStale([int]$daysOld) {
        return $this.LastWriteTime -lt (Get-Date).AddDays(-$daysOld)
    }

    [string]ToString() {
        return "$($this.FullName) - $($this.Length) bytes - $($this.LastWriteTime)"
    }
}
class FileAuditEngine {
    [string]$FolderToQuery
    [int64]$MinSizeBytes
    [string[]]$Extensions
    [string]$SortBy

    FileAuditEngine([string]$folder, [int]$minSizeMB, [string]$extCsv, [string]$sortBy = "Length") {
        $this.FolderToQuery = [System.IO.Path]::Combine([Environment]::GetFolderPath("UserProfile"), "OneDrive", $folder)
        $this.MinSizeBytes = $minSizeMB * 1MB
        $this.Extensions = $extCsv -split ',' | ForEach-Object { $_.Trim().ToLower() }
        $this.SortBy = $sortBy
    }

    [FileAuditEntry[]]GetLargeFiles() {
        $files = Get-ChildItem -Path $this.FolderToQuery -Recurse -File -ErrorAction SilentlyContinue
        $filtered = foreach ($file in $files) {
            $entry = [FileAuditEntry]::new($file)
            if ($this.Extensions -contains $entry.Extension -and $entry.IsLarge($this.MinSizeBytes)) {
                $entry
            }
        }
        return $filtered | Sort-Object -Property $this.SortBy -Descending
    }
}