<#
.SYNOPSIS
Returns file metadata including Explorer-style Type, sorted by a specified property.

.DESCRIPTION
Uses Shell.Application COM object to extract Explorer-style file metadata and sorts output by Name, Extension, Type, or DateCreated.

.PARAMETER Path
The folder path to scan. Defaults to current directory.
<#
.SYNOPSIS
Returns Explorer-style file metadata and sorts by a specified property.

.DESCRIPTION
Uses Shell.Application COM object to extract file metadata including Type and DateCreated.
Supports sorting by Name, Extension, Type, or DateCreated, with optional descending order.

.PARAMETER Path
The folder path to scan. Defaults to current directory.

.PARAMETER SortBy
The property to sort by. Valid values: Name, Extension, Type, DateCreated.

.PARAMETER Descending
Switch to sort in descending order.

.EXAMPLE
Get-ExplorerType -Path "C:\Scripts" -SortBy "Type"

.EXAMPLE
Get-ExplorerType -Path "C:\Docs" -SortBy "DateCreated" -Descending
#>

function Get-ExplorerType {
    param (
        [string]$Path = ".",
        [ValidateSet("Name", "Extension", "Type", "DateCreated", "Size")]
        [string]$SortBy = "Type",
        [switch]$Descending
    )

    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace((Resolve-Path $Path).Path)

    $items = $folder.Items() | ForEach-Object {
        $type        = $folder.GetDetailsOf($_, 2)
        $dateCreated = $folder.GetDetailsOf($_, 4)
        $sizeRaw     = $folder.GetDetailsOf($_, 1)

        # Use .Path instead of .Name for reliable extension
        $extension   = [System.IO.Path]::GetExtension($_.Path)
        $name        = [System.IO.Path]::GetFileName($_.Path)

        $sizeClean = try { [int64]::Parse($sizeRaw -replace '[^\d]', '') } catch { $null }
        $dateClean = try { [datetime]::Parse($dateCreated) } catch { $null }

        [PSCustomObject]@{
            Name        = $name
            Extension   = $extension
            Type        = $type
            DateCreated = $dateClean
            Size        = $sizeClean
        }

    }

    if ($Descending) {
        $items | Sort-Object -Property $SortBy -Descending
    } else {
        $items | Sort-Object -Property $SortBy
    }
}

function Find-JunkFiles {
    param (
        [string]$Path = "$env:USERPROFILE\OneDrive\Downloads",
        [int]$MinSizeMB = 50,
        [int]$OlderThanDays = 30,
        [string[]]$Extensions = @(".exe", ".msi", ".zip", ".log", ".tmp"),
        [switch]$Delete,
        [switch]$UseLastWriteTime
    )

    $cutoff = (Get-Date).AddDays(-$OlderThanDays)
    $normalizedExt = $Extensions | ForEach-Object { $_.ToLower() }

    $files = Get-ChildItem -Path $Path -Recurse -File |
        Where-Object {
            $extMatch = $normalizedExt -contains $_.Extension.ToLower()
            $sizeMatch = ($_.Length / 1MB) -ge $MinSizeMB
            $dateMatch = if ($UseLastWriteTime) {
                $_.LastWriteTime -lt $cutoff
            } else {
                $_.CreationTime -lt $cutoff
            }
            $extMatch -and $sizeMatch -and $dateMatch
        }

    if (-not $Delete) {
        return $files | Select-Object Name, Extension, Length, LastWriteTime
    }

    # Display summary
    $files | Select-Object Name, Extension, Length, LastWriteTime | Format-Table -AutoSize
    Write-Host "`n$($files.Count) files matched." -ForegroundColor Cyan

    # Prompt for bulk deletion
    $bulkConfirm = Read-Host "`nDelete all matched files? (Y/n)"
    if ($bulkConfirm -eq "" -or $bulkConfirm -match "^[Yy]$") {
        $files | ForEach-Object {
            Remove-Item $_.FullName -Force
            Write-Host "Deleted: $($_.FullName)" -ForegroundColor Green
        }
        return
    }

    # Loop through each file interactively
    foreach ($file in $files) {
        $response = Read-Host "Delete $($file.Name)? (Y/n)"
        if ($response -eq "" -or $response -match "^[Yy]$") {
            Remove-Item $file.FullName -Force
            Write-Host "Deleted: $($file.FullName)" -ForegroundColor Green
        } else {
            Write-Host "Skipped: $($file.FullName)" -ForegroundColor Yellow
        }
    }
}



Export-ModuleMember -Function Get-ExplorerType, Find-JunkFiles

