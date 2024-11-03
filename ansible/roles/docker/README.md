# Docker Role

## Description
Installs and configures Docker on Ubuntu systems.

## Requirements
- Ubuntu operating system
- Ansible 2.9 or higher

## Required Variables
- `docker_user`: Main Docker user (defined in inventory)
- `ansible_user`: Ansible control user (defined in inventory)

## Role Variables
See defaults/main.yml for all variables:
- `docker_package_name`: Docker package to install (default: docker-ce)
- `docker_users`: List of users to add to docker group
- `docker_daemon_config`: Docker daemon configuration

## Usage
```yaml
- hosts: global_hosts
  roles:
    - role: docker
      vars:
        docker_users:
          - "{{ docker_user }}"
          - "{{ ansible_user }}"