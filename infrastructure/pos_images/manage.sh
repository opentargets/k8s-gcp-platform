#!/bin/bash

# This script is a helper CLI tool to manage GCE deployed GCE disks and the images used as templates

# This script folder
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Logging functions
log () {
  echo -e "\033[1;32m$@\033[0m"
}

error () {
  echo -e "\033[1;31m$@\033[0m"
}

# Global variables
folder_environments="${SCRIPT_DIR}/environments"
platform_image_file_clickhouse="images_platform_ch.txt"
platform_image_file_opensearch="images_platform_os.txt"
ppp_image_file_clickhouse="images_ppp_ch.txt"
ppp_image_file_opensearch="images_ppp_os.txt"

# Sample commands
# manage <environment> add_image <product> <image_type> <image_name>
# manage <environment> remove_image <product> <image_type> <image_name>
# manage <environment> pop_image <product> <image_type>
# manage <environment> list_images <product>
# manage <environment> deploy_disks <product>
# manage <environment> destroy_disks <product>

# Validate the number of arguments
if [ "$#" -lt 3 ]; then
    echo "Usage: manage <environment> <command> <product> [image_name]"
    exit 1
fi

# Command line parameters
environment=$1
command=$2
product=$3
image_type=$4
image_name=$5

# Validate product
if [[ "$product" != "platform" && "$product" != "ppp" ]]; then
    echo "Invalid product. Must be 'platform' or 'ppp'."
    exit 1
fi

# Validate image type, it must be either 'clickhouse' or 'opensearch'
if [[ "$image_type" != "clickhouse" && "$image_type" != "opensearch" ]]; then
    echo "Invalid image type. Must be 'clickhouse' or 'opensearch'."
    exit 1
fi

# Function to add an image to the list
add_image() {
    local image_file=$1
    local image_name=$2

    if [ -f "$image_file" ]; then
        if grep -q "$image_name" "$image_file"; then
            error "Image already exists in the list."
            exit 1
        fi
    fi

    echo "$image_name" >> "$image_file"
    log "Image added to the list."
}

