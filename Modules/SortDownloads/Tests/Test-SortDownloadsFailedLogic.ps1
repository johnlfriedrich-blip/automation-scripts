$imageExtensions = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff")
$source = "$env:USERPROFILE\Downloads"

Get-ChildItem -Path $source -File | ForEach-Object {
    $ext = [System.IO.Path]::GetExtension($_.Name).ToLower().Trim()
    $name = $_.Name

    Write-Host "File: $name | Extension: '$ext' | Length: $($ext.Length)"

    if ($imageExtensions -contains $ext) {
        Write-Host "✅ Matched image extension for $name"
    } else {
        Write-Host "❌ Did not match for $name"
    }
}