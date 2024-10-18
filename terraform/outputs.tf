output "vm_names" {
  value = [module.vm1.vm_name]
}

output "vm_fqdns" {
  value = [module.vm1.vm_fqdn]
}

output "vm_unique_identifiers" {
  value = [module.vm1.vm_unique_identifier]
}

output "vm_ids" {
  value = [module.vm1.vm_id]
}

output "resource_group_name" {
  value = module.vm1.resource_group_name
}

output "lab_name" {
  value = module.vm1.lab_name
}