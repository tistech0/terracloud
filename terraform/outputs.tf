output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "frontend_lb_ip" {
  value = azurerm_public_ip.frontend_lb_pip.ip_address
}

output "frontend_vm_private_ips" {
  value = azurerm_network_interface.frontend_nic[*].private_ip_address
}

output "backend_vm_private_ips" {
  value = azurerm_network_interface.backend_nic[*].private_ip_address
}

output "database_vm_private_ip" {
  value = azurerm_network_interface.database_nic.private_ip_address
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_pip.ip_address
}