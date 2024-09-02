# Function to recursively find files and append their content to the output file
function Append-FilesContent {
    param (
        [string]$Directory,
        [string]$OutputFile
    )

    # Loop through files and directories
    Get-ChildItem -Path $Directory -Recurse | ForEach-Object {
        $file = $_.FullName
        $extension = [System.IO.Path]::GetExtension($file)

        # Exclude specific file types and directories
        if ($extension -match "\.(ico|jpg|jpeg|png|svg|bmp|gif)" -or 
            $file -like "*node_modules*" -or 
            $file -like "*package-lock.json" -or 
            $file -like "*mailpit.db") {
            Write-Output "Skipping file: $file"
            return
        }

        # Include text-based file types
        if ($extension -in @(".tsx", ".js", ".ts", ".config.mjs", ".json")) {
            try {
                Add-Content -Path $OutputFile -Value "`n`n// $file"
                $fileContent = Get-Content -Path $file
                Add-Content -Path $OutputFile -Value $fileContent
            } catch {
                Write-Output "Error writing to $($OutputFile): $($_.Exception.Message)"
                return
            }
        }
    }
}

# Main script

# Output file name
$outputFile = "output.txt"

# Clear output file if it exists
if (Test-Path -Path $outputFile) {
    try {
        Remove-Item -Path $outputFile -Force
    } catch {
        Write-Output "Error deleting $($outputFile): $($_.Exception.Message)"
        return
    }
    New-Item -Path $outputFile -ItemType File
} else {
    New-Item -Path $outputFile -ItemType File
}

# Add content of files in the current directory and its immediate subdirectories
Append-FilesContent -Directory "." -OutputFile $outputFile

Write-Output "Text files content copied to $($outputFile)"
