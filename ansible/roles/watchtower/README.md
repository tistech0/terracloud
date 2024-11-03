# Watchtower Role

## Description
Installs and configures Watchtower for automatic Docker container updates.

## Requirements
- Docker installed (dependency)
- Ansible 2.9 or higher

## Required Variables
- `watchtower_user`: Watchtower user (defined in inventory)
- `watched_repo`: Docker image to watch and update

## Role Variables
See defaults/main.yml for all variables:
- `watchtower_interval`: Check interval in seconds
- `watchtower_container_name`: Name for Watchtower container
- `watchtower_image`: Watchtower Docker image
- `app_container_port`: Port for the application container

## Dependencies
- Docker role

## Usage
```yaml
- hosts: application_hosts
  roles:
    - role: watchtower
      vars:
        watched_repo: "your/image:tag"