output "vm_name" {
  value = azurerm_dev_test_linux_virtual_machine.vm.name
}

output "vm_fqdn" {
  value = azurerm_dev_test_linux_virtual_machine.vm.fqdn
}

output "vm_unique_identifier" {
  value = azurerm_dev_test_linux_virtual_machine.vm.unique_identifier
}

output "vm_id" {
  value = azurerm_dev_test_linux_virtual_machine.vm.id
}

output "resource_group_name" {
  value = var.lab_resource_group_name
}

output "lab_name" {
  value = var.lab_name
}