$imageExtensions = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff") | ForEach-Object { $_.ToLower().Trim() }
$source = "$env:USERPROFILE\Downloads"

Get-ChildItem -Path $source -File | ForEach-Object {
    $name = $_.Name
    $extRaw = [System.IO.Path]::GetExtension($name)
    $ext = [System.Text.RegularExpressions.Regex]::Replace($extRaw.ToLower(), '[^\.\w]', '').Trim()

    Write-Output "🔍 File: $name"
    Write-Output "Raw Extension: '$extRaw'"
    Write-Output "Sanitized Extension: '$ext'"
    Write-Output "Extension Length: $($ext.Length)"

    foreach ($img in $imageExtensions) {
        Write-Output "Comparing '$ext' to '$img'"
        if ($ext -eq $img) {
            Write-Output "✅ Match found for $name"
        }
    }

    Write-Output "-----------------------------------"
}