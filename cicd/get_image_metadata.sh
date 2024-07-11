#!/bin/bash

# Requirements
# - bash (version 4.0+)
# - yq

# Function to log messages
log() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" > /dev/stderr
}

# Main script execution
if [ "$#" -ne 1 ]; then
    log "Usage: $0 <stack_folder>"
    exit 1
fi

stack_folder="$1"
disk_yaml_path="$stack_folder/disk.yaml"

if [ ! -f "$disk_yaml_path" ]; then
    log "Error: disk.yaml not found in $stack_folder"
    exit 1
fi

# Extract image information using yq
image_path=$(yq e '.spec.forProvider.image' "$disk_yaml_path")

if [ -z "$image_path" ]; then
    log "Error: Could not find spec.forProvider.image in $disk_yaml_path"
    exit 1
fi

# Extract project name and image name
project_name=$(echo "$image_path" | sed -n 's/projects\/\([^\/]*\).*/\1/p')
image_name=$(echo "$image_path" | sed -n 's/.*\/images\/\(.*\)/\1/p')

# Print results in tabular format
printf "%-20s %-20s\n" "$project_name" "$image_name"

log "Extraction completed successfully."