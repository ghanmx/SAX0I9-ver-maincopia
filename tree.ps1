function New-DirectoryTree {
    param (
        [string]$Directory,
        [string]$TreeOutputFile
    )

    $tree = Get-ChildItem -Path $Directory -Recurse | Where-Object { $_.Name -ne 'node_modules' -and $_.Name -ne 'package-lock.json' -and $_.Name -notlike '*.yaml' } | ForEach-Object {
        $indent = "  " * ($_.FullName.Split([IO.Path]::DirectorySeparatorChar).Count - $Directory.Split([IO.Path]::DirectorySeparatorChar).Count)
        $name = $_.Name
        if ($_.PSIsContainer) {
            $name += "/"
        } else {
            $content = Get-Content -Path $_.FullName -Raw
            $name += " - Content: $content"
        }
        "$indent$name"
    }

    Set-Content -Path $TreeOutputFile -Value "Directory Tree Structure:`n"
    Add-Content -Path $TreeOutputFile -Value ($tree -join "`n")
    Write-Output "Directory tree structure has been written to $TreeOutputFile"
}

$outputFile = "outputtree.txt"

New-DirectoryTree -Directory "." -TreeOutputFile $outputFile