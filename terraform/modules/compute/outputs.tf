output "frontend_vm_ids" {
  description = "The IDs of the frontend VMs"
  value       = azurerm_linux_virtual_machine.frontend_vm[*].id
}

output "backend_vm_ids" {
  description = "The IDs of the backend VMs"
  value       = azurerm_linux_virtual_machine.backend_vm[*].id
}

output "database_vm_id" {
  description = "The ID of the database VM"
  value       = azurerm_linux_virtual_machine.database_vm.id
}

output "frontend_nic_ids" {
  description = "The IDs of the frontend NICs"
  value       = azurerm_network_interface.frontend_nic[*].id
}

output "backend_nic_ids" {
  description = "The IDs of the backend NICs"
  value       = azurerm_network_interface.backend_nic[*].id
}

output "database_nic_id" {
  description = "The ID of the database NIC"
  value       = azurerm_network_interface.database_nic.id
}