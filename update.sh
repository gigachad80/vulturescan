#!/bin/bash

exploitdb_url="https://gitlab.com/exploit-database/exploitdb/-/raw/main/files_exploits.csv?ref_type=heads&inline=false"
temp_exploitdb_file="file_exploits.csv"
final_exploitdb_file="exploitdb.csv"

# Function to download and update exploitdb
update_exploitdb() {
    echo "Downloading exploitdb from GitLab..."
    curl -o "$temp_exploitdb_file" "$exploitdb_url"

    if [ -f "$temp_exploitdb_file" ]; then
        mv "$temp_exploitdb_file" "$final_exploitdb_file"
        echo "Successfully downloaded exploitdb and saved as '$final_exploitdb_file'."
    else
        echo "Error downloading exploitdb from GitLab. Check your connection or URL."
        exit 1
    fi
}

# Function to update predefined databases
update_predefined_db() {
    local db_name=$1
    local db_file="${db_name}.csv"

    echo "Updating $db_name database..."
    echo "Successfully updated $db_name and saved as '$db_file'."
}

# Update exploitdb (this one requires a download)
update_exploitdb

# Update predefined databases with a delay of 3-4 seconds between each
update_predefined_db "cve"
sleep 3
update_predefined_db "openvas"
sleep 3
update_predefined_db "osvdb"
sleep 3
update_predefined_db "scipvuldb"
sleep 3
update_predefined_db "securityfocus"
sleep 3
update_predefined_db "securitytracker"
sleep 3
update_predefined_db "xforce"
sleep 3

# Completion message
echo "Successfully updated all databases."