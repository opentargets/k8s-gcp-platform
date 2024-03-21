#!/bin/bash

# Configuration
cluster_info_dir="./.microk8s-cluster"
mkdir -p "$cluster_info_dir"
vm_names_file="$cluster_info_dir/vm-names"

# Default parameter values
n=3
c=4
m="8Gb"
d="50G"

# Parse command-line arguments for create
parse_args() {
  while getopts ":n:c:m:d:" opt; do
    case ${opt} in
      n ) n=$OPTARG ;;
      c ) c=$OPTARG ;;
      m ) m=$OPTARG ;;
      d ) d=$OPTARG ;;
      \? ) echo "Usage: cmd [-n] number_of_nodes [-c] cpus_per_node [-m] memory_per_node [-d] disk_size_per_node"; return 1 ;;
    esac
  done
}

# Create and setup the microk8s cluster
create_cluster() {
  parse_args "$@"
  
  # Create and setup the master node
  echo "Creating the master node with $c CPUs, $m memory, and $d disk..."
  multipass launch --name microk8s-master --cpus $c --mem $m --disk $d
  multipass exec microk8s-master -- sudo snap install microk8s --classic
  
  declare -a pids # Array to keep track of process IDs

  # Create and setup worker nodes in parallel
  for i in $(seq 1 $n); do
    {
      worker_name="microk8s-node-$i"
      echo "Creating $worker_name with $c CPUs, $m memory, and $d disk..."
      multipass launch --name "$worker_name" --cpus $c --mem $m --disk $d
      echo "$worker_name" >> "$vm_names_file"
      multipass exec "$worker_name" -- sudo snap install microk8s --classic
      
      # Retrieve and execute the microk8s join command for each worker node
      echo "Joining $worker_name to the cluster..."
      join_cmd=$(multipass exec microk8s-master -- sudo microk8s add-node | grep "microk8s join" | sed 's/^ *//')
      multipass exec "$worker_name" -- sudo $join_cmd
      echo "$worker_name has joined the cluster."
    } & # Run in background
    
    pids+=($!) # Store the process ID of the background process
  done

  # Wait for all worker nodes to be set up
  for pid in "${pids[@]}"; do
      wait $pid
  done
  
  # Add the master node to the VM names file, at the end of the file, so it is destroyed the last
  echo "microk8s-master" >> "$vm_names_file"
  echo "All worker nodes have been created and joined the cluster."
  
  # Wait for the cluster to be ready
  echo "Waiting for the cluster to become ready..."
  multipass exec microk8s-master -- sudo microk8s status --wait-ready
  
  # Fetch the kubeconfig file
  echo "Configuring kubectl to use the microk8s cluster..."
  multipass exec microk8s-master -- sudo microk8s config > ~/.kube/config
  
  echo "Microk8s cluster setup is complete."
}

# Delete the microk8s cluster
delete_cluster() {
  if [ ! -f "$vm_names_file" ]; then
    echo "VM names file does not exist. Cannot delete cluster."
    exit 1
  fi

  declare -a pids # Array to keep track of process IDs

  while IFS= read -r vm_name; do
    {
      # Stop the cluster services in the node, and then delete the node
      echo "Stopping microk8s services in $vm_name..."
      multipass exec "$vm_name" -- sudo microk8s stop
      echo "Deleting $vm_name..."
      multipass delete "$vm_name" && multipass purge
      echo "$vm_name has been deleted."
    } & # Run in background
    
    pids+=($!) # Store the process ID of the background process
  done < "$vm_names_file"

  # Wait for all deletions to complete
  for pid in "${pids[@]}"; do
      wait $pid
  done

  # Optionally, remove the VM names file after deletion
  rm -f "$vm_names_file"

  echo "Cluster deletion is complete."
}





# Delete the microk8s cluster
delete_cluster() {
  if [ ! -f "$vm_names_file" ]; then
    echo "No cluster information found. Exiting..."
    return 1
  fi
  
  while read -r vm_name; do
    echo "Deleting VM: $vm_name"
    multipass delete "$vm_name"
    multipass purge
  done < "$vm_names_file"
  
  # Clean up
  rm -f "$vm_names_file"
  echo "Cluster and related VMs have been deleted."
}

# Main logic
case "$1" in
  create)
    shift
    create_cluster "$@"
    ;;
  delete)
    delete_cluster
    ;;
  *)
    echo "Usage: $0 {create|delete} [OPTIONS]"
    echo "Options for create:"
    echo "  -n [number_of_nodes] -c [cpus_per_node] -m [memory_per_node] -d [disk_size_per_node]"
    exit 1
    ;;
esac
