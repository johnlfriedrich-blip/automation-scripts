class SortDownloads {
    [System.Collections.Generic.List[object]]$RollbackList = @()
    [string]$Source
    [string]$ImageBase
    [string]$DocBase
    [string]$LogPath
    [string[]]$ImageExtensions
    [string[]]$DocumentExtensions
    [switch]$DryRun
    [datetime]$StartTime
    [datetime]$EndTime
    [string]$TimestampFolder
    [string]$ImageDestination
    [string]$DocDestination
    [hashtable]$ExtensionMap

    SortDownloads([switch]$DryRun) {
        $this.DryRun = $DryRun # Accepts a switch to enable dry run mode - $true = dry run, $false = actual move
        #$this.ImageExtensions = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff")
        #$this.DocumentExtensions = @(".pdf", ".docx", ".xlsx", ".pptx", ".txt", ".zip")
        $this.Source = "$env:USERPROFILE\Downloads"
        $this.ImageBase = "$env:OneDrive\Pictures\SortedImages"
        $this.DocBase = "$env:OneDrive\Documents\SortedDocs"
        $this.TimestampFolder = Get-Date -Format "yyyy-MM-dd"
        $this.ImageDestination = Join-Path $this.ImageBase $this.TimestampFolder
        $this.DocDestination = Join-Path $this.DocBase $this.TimestampFolder
        $this.LogPath = Join-Path $this.ImageBase "SortDownloads.log"
        $this.StartTime = Get-Date
        $this.EnsureFolders()
        $this.Log("Script started", "INFO")
        $configPath = Join-Path $PSScriptRoot "ExtensionMap.json"
        if (-not (Test-Path $configPath)) {
            throw "ExtensionMap.json not found at $configPath"
        }

        $json = Get-Content $configPath | ConvertFrom-Json
        $this.ExtensionMap = [hashtable]::Synchronized(@{ })

        foreach ($key in $json.PSObject.Properties.Name) {
            $this.ExtensionMap[$key] = $json.$key
        }

        if (-not ($this.ExtensionMap.Keys.Count)) {
            throw "ExtensionMap.json is empty or invalid"
        }          
        $this.Log("Loaded extension map from $configPath", "INFO")
    }
    [void]Log([string]$Message, [string]$Level = "INFO") {
        $entry = [PSCustomObject]@{
            Timestamp = (Get-Date).ToString("s")  # ISO 8601 format
            Level     = $Level
            Message   = $Message
            DryRun    = $this.DryRun.ToBool()
            Source    = $this.Source
            Actor     = $this.GetType().Name
        }
        $entry | ConvertTo-Json -Compress | Add-Content -Path $this.LogPath
    }

    [string]GetFileHash([string]$Path) {
        try {
            return (Get-FileHash -Path $Path -Algorithm SHA256).Hash
        }
        catch {
            return "Hash failed: $($_.Exception.Message)"
        }
    }

    [void]EnsureFolders() {
        foreach ($path in @($this.ImageDestination, $this.DocDestination)) {
            if (!(Test-Path $path)) {
                New-Item -Path $path -ItemType Directory -Force | Out-Null
            }
        }
    }

    [bool]IsHydrated([System.IO.FileInfo]$File) {
        try {
            $stream = [System.IO.File]::OpenRead($File.FullName)
            $stream.Close()
            return $true
        }
        catch {
            return $false
        }
    }

    [void]RouteFile([System.IO.FileInfo]$File) {
        $ext = $File.Extension.ToLower().Trim()

        if (-not $this.IsHydrated($File)) {
            $this.Log("Skipped $($File.Name) — not hydrated", "WARNING")
            return
        }

        if (-not $this.ExtensionMap.ContainsKey($ext)) {
            $this.Log("Skipped $($File.Name) — unmatched extension '$ext'", "WARNING")
            return
        }

        $rawPath = $this.ExtensionMap[$ext]

        # Handle absolute vs relative paths
        $basePath = if ([System.IO.Path]::IsPathRooted($rawPath)) {
            $rawPath
        }
        else {
            Join-Path $env:OneDrive $rawPath
        }

        $target = Join-Path $basePath $File.Name

        # Log resolved path for audit clarity
        $this.Log("Resolved base path for '$ext': $basePath", "DEBUG")
        $this.Log("Target path: $target", "DEBUG")

        if ($this.DryRun) {
            $this.Log("[DryRun] Would move $($File.Name) → $target", "INFO")
        }
        else {
            Move-Item $File.FullName -Destination $target -Force
            $status = $this.GetSignatureStatus($target)
            $this.Log("Signature status for $($File.Name): $status", "INFO")
            $this.Log("Moved $($File.Name) → $target", "INFO")

            # Track for rollback
            $this.RollbackList.Add([PSCustomObject]@{
                    Original = $File.FullName
                    Target   = $target
                })
        }
    }
    [void]RotateLog() {
        if (-not (Test-Path $this.LogPath)) {
            return  # Nothing to rotate
        }

        $stamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
        $archiveDir = Join-Path $this.ImageBase "LogArchive"
        $archiveLog = Join-Path $archiveDir "SortDownloads-$stamp.log"

        if (-not (Test-Path $archiveDir)) {
            New-Item -Path $archiveDir -ItemType Directory -Force | Out-Null
        }

        Move-Item -Path $this.LogPath -Destination $archiveLog -Force
        $this.Log("Rotated log to $archiveLog", "INFO")        
    }

    [void]Rollback() {
        if ($this.RollbackList.Count -eq 0) {
            $this.Log("Rollback skipped — no files were moved", "INFO")
            return
        }
        foreach ($entry in $this.RollbackList) {
            if ($this.DryRun) {
                $this.Log("[DryRun] Would rollback $($entry.Target) → $($entry.Original)", "INFO")
            }
            elseif (Test-Path $entry.Target) {
                Move-Item $entry.Target -Destination $entry.Original -Force
                $this.Log("Rolled back $($entry.Target) → $($entry.Original)", "INFO")
            }
            else {
                $this.Log("Rollback failed — target not found: $($entry.Target)", "ERROR")
            }
        }
    }

    [string]GetSignatureStatus([string]$Path) {
        try {
            $sig = Get-AuthenticodeSignature -FilePath $Path
            return $sig.Status.ToString()
        }
        catch {
            return "Signature check failed: $($_.Exception.Message)"
        }
    }

    [void]Run() {
        $this.RotateLog()

        $files = Get-ChildItem -Path $this.Source -File
        foreach ($file in $files) {
            $this.RouteFile($file)
        }

        # 🧹 Quarantine unmatched installers
        $installers = $files | Where-Object {
            $_.Extension -in @('.exe', '.msi') -and
            -not $this.ExtensionMap.ContainsKey($_.Extension.ToLower())
        }

        $quarantinePath = "C:\Users\JohnFriedrich\Downloads\Installers"
        if (-not (Test-Path $quarantinePath)) {
            New-Item -Path $quarantinePath -ItemType Directory -Force | Out-Null
        }

        foreach ($installer in $installers) {
            $target = Join-Path $quarantinePath $installer.Name
            if ($this.DryRun) {
                $this.Log("[DryRun] Would quarantine installer $($installer.Name) → $target", "INFO")
            }
            else {
                Move-Item $installer.FullName -Destination $target -Force
                $this.Log("Quarantined installer $($installer.Name) → $target", "INFO")
                $status = $this.GetSignatureStatus($target)
                $hash = $this.GetFileHash($target)

                $this.Log("Signature status for $($installer.Name): $status", "INFO")
                $this.Log("SHA256 for $($installer.Name): $hash", "DEBUG")

                if ($status -ne 'Valid') {
                    $this.Log("⚠️ Installer $($installer.Name) has suspicious signature: $status", "WARNING")
                }
            }
        }

        $this.EndTime = Get-Date
        $duration = $this.EndTime - $this.StartTime
        $durationFormatted = [string]::Format("{0:hh\:mm\:ss}", $duration)
        $avgPerFile = if ($files.Count -gt 0) {
            [math]::Round($duration.TotalSeconds / $files.Count, 3)
        }
        else {
            0
        }

        $uniqueExtCount = ($files.Extension | Select-Object -Unique).Count
        $this.Log("Script completed", "INFO")
        $this.Log("Execution time: $durationFormatted", "INFO")
        $this.Log("It took $avgPerFile seconds per file for $uniqueExtCount unique extensions", "INFO")
    }

    
}