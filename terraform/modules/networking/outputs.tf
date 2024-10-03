output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  value = {
    frontend = azurerm_subnet.frontend.id
    backend  = azurerm_subnet.backend.id
    database = azurerm_subnet.database.id
    bastion  = azurerm_subnet.bastion.id
  }
}

output "nsg_ids" {
  description = "Map of NSG names to NSG IDs"
  value = {
    frontend = azurerm_network_security_group.frontend_nsg.id
    backend  = azurerm_network_security_group.backend_nsg.id
    database = azurerm_network_security_group.database_nsg.id
  }
}