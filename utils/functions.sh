#!/bin/bash

# Fonction pour afficher des messages en couleur
print_color() {
    local color=$1
    local message=$2
    case $color in
        "red") echo -e "\033[0;31m$message\033[0m" >&2 ;;
        "green") echo -e "\033[0;32m$message\033[0m" >&2 ;;
        "yellow") echo -e "\033[0;33m$message\033[0m" >&2 ;;
        "blue") echo -e "\033[0;34m$message\033[0m" >&2 ;;
        *) echo "$message" >&2 ;;
    esac
}

# Fonction pour obtenir l'adresse IP publique
get_public_ip() {
    local vm_name=$1
    local ip_name="${vm_name}"
    
    IP_ADDRESS=$(az network public-ip show --resource-group "$ITEMS_RESOURCE_GROUP" --name "$ip_name" --query ipAddress -o tsv 2>/dev/null)
    
    if [ -n "$IP_ADDRESS" ]; then
        echo "$IP_ADDRESS"
        return 0
    else
        log "WARN" "Adresse IP publique non trouvée pour $vm_name"
        return 1
    fi
}

# Fonction pour revendiquer la VM
claim_vm() {
    local vm_name=$1
    log "INFO" "Tentative de revendication de la VM $vm_name..."
    CLAIM_RESULT=$(az lab vm claim --resource-group "$LAB_RESOURCE_GROUP" --lab-name "$LAB_NAME" --name "$vm_name" -o json 2>&1)
    
    if [ $? -eq 0 ]; then
        log "INFO" "VM $vm_name revendiquée avec succès."
        return 0
    else
        log "WARN" "Échec de la revendication de la VM $vm_name. Erreur : $CLAIM_RESULT"
        return 1
    fi
}

# Function to run Ansible playbook with vault password
run_playbook() {
    local playbook=$1
    log "INFO" "Executing Ansible playbook $playbook..."
    ansible-playbook -i inventory.ini "$playbook" --vault-password-file="$VAULT_PASS_FILE" -v
}

log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    case $level in
        "ERROR")
            echo -e "[$timestamp] \033[0;31mERROR:\033[0m $message"
            ;;
        "WARN")
            echo -e "[$timestamp] \033[0;33mWARN:\033[0m $message"
            ;;
        "INFO")
            echo -e "[$timestamp] \033[0;34mINFO:\033[0m $message"
            ;;
        "SUCCESS")
            echo -e "[$timestamp] \033[0;32mSUCCESS:\033[0m $message"
            ;;
        *)
            echo "[$timestamp] $level: $message"
            ;;
    esac
}

format_duration() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local remaining_seconds=$((seconds % 60))
    echo "${minutes}m ${remaining_seconds}s"
}

# Fonction pour exporter les données Terraform
export_terraform_data() {
    log "INFO" "Setting up environment variables..."
    
    # Configuration des VMs
    export BDD_VM_NAME="ubuntu-vm-nts-0-bdd"
    export MONITORING_VM_NAME="ubuntu-vm-nts-0-monitoring"
    export APPLICATION_VM_NAME="ubuntu-vm-nts-0-application"
    
    # Configuration des FQDNs (à adapter selon vos besoins)
    export BDD_FQDN="${BDD_VM_NAME}.westeurope.cloudapp.azure.com"
    export MONITORING_FQDN="${MONITORING_VM_NAME}.westeurope.cloudapp.azure.com"
    export APPLICATION_FQDN="${APPLICATION_VM_NAME}.westeurope.cloudapp.azure.com"
    
    # Variables dérivées
    export VM_NAMES="$BDD_VM_NAME $MONITORING_VM_NAME $APPLICATION_VM_NAME"
    export VM_FQDNS="$BDD_FQDN $MONITORING_FQDN $APPLICATION_FQDN"
    export LAB_NAME="t-clo-901-nts-0"
    export LAB_RESOURCE_GROUP="$LAB_NAME"
    export ITEMS_RESOURCE_GROUP="${LAB_RESOURCE_GROUP}-items"
    
    # Claim VMs and get their IPs
    for VM_NAME in $VM_NAMES; do
        log "INFO" "Processing VM: $VM_NAME"
        
        # Claim the VM
        claim_vm "$VM_NAME"
        
        # Get the public IP
        local PUBLIC_IP=$(get_public_ip "$VM_NAME")
        log "INFO" "Public IP for $VM_NAME: $PUBLIC_IP"
        
        # Export IP based on VM type
        if [[ $VM_NAME == *"bdd"* ]]; then
            export BDD_PUBLIC_IP="$PUBLIC_IP"
        elif [[ $VM_NAME == *"monitoring"* ]]; then
            export MONITORING_PUBLIC_IP="$PUBLIC_IP"
        elif [[ $VM_NAME == *"application"* ]]; then
            export APPLICATION_PUBLIC_IP="$PUBLIC_IP"
        fi
    done
    
    # Sauvegarder les variables dans un fichier
    cat > "./env_vars.sh" << EOF
export BDD_VM_NAME="$BDD_VM_NAME"
export MONITORING_VM_NAME="$MONITORING_VM_NAME"
export APPLICATION_VM_NAME="$APPLICATION_VM_NAME"
export BDD_FQDN="$BDD_FQDN"
export MONITORING_FQDN="$MONITORING_FQDN"
export APPLICATION_FQDN="$APPLICATION_FQDN"
export VM_NAMES="$VM_NAMES"
export VM_FQDNS="$VM_FQDNS"
export LAB_NAME="$LAB_NAME"
export LAB_RESOURCE_GROUP="$LAB_RESOURCE_GROUP"
export ITEMS_RESOURCE_GROUP="$ITEMS_RESOURCE_GROUP"
export BDD_PUBLIC_IP="$BDD_PUBLIC_IP"
export MONITORING_PUBLIC_IP="$MONITORING_PUBLIC_IP"
export APPLICATION_PUBLIC_IP="$APPLICATION_PUBLIC_IP"
EOF

    # Source le fichier pour s'assurer que les variables sont disponibles
    source ./env_vars.sh
    
    # Display all exported variables
    log "INFO" "Exported Environment Variables:"
    log "INFO" "----------------------------------------"
    log "INFO" "BDD_VM_NAME=$BDD_VM_NAME"
    log "INFO" "BDD_PUBLIC_IP=$BDD_PUBLIC_IP"
    log "INFO" "BDD_FQDN=$BDD_FQDN"
    log "INFO" "MONITORING_VM_NAME=$MONITORING_VM_NAME"
    log "INFO" "MONITORING_PUBLIC_IP=$MONITORING_PUBLIC_IP"
    log "INFO" "MONITORING_FQDN=$MONITORING_FQDN"
    log "INFO" "APPLICATION_VM_NAME=$APPLICATION_VM_NAME"
    log "INFO" "APPLICATION_PUBLIC_IP=$APPLICATION_PUBLIC_IP"
    log "INFO" "APPLICATION_FQDN=$APPLICATION_FQDN"
    log "INFO" "VM_NAMES=$VM_NAMES"
    log "INFO" "VM_FQDNS=$VM_FQDNS"
    log "INFO" "LAB_NAME=$LAB_NAME"
    log "INFO" "LAB_RESOURCE_GROUP=$LAB_RESOURCE_GROUP"
    log "INFO" "ITEMS_RESOURCE_GROUP=$ITEMS_RESOURCE_GROUP"
    log "INFO" "----------------------------------------"
    
    log "SUCCESS" "Environment variables set successfully"
    return 0
}

