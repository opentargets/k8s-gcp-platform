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
manage <environment> add_image <product> <image_name>
manage <environment> remove_image <product> <image_name>
manage <environment> list_images <product>
manage <environment> deploy_disks <product>
manage <environment> destroy_disks <product>

# Validate the number of arguments
if [ "$#" -lt 3 ]; then
    echo "Usage: manage <environment> <command> <product> [image_name]"
    exit 1
fi

# Command line parameters
environment=$1
command=$2
product=$3
image_name=$4

