#!/bin/bash
set -e

source ../utils/functions.sh

log "INFO" "Starting Terraform deployment"

# Cleanup and initialize Terraform
log "INFO" "Cleaning Terraform state"
rm -rf .terraform* terraform.tfstate*

# Initialize and validate Terraform
log "INFO" "Initializing Terraform"
terraform init

log "INFO" "Running Terraform plan"
terraform plan -out=tfplan || {
    log "ERROR" "Terraform plan failed"
    exit 1
}

log "INFO" "Running Terraform apply"
terraform apply tfplan || {
    log "ERROR" "Terraform apply failed"
    exit 1
}

# Export Terraform data
log "INFO" "Exporting deployment data"
export_terraform_data || {
    log "ERROR" "Failed to export deployment data"
    exit 1
}

# Create Ansible inventory
log "INFO" "Creating Ansible inventory"
create_ansible_inventory || {
    log "ERROR" "Failed to create Ansible inventory"
    exit 1
}

log "SUCCESS" "Terraform deployment completed successfully"