display_deployment_info() {
    log "INFO" "----------------------------------------"
    log "INFO" "Deployment Information"
    log "INFO" "----------------------------------------"
    
    if [ -f ./env_vars.sh ]; then
        source ./env_vars.sh
    else
        log "ERROR" "Environment variables file not found"
        cd - > /dev/null
        return 1
    fi
    
    # Afficher les informations générales du Lab
    log "SUCCESS" "Lab Configuration:"
    log "SUCCESS" "Lab Name: $LAB_NAME"
    log "SUCCESS" "Lab Resource Group: $LAB_RESOURCE_GROUP"
    log "SUCCESS" "Items Resource Group: $ITEMS_RESOURCE_GROUP"
    log "INFO" "----------------------------------------"
    
    # Afficher les informations de toutes les VMs
    log "SUCCESS" "VMs Configuration:"
    log "SUCCESS" "VM Names: $VM_NAMES"
    log "INFO" "----------------------------------------"
    
    # Afficher les informations détaillées pour chaque VM
    log "SUCCESS" "Database Server (BDD):"
    log "SUCCESS" "- Name: $BDD_VM_NAME"
    log "SUCCESS" "- IP: $BDD_PUBLIC_IP"
    log "SUCCESS" "- FQDN: $BDD_FQDN"
    log "INFO" "----------------------------------------"
    
    log "SUCCESS" "Monitoring Server:"
    log "SUCCESS" "- Name: $MONITORING_VM_NAME"
    log "SUCCESS" "- IP: $MONITORING_PUBLIC_IP"
    log "SUCCESS" "- Graphana url: http://$MONITORING_PUBLIC_IP:3000"
    log "SUCCESS" "- FQDN: $MONITORING_FQDN"
    log "INFO" "----------------------------------------"
    
    log "SUCCESS" "Application Server:"
    log "SUCCESS" "- Name: $APPLICATION_VM_NAME"
    log "SUCCESS" "- IP: $APPLICATION_PUBLIC_IP"
    log "SUCCESS" "- FQDN: $APPLICATION_FQDN"
    log "INFO" "----------------------------------------"
    
    return 0
}

create_ansible_inventory() {
    log "INFO" "Creating Ansible inventory"
    
    # Create ansible directory if needed
    local ansible_dir="../ansible"
    mkdir -p "$ansible_dir"
    local inventory_file="$ansible_dir/inventory.ini"
    local template_file="$ansible_dir/inventory.template"
    # Process template with envsubst
    log "INFO" "Generating inventory from template..."
    if envsubst < "$template_file" > "$inventory_file"; then
        log "SUCCESS" "Ansible inventory created successfully at $inventory_file"
        return 0
    else
        log "ERROR" "Failed to create Ansible inventory"
        return 1
    fi
}

verify_ansible_playbooks() {
    local missing_playbooks=()

    for playbook in "${PLAYBOOKS[@]}"; do
        if [ ! -f "$ANSIBLE_DIR/playbooks/$playbook" ]; then
            missing_playbooks+=("$playbook")
        fi
    done
    
    if [ ${#missing_playbooks[@]} -ne 0 ]; then
        log "ERROR" "Missing playbooks: ${missing_playbooks[*]}"
        return 1
    fi
    
    log "INFO" "All required playbooks are present"
    return 0
}

verify_ansible_roles() {
    local roles=("docker" "mysql" "prometheus" "grafana" "watchtower")
    local missing_roles=()
    
    for role in "${roles[@]}"; do
        if [ ! -d "$ANSIBLE_DIR/roles/$role" ]; then
            missing_roles+=("$role")
        fi
    done
    
    if [ ${#missing_roles[@]} -ne 0 ]; then
        log "ERROR" "Missing Ansible roles: ${missing_roles[*]}"
        return 1
    fi
    
    log "INFO" "All required Ansible roles are present"
    return 0
}
