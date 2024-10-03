output "bastion_public_ip" {
  description = "The public IP address of the Bastion host"
  value       = azurerm_public_ip.bastion_pip.ip_address
}

output "bastion_host_id" {
  description = "The ID of the Bastion host"
  value       = azurerm_bastion_host.bastion.id
}

output "bastion_nsg_id" {
  description = "The ID of the Bastion NSG"
  value       = azurerm_network_security_group.bastion_nsg.id
}