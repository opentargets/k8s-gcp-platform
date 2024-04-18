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
tf_context_file_name="context.tfvars"
platform_image_file_clickhouse="images_platform_ch.txt"
platform_image_file_opensearch="images_platform_os.txt"
ppp_image_file_clickhouse="images_ppp_ch.txt"
ppp_image_file_opensearch="images_ppp_os.txt"
# Overlays base location, relative to the script
overlays_folder="../../kubernetes/overlays"
# Clickhouse overlay base file name
clickhouse_overlay_base="clickhouse_pv"
# OpenSearch overlay base file name
opensearch_overlay_base="opensearch_pv"
# Overlays template file extension
overlay_template_extension=".yaml.template"
# Overlays instance file extension
overlay_instance_extension=".yaml"

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
    echo ""
    echo "Commands:"
    echo "  add_image <product> <image_type> <image_name>"
    echo "  remove_image <product> <image_type> <image_name>"
    echo "  pop_image <product> <image_type>"
    echo "  list_images <product> <image_type>"
    echo "  deploy_disks"
    echo "  destroy_disks"
    echo ""
    echo "Products:"
    echo "  platform"
    echo "  ppp"
    echo ""
    echo "Image types:"
    echo "  clickhouse"
    echo "  opensearch"
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
    error "Invalid product. Must be 'platform' or 'ppp'."
    exit 1
fi

# Validate image type, it must be either 'clickhouse' or 'opensearch', unless the command is 'deploy_disks' or 'destroy_disks'
if [[ "$command" != "deploy_disks" && "$command" != "destroy_disks" ]]; then
    if [[ "$image_type" != "clickhouse" && "$image_type" != "opensearch" ]]; then
        error "Invalid image type. Must be 'clickhouse' or 'opensearch'."
        exit 1
    fi
fi

# Helper functions for working with overlays
# get_overlay_template_file_name <image_type> <zone>, produces the overlay template file name
get_overlay_template_file_path() {
    local image_type=$1
    local zone=$2

    if [[ "$image_type" == "clickhouse" ]]; then
        echo "${overlays_folder}/${clickhouse_overlay_base}-${zone}${overlay_template_extension}"
    elif [[ "$image_type" == "opensearch" ]]; then
        echo "${overlays_folder}/${opensearch_overlay_base}-${zone}${overlay_template_extension}"
    fi
}

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

# Helper functions
# get_overlay_template_file_name <image_type> <zone>

# Function to remove an image from the list
remove_image() {
    local image_file=$1
    local image_name=$2

    if [ -f "$image_file" ]; then
        if grep -q "$image_name" "$image_file"; then
            sed -i "/$image_name/d" "$image_file"
            log "Image removed from the list."
        else
            error "Image not found in the list."
            exit 1
        fi
    else
        error "Image file not found."
        exit 1
    fi
}

# Function to pop an image from the list, which removes the first image from the list, if the list is not empty
pop_image() {
    local image_file=$1

    if [ -f "$image_file" ]; then
        if [ -s "$image_file" ]; then
            local image_name=$(head -n 1 "$image_file")
            sed -i "1d" "$image_file"
            log "Image popped from the list: $image_name"
        else
            error "Image list is empty."
            exit 1
        fi
    else
        error "Image file not found."
        exit 1
    fi
}

# Function to list images
list_images() {
    local image_file=$1

    if [ -f "$image_file" ]; then
        if [ -s "$image_file" ]; then
            log "Images:"
            cat "$image_file"
        else
            error "Image list is empty."
            exit 1
        fi
    else
        error "Image file not found."
        exit 1
    fi
}

# Function to deploy GCE disks using terraform, based on the images in the list file for both products (platform and ppp), given an environment
deploy_disks() {
    local path_tf_context="${folder_environments}/${environment}/${tf_context_file_name}"

    # Init Terraform, exit if it fails
    log "Initializing Terraform..."
    terraform init
    if [ $? -ne 0 ]; then
        error "Failed to initialize Terraform."
        exit 1
    fi

    # Switch to the workspace with the name that matches the environment
    log "Switching to the workspace '${environment}'..."
    terraform workspace select "${environment}"
    if [ $? -ne 0 ]; then
        error "Failed to switch to the workspace."
        exit 1
    fi

    # Deploy the disks
    log "Deploying disks..."
    terraform apply -var-file="${path_tf_context}" -auto-approve
    if [ $? -ne 0 ]; then
        error "Failed to deploy disks."
        exit 1
    fi
}

# Function to destroy GCE disks using terraform, based on the images in the list file for both products (platform and ppp), given an environment
destroy_disks() {
    local path_tf_context="${folder_environments}/${environment}/${tf_context_file_name}"

    # Init Terraform, exit if it fails
    log "Initializing Terraform..."
    terraform init
    if [ $? -ne 0 ]; then
        error "Failed to initialize Terraform."
        exit 1
    fi

    # Switch to the workspace with the name that matches the environment
    log "Switching to the workspace '${environment}'..."
    terraform workspace select "${environment}"
    if [ $? -ne 0 ]; then
        error "Failed to switch to the workspace."
        exit 1
    fi

    # Destroy the disks
    log "Destroying disks..."
    terraform destroy -var-file="${path_tf_context}" -auto-approve
    if [ $? -ne 0 ]; then
        error "Failed to destroy disks."
        exit 1
    fi
}

# Command line routing
path_base_images="${folder_environments}/${environment}"
case $command in
    add_image)
        if [[ "$product" == "platform" ]]; then
            if [[ "$image_type" == "clickhouse" ]]; then
                add_image "${path_base_images}/${platform_image_file_clickhouse}" "$image_name"
            elif [[ "$image_type" == "opensearch" ]]; then
                add_image "${path_base_images}/${platform_image_file_opensearch}" "$image_name"
            fi
        elif [[ "$product" == "ppp" ]]; then
            if [[ "$image_type" == "clickhouse" ]]; then
                add_image "${path_base_images}/${ppp_image_file_clickhouse}" "$image_name"
            elif [[ "$image_type" == "opensearch" ]]; then
                add_image "${path_base_images}/${ppp_image_file_opensearch}" "$image_name"
            fi
        fi
        ;;
    remove_image)
        if [[ "$product" == "platform" ]]; then
            if [[ "$image_type" == "clickhouse" ]]; then
                remove_image "${path_base_images}/${platform_image_file_clickhouse}" "$image_name"
            elif [[ "$image_type" == "opensearch" ]]; then
                remove_image "${path_base_images}/${platform_image_file_opensearch}" "$image_name"
            fi
        elif [[ "$product" == "ppp" ]]; then
            if [[ "$image_type" == "clickhouse" ]]; then
                remove_image "${path_base_images}/${ppp_image_file_clickhouse}" "$image_name"
            elif [[ "$image_type" == "opensearch" ]]; then
                remove_image "${path_base_images}/${ppp_image_file_opensearch}" "$image_name"
            fi
        fi
        ;;
    pop_image)
        if [[ "$product" == "platform" ]]; then
            if [[ "$image_type" == "clickhouse" ]]; then
                pop_image "${path_base_images}/${platform_image_file_clickhouse}"
            elif [[ "$image_type" == "opensearch" ]]; then
                pop_image "${path_base_images}/${platform_image_file_opensearch}"
            fi
        elif [[ "$product" == "ppp" ]]; then
            if [[ "$image_type" == "clickhouse" ]]; then
                pop_image "${path_base_images}/${ppp_image_file_clickhouse}"
            elif [[ "$image_type" == "opensearch" ]]; then
                pop_image "${path_base_images}/${ppp_image_file_opensearch}"
            fi
        fi
        ;;
    list_images)
        if [[ "$product" == "platform" ]]; then
            if [[ "$image_type" == "clickhouse" ]]; then
                list_images "${path_base_images}/${platform_image_file_clickhouse}"
            elif [[ "$image_type" == "opensearch" ]]; then
                list_images "${path_base_images}/${platform_image_file_opensearch}"
            fi
        elif [[ "$product" == "ppp" ]]; then
            if [[ "$image_type" == "clickhouse" ]]; then
                list_images "${path_base_images}/${ppp_image_file_clickhouse}"
            elif [[ "$image_type" == "opensearch" ]]; then
                list_images "${path_base_images}/${ppp_image_file_opensearch}"
            fi
        fi
        ;;
    deploy_disks)
        deploy_disks
        ;;
    destroy_disks)
        destroy_disks
        ;;
    *)
        error "Invalid command."
        exit 1
        ;;
esac