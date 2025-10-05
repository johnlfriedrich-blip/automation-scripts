function Invoke-FileRouting {
    [CmdletBinding()]
     param (
        [System.IO.FileInfo]$File,
        [string[]]$ImageExtensions,
        [string[]]$DocumentExtensions,
        [string]$ImageDestination,
        [string]$DocDestination,
        [string]$LogPath,
        [switch]$DryRun
    )

    $ext = $File.Extension.ToLower().Trim()

    #Start Timer
    $startTime = Get-Date

    # Normalize extension arrays
    $imageExtensions = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff") | ForEach-Object { $_.ToLower().Trim() }
    $documentExtensions = @(".pdf", ".docx", ".xlsx", ".pptx", ".txt", ".zip") | ForEach-Object { $_.ToLower().Trim() }

    # Fallback paths for testing
    
    $imageDestination = Join-Path $env:OneDrive "Pictures\SortedImages"
    $docDestination   = Join-Path $env:OneDrive "Documents\SortedDocs"
    $source           = "$env:USERPROFILE\Downloads"
    $logPath          = Join-Path $imageDestination "SortDownloads.log"

    # Trace paths
    
    # Ensure folders exist
    foreach ($path in @($imageDestination, $docDestination)) {
        if (!(Test-Path $path)) {
            Write-Host "🛠️ Creating folder: $path" -ForegroundColor Magenta
            New-Item -Path $path -ItemType Directory -Force
        } else {
            Write-Host "✅ Folder exists: $path" -ForegroundColor Green
        }
    }

    # Start log
    Add-Content -Path $logPath -Value "$(Get-Date): Script started"
    
    $seenExtensions = @{}
    # Process files
    Get-ChildItem -Path $source -File | ForEach-Object {
        $ext = $_.Extension.ToLower().Trim()
       
        $seenExtensions[$ext] = $true
        # Hydration check
        $isHydrated = $true
        try {
            $stream = [System.IO.File]::OpenRead($_.FullName)
            $stream.Close()
        } catch {
            $isHydrated = $false
        }

        if (-not $isHydrated) {
            Add-Content -Path $logPath -Value "$(Get-Date): Skipped $($_.Name) — not hydrated"
            return
        }

        # Document routing
        if ($documentExtensions -contains $ext) {
        #if ($_.Name -match '\.(pdf|docx|xlsx|pptx|txt|zip)$') {
            $target = Join-Path $docDestination $_.Name
            if ($DryRun) {
                Add-Content -Path $logPath -Value "$(Get-Date): [DryRun] Would move document $($_.Name)"
            } else {
                Move-Item $_.FullName -Destination $target -Force
                Add-Content -Path $logPath -Value "$(Get-Date): Moved document $($_.Name)"
            }
            return
        }

        # Image routing
        if ($imageExtensions -contains $ext) {
            $target = Join-Path $imageDestination $_.Name
            if ($DryRun) {
                Add-Content -Path $logPath -Value "$(Get-Date): [DryRun] Would move image $($_.Name)"
            } else {
                Move-Item $_.FullName -Destination $target -Force
                Add-Content -Path $logPath -Value "$(Get-Date): Moved image $($_.Name)"
            }
            return
        }

        # Fallback
        Add-Content -Path $logPath -Value "$(Get-Date): Skipped $($_.Name) — unmatched extension '$ext'"
        Add-Content -Path $logPath -Value "$(Get-Date): Skipped $($_.Name) — extension '$ext' not matched"
    }

    #End Timer and calculate duration
    $endTime = Get-Date
    $duration = $endTime - $startTime
    $durationFormatted = [string]::Format("{0:hh\:mm\:ss}" -f $duration)
    $durationPerFile = if ($seenExtensions.Count -gt 0) { $duration.TotalSeconds / $seenExtensions.Count } else { 0 }
    #Log completion with duration
    Add-Content -Path $logPath -Value "$(Get-Date): Script completed in $duration"
    Add-Content -Path $logPath -Value "$(Get-Date): Execution time: $durationFormatted"
    Add-Content -Path $logPath -Value "$(Get-Date): It took $durationPerFile seconds per file for $($seenExtensions.Count) unique extensions"
    Write-Host "I'm at the end of the script!"
    Write-Host "⏱️ Script completed in $durationFormatted" -ForegroundColor Green
    Write-Host "⏱️ It took $durationPerFile seconds per file for $($seenExtensions.Count) unique extensions" -ForegroundColor Green
}

Export-ModuleMember -Function Invoke-SortDownloads