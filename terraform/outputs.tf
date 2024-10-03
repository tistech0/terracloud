output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_id" {
  value = module.networking.vnet_id
}

output "frontend_lb_public_ip" {
  value = module.load_balancers.frontend_lb_ip
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "frontend_vm_ids" {
  value = module.compute.frontend_vm_ids
}

output "backend_vm_ids" {
  value = module.compute.backend_vm_ids
}