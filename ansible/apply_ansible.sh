#!/bin/bash
set -e

# Obtenir les chemins absolus
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

source "$PROJECT_ROOT/utils/functions.sh"
source "$PROJECT_ROOT/config.sh"

# Vérifier que les playbooks sont bien définis
if [ ${#PLAYBOOKS[@]} -eq 0 ]; then
    log "ERROR" "No playbooks defined in PLAYBOOKS array"
    log "INFO" "Current directory: $(pwd)"
    log "INFO" "Content of config.sh:"
    cat "$PROJECT_ROOT/config.sh"
    exit 1
fi

# Install required collections
log "INFO" "Installing required Ansible collections"
ansible-galaxy collection install community.grafana
ansible-galaxy install geerlingguy.docker
ansible-galaxy collection install community.docker

# Handle vault password
log "INFO" "Setting up Ansible vault"
VAULT_PASS_FILE=$(mktemp)
trap 'rm -f "$VAULT_PASS_FILE"' EXIT

log "WARN" "Please enter the Ansible Vault password:"
read -s VAULT_PASS
echo "$VAULT_PASS" > "$VAULT_PASS_FILE"

# Debug: Afficher les informations sur les playbooks
log "INFO" "Nombre de playbooks à exécuter: ${#PLAYBOOKS[@]}"
log "INFO" "Liste des playbooks:"
for playbook in "${PLAYBOOKS[@]}"; do
    echo "  - $playbook"
done

# Execute playbooks
log "INFO" "Starting playbook execution with roles"
for playbook in "${PLAYBOOKS[@]}"; do
    playbook_path="$SCRIPT_DIR/playbooks/$playbook"
    
    if [ ! -f "$playbook_path" ]; then
        log "ERROR" "Playbook not found: $playbook_path"
        log "INFO" "Current directory: $(pwd)"
        log "INFO" "Directory content:"
        ls -R
        exit 1
    fi

    log "INFO" "Executing playbook: $playbook_path"
    # Ajout de ANSIBLE_ROLES_PATH et utilisation des chemins absolus
    if ! ANSIBLE_ROLES_PATH="$SCRIPT_DIR/roles" ansible-playbook \
        -i "$SCRIPT_DIR/inventory.ini" \
        "$playbook_path" \
        --vault-password-file="$VAULT_PASS_FILE" \
        -v; then
        log "ERROR" "Failed to execute $playbook"
        exit 1
    fi
    log "SUCCESS" "Playbook $playbook executed successfully"
done

log "SUCCESS" "All Ansible playbooks executed successfully"