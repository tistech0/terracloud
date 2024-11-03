#!/bin/bash

# Infrastructure settings
export LAB_NAME="t-clo-901-nts-0"
export LAB_RESOURCE_GROUP="t-clo-901-nts-0"
export ITEMS_RESOURCE_GROUP="t-clo-901-nts-0-item"
export ANSIBLE_USER="AnsibleUser"

# Paths
export TERRAFORM_DIR="./terraform"
export ANSIBLE_DIR="./ansible"
export INVENTORY_FILE="${ANSIBLE_DIR}/inventory.ini"

# Playbooks à exécuter dans l'ordre
export PLAYBOOKS=(
    "install_docker_role.yml"
    "install_mysql_role.yml"
    "install_prometheus_role.yml"
    "install_grafana_role.yml"
    "install_watchtower_role.yml"
)

# Timeout settings (en secondes)
export TERRAFORM_TIMEOUT=1800  # 30 minutes
export ANSIBLE_TIMEOUT=900     # 15 minutes

# Log settings
export LOG_DIR="./logs"
export LOG_LEVEL="INFO"  # ERROR, WARN, INFO, DEBUG

# Backup settings (si nécessaire)
export BACKUP_DIR="./backups"
export BACKUP_RETENTION_DAYS=7