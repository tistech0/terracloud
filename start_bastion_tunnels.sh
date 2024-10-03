#!/bin/bash

RESOURCE_GROUP="rg-terracloud-dev"
BASTION_NAME="bastion-host"
USERNAME="adminuser"
SSH_KEY_PATH="$HOME/.ssh/id_rsa"  # chemin de la clef ssh

start_bastion_tunnel() {
    local vm_name=$1
    local port=$2
    
    echo "Starting tunnel for $vm_name on local port $port"
    
    az network bastion tunnel \
        --name "$BASTION_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --target-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$vm_name" \
        --resource-port 22 \
        --port $port &
}

# Liste des vm
vm_list=$(az vm list -g "$RESOURCE_GROUP" --query "[].name" -o tsv)

port=50022

for vm in $vm_list
do
    start_bastion_tunnel "$vm" "$port"
    ((port++))
done

echo "All tunnels started. Use 'ssh -p PORT $USERNAME@localhost' to connect."
echo "Press Ctrl+C to close all tunnels."

read -p "Press Enter to exit and close all tunnels..."

# Kill tous les tunnels en cas d'interruption du script
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT