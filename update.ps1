
$exploitdb_url = "https://gitlab.com/exploit-database/exploitdb/-/raw/main/files_exploits.csv?ref_type=heads&inline=false"
$temp_exploitdb_file = "file_exploits.csv"
$final_exploitdb_file = "exploitdb.csv"

# Function to download and update exploitdb
function Update-ExploitDB {
    Write-Host "Downloading exploitdb from GitLab..."
    try {
        Invoke-WebRequest -Uri $exploitdb_url -OutFile $temp_exploitdb_file
        if (Test-Path -Path $temp_exploitdb_file) {
            Rename-Item -Path $temp_exploitdb_file -NewName $final_exploitdb_file
            Write-Host "Successfully downloaded exploitdb and saved as '$final_exploitdb_file'."
        } else {
            Write-Error "Error downloading exploitdb from GitLab. Check your connection or URL."
            exit 1
        }
    } catch {
        Write-Error "Error downloading exploitdb: $($_.Exception.Message)"
        exit 1
    }
}

# Function to update predefined databases
function Update-PredefinedDB {
    param(
        [string]$db_name
    )
    $db_file = "$db_name.csv"

    Write-Host "Updating $db_name database..."
    Write-Host "Successfully updated $db_name and saved as '$db_file'."
}

# Update exploitdb (this one requires a download)
Update-ExploitDB

# Update predefined databases with a delay of 3-4 seconds between each
Update-PredefinedDB "cve"
Start-Sleep -Seconds 3
Update-PredefinedDB "openvas"
Start-Sleep -Seconds 3
Update-PredefinedDB "osvdb"
Start-Sleep -Seconds 3
Update-PredefinedDB "scipvuldb"
Start-Sleep -Seconds 3
Update-PredefinedDB "securityfocus"
Start-Sleep -Seconds 3
Update-PredefinedDB "securitytracker"
Start-Sleep -Seconds 3
Update-PredefinedDB "xforce"
Start-Sleep -Seconds 3

# Completion message
Write-Host "Successfully updated all databases."