output "vm_names" {
  value = [
    module.bdd.vm_name,
    module.monitoring.vm_name,
    module.application.vm_name
  ]
}

output "vm_fqdns" {
  value = [
    module.bdd.vm_fqdn,
    module.monitoring.vm_fqdn,
    module.application.vm_fqdn
  ]
}

output "vm_unique_identifiers" {
  value = [
    module.bdd.vm_unique_identifier,
    module.monitoring.vm_unique_identifier,
    module.application.vm_unique_identifier
  ]
}

output "vm_ids" {
  value = [
    module.bdd.vm_id,
    module.monitoring.vm_id,
    module.application.vm_id
  ]
}

output "resource_group_name" {
  value = module.bdd.resource_group_name
}

output "lab_name" {
  value = module.bdd.lab_name
}