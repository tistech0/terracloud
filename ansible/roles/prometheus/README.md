# Prometheus Role

## Description
Installs and configures Prometheus and Node Exporter on Ubuntu systems.

## Requirements
- Ubuntu operating system
- Ansible 2.9 or higher

## Required Variables
- `prometheus_user`: Main Prometheus user (defined in inventory)

## Role Variables
See defaults/main.yml for all variables:
- `prometheus_version`: Prometheus version to install
- `node_exporter_version`: Node Exporter version to install
- `prometheus_config_path`: Configuration path
- `prometheus_data_path`: Data path
- `prometheus_port`: Prometheus port
- `node_exporter_port`: Node Exporter port

## Usage
```yaml
- hosts: global_hosts
  roles:
    - role: prometheus