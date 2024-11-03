# Grafana Role

## Description
Installs and configures Grafana on Ubuntu systems.

## Requirements
- Ubuntu operating system
- Ansible 2.9 or higher
- Prometheus installed and accessible

## Required Variables
- `grafana_user`: Main Grafana user (defined in inventory)
- `grafana_admin_password`: Admin password for Grafana

## Role Variables
See defaults/main.yml for all variables:
- `grafana_version`: Grafana version to install
- `grafana_port`: Grafana web interface port
- `grafana_domain`: Domain name for Grafana
- `prometheus_url`: URL of the Prometheus server
- `grafana_dashboards`: List of dashboards to import

## Dependencies
- Prometheus server must be running and accessible

## Usage
```yaml
- hosts: monitoring_hosts
  roles:
    - role: grafana
      vars:
        grafana_admin_password: "your_secure_password"