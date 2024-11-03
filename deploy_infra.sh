#!/bin/bash

###########################################
# Main deployment script for infrastructure
# Prerequisites:
#   - Azure CLI installed and configured
#   - Terraform installed
#   - Ansible installed
#   - SSH key pair configured
###########################################

# Enable exit on error and undefined variables
set -euo pipefail

# Import configuration and functions first
for file in "./config.sh" "./utils/functions.sh"; do
    if [ -f "$file" ]; then
        source "$file"
    else
        echo "Error: $file not found"
        exit 1
    fi
done

# Display help message
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -t, --terraform   Run only Terraform deployment"
    echo "  -a, --ansible     Run only Ansible configuration"
    echo "  -d, --destroy     Destroy the Terraform infrastructure"
    echo
    echo "If no options are provided, both Terraform and Ansible will be executed"
    exit 0
}

# Parse command line arguments
TERRAFORM_ONLY=false
ANSIBLE_ONLY=false
DESTROY_INFRA=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -t|--terraform)
            TERRAFORM_ONLY=true
            shift
            ;;
        -a|--ansible)
            ANSIBLE_ONLY=true
            shift
            ;;
        -d|--destroy)
            DESTROY_INFRA=true
            shift
            ;;
        *)
            echo "ERROR: Unknown option: $1"
            show_help
            ;;
    esac
done

# Check for mutually exclusive options
if [[ "$TERRAFORM_ONLY" == true && "$ANSIBLE_ONLY" == true ]]; then
    echo "Error: Cannot specify both --terraform and --ansible options"
    show_help
fi

if [[ "$DESTROY_INFRA" == true && ("$TERRAFORM_ONLY" == true || "$ANSIBLE_ONLY" == true) ]]; then
    echo "Error: Destroy option cannot be combined with --terraform or --ansible"
    show_help
fi

# Import configuration and functions
for file in "./config.sh" "./utils/functions.sh"; do
    if [ -f "$file" ]; then
        source "$file"
    else
        echo "Error: $file not found"
        exit 1
    fi
done

# Initialize logging
setup_logging() {
    local log_file="deployment_$(date +%Y%m%d_%H%M%S).log"
    mkdir -p logs
    exec 1> >(tee -a "logs/$log_file")
    exec 2> >(tee -a "logs/$log_file" >&2)
    log "INFO" "Logging initialized to logs/$log_file"
}

# Cleanup function
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR" "Deployment failed with exit code $exit_code"
    fi
    log "INFO" "Cleanup completed"
}

# Validate prerequisites
validate_prerequisites() {
    log "INFO" "Validating prerequisites..."
    local required_commands=("az" "terraform" "ansible" "jq")
    for cmd in "${required_commands[@]}"; do
        log "INFO" "Checking for $cmd..."
        if ! command -v "$cmd" &> /dev/null; then
            log "ERROR" "$cmd is required but not installed"
            exit 1
        fi
    done
    log "SUCCESS" "All prerequisites validated"
}

# Infrastructure deployment
deploy_infrastructure() {
    log "INFO" "Starting infrastructure deployment..."
    if [ ! -d "$TERRAFORM_DIR" ] || [ ! -f "$TERRAFORM_DIR/apply_terraform.sh" ]; then
        log "ERROR" "Terraform directory or script not found"
        return 1
    fi
    
    chmod +x "$TERRAFORM_DIR/apply_terraform.sh"
    
    cd "$TERRAFORM_DIR"
    
    if ! ./apply_terraform.sh; then
        log "ERROR" "Terraform deployment failed"
        cd - > /dev/null
        return 1
    fi
    
    if [ -f ./env_vars.sh ]; then
        source ./env_vars.sh
    else
        log "ERROR" "Environment variables file not found"
        cd - > /dev/null
        return 1
    fi
    
    cd - > /dev/null
    
    log "SUCCESS" "Terraform deployment completed"
    return 0
}

# New function: Destroy infrastructure
destroy_infrastructure() {
    log "INFO" "Starting infrastructure destruction..."
    if [ ! -d "$TERRAFORM_DIR" ]; then
        log "ERROR" "Terraform directory not found"
        return 1
    fi
    
    cd "$TERRAFORM_DIR"
    
    # Demande de confirmation
    read -p "Are you sure you want to destroy the infrastructure? This action cannot be undone. (yes/no) " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        log "INFO" "Infrastructure destruction cancelled"
        cd - > /dev/null
        return 0
    fi
    
    log "INFO" "Proceeding with infrastructure destruction..."
    if ! terraform init; then
        log "ERROR" "Terraform initialization failed"
        cd - > /dev/null
        return 1
    fi
    
    if ! terraform destroy -auto-approve; then
        log "ERROR" "Terraform destruction failed"
        cd - > /dev/null
        return 1
    fi
    
    cd - > /dev/null
    
    log "SUCCESS" "Infrastructure successfully destroyed"
    return 0
}

configure_environment() {
    log "INFO" "Starting environment configuration..."
    if [ ! -d "$ANSIBLE_DIR" ] || [ ! -f "$ANSIBLE_DIR/apply_ansible.sh" ]; then
        log "ERROR" "Ansible directory or script not found"
        return 1
    fi
    
    if ! verify_ansible_roles || ! verify_ansible_playbooks; then
        log "ERROR" "Missing required Ansible files"
        return 1
    fi
    
    chmod +x "$ANSIBLE_DIR/apply_ansible.sh"
    if ! (cd "$ANSIBLE_DIR" && ./apply_ansible.sh); then
        log "ERROR" "Ansible configuration failed"
        return 1
    fi
    
    cd - > /dev/null
    
    log "SUCCESS" "Ansible configuration completed"
    return 0
}

# Main deployment function
main() {
    setup_logging
    
    local start_time=$(date +%s)
    log "INFO" "Starting deployment process"
    
    validate_prerequisites
    
    if [[ "$DESTROY_INFRA" == true ]]; then
        if ! destroy_infrastructure; then
            log "ERROR" "Infrastructure destruction failed"
            exit 1
        fi
    else
        if [[ "$ANSIBLE_ONLY" == false ]]; then
            if ! deploy_infrastructure; then
                log "ERROR" "Infrastructure deployment failed"
                exit 1
            fi
        fi
        
        if [[ "$TERRAFORM_ONLY" == false ]]; then
            if ! configure_environment; then
                log "ERROR" "Environment configuration failed"
                exit 1
            fi
        fi
        
        display_deployment_info
    fi
    
    local duration=$(($(date +%s) - start_time))
    log "SUCCESS" "Process completed in $(format_duration $duration)"
}

# Set the cleanup trap and execute main
trap cleanup EXIT
main