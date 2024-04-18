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
# "Externalized" strings
# Commands
cmd_add_image="add_image"
cmd_remove_image="remove_image"
cmd_pop_image="pop_image"
cmd_list_images="list_images"
cmd_deploy_disks="deploy_disks"
cmd_destroy_disks="destroy_disks"
# Products
product_platform="platform"
product_ppp="ppp"
# Image types
image_type_clickhouse="clickhouse"
image_type_opensearch="opensearch"
# Folder locations and file names
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
    echo "  $cmd_add_image <product> <image_type> <image_name>"
    echo "  $cmd_remove_image <product> <image_type> <image_name>"
    echo "  $cmd_pop_image <product> <image_type>"
    echo "  $cmd_list_images <product> <image_type>"
    echo "  $cmd_deploy_disks"
    echo "  $cmd_destroy_disks"
    echo ""
    echo "Products:"
    echo "  $platform"
    echo "  $ppp"
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

# Validate product (this is fine, we just have a couple of products)
if [[ "$product" != "${product_platform}" && "$product" != "${product_ppp}" ]]; then
    error "Invalid product. Must be '$product_platform' or '$product_ppp'."
    exit 1
fi

# Validate image type, it must be either 'clickhouse' or 'opensearch', unless the command is 'deploy_disks' or 'destroy_disks'
if [[ "$command" != "deploy_disks" && "$command" != "destroy_disks" ]]; then
    if [[ "$image_type" != "${image_type_clickhouse}" && "$image_type" != "${image_type_opensearch}" ]]; then
        error "Invalid image type. Must be '$image_type_clickhouse' or '$image_type_opensearch'."
        exit 1
    fi
fi

# Helper functions for working with overlays
# get_overlay_template_file_name <product> <environment> <image_type> <zone>, produces the overlay template file name
get_overlay_template_file_name() {
    local product=$1
    local environment=$2
    local image_type=$3
    local zone=$4

    if [[ "$image_type" == "$image_type_clickhouse" ]]; then
        echo "${overlays_folder}/${product}/${environment}/${clickhouse_overlay_base}-${zone}${overlay_template_extension}"
    elif [[ "$image_type" == "$image_type_opensearch" ]]; then
        echo "${overlays_folder}/${product}/${environment}/${opensearch_overlay_base}-${zone}${overlay_template_extension}"
    fi
}
# update_overlay_instance_file <environment> <image_type> <zone> <gce_disk_id>, updates the overlay instance file with the corresponding GCE disk ID
update_overlay_instance_file() {
    local environment=$1
    local image_type=$2
    local zone=$3
    local gce_disk_id=$4

    local overlay_template_file=$(get_overlay_template_file_name "$environment" "$image_type" "$zone")
    local overlay_instance_file="${overlay_template_file%$overlay_template_extension}${overlay_instance_extension}"

    # If the overlay template file exists, replace 'GCE_DISK_ID' with the actual GCE disk ID in the overlay template file and use the output to overwrite the overlay instance file
    if [ -f "$overlay_template_file" ]; then
        sed "s/GCE_DISK_ID/${gce_disk_id}/g" "$overlay_template_file" > "$overlay_instance_file"
    fi
}
# The following function updates all images overlays for the given environment, based on the terraform outputs as 'latest images' for a given product.
# Keep in mind that the meaning of 'environment' is different from the point of view of the infrastructure and the Kubernetes overlays, i.e. the environment in the infrastructure is the purpose environment (development, staging and production) while, for the kubernetes definition of the platform, those three environments are duplicated as per the number of products
# TODO A need for reconciliation of these two approaches has been identified

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
        if [[ "$product" == "$product_platform" ]]; then
            if [[ "$image_type" == "$image_type_clickhouse" ]]; then
                add_image "${path_base_images}/${platform_image_file_clickhouse}" "$image_name"
            elif [[ "$image_type" == "$image_type_opensearch" ]]; then
                add_image "${path_base_images}/${platform_image_file_opensearch}" "$image_name"
            fi
        elif [[ "$product" == "$product_ppp" ]]; then
            if [[ "$image_type" == "$image_type_clickhouse" ]]; then
                add_image "${path_base_images}/${ppp_image_file_clickhouse}" "$image_name"
            elif [[ "$image_type" == "$image_type_opensearch" ]]; then
                add_image "${path_base_images}/${ppp_image_file_opensearch}" "$image_name"
            fi
        fi
        ;;
    remove_image)
        if [[ "$product" == "$product_platform" ]]; then
            if [[ "$image_type" == "$image_type_clickhouse" ]]; then
                remove_image "${path_base_images}/${platform_image_file_clickhouse}" "$image_name"
            elif [[ "$image_type" == "$image_type_opensearch" ]]; then
                remove_image "${path_base_images}/${platform_image_file_opensearch}" "$image_name"
            fi
        elif [[ "$product" == "$product_ppp" ]]; then
            if [[ "$image_type" == "$image_type_clickhouse" ]]; then
                remove_image "${path_base_images}/${ppp_image_file_clickhouse}" "$image_name"
            elif [[ "$image_type" == "$image_type_opensearch" ]]; then
                remove_image "${path_base_images}/${ppp_image_file_opensearch}" "$image_name"
            fi
        fi
        ;;
    pop_image)
        if [[ "$product" == "$product_platform" ]]; then
            if [[ "$image_type" == "$image_type_clickhouse" ]]; then
                pop_image "${path_base_images}/${platform_image_file_clickhouse}"
            elif [[ "$image_type" == "$image_type_opensearch" ]]; then
                pop_image "${path_base_images}/${platform_image_file_opensearch}"
            fi
        elif [[ "$product" == "$product_ppp" ]]; then
            if [[ "$image_type" == "$image_type_clickhouse" ]]; then
                pop_image "${path_base_images}/${ppp_image_file_clickhouse}"
            elif [[ "$image_type" == "$image_type_opensearch" ]]; then
                pop_image "${path_base_images}/${ppp_image_file_opensearch}"
            fi
        fi
        ;;
list_images)
        if [[ "$product" == "$product_platform" ]]; then
            if [[ "$image_type" == "$image_type_clickhouse" ]]; then
                list_images "${path_base_images}/${platform_image_file_clickhouse}"
            elif [[ "$image_type" == "$image_type_opensearch" ]]; then
                list_images "${path_base_images}/${platform_image_file_opensearch}"
            fi
        elif [[ "$product" == "$product_ppp" ]]; then
            if [[ "$image_type" == "$image_type_clickhouse" ]]; then
                list_images "${path_base_images}/${ppp_image_file_clickhouse}"
            elif [[ "$image_type" == "$image_type_opensearch" ]]; then
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