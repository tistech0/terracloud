output "vm_names" {
  value = [
    module.bdd.vm_name,
    module.back.vm_name,
    module.front.vm_name
  ]
}

output "vm_fqdns" {
  value = [
    module.bdd.vm_fqdn,
    module.back.vm_fqdn,
    module.front.vm_fqdn
  ]
}

output "vm_unique_identifiers" {
  value = [
    module.bdd.vm_unique_identifier,
    module.back.vm_unique_identifier,
    module.front.vm_unique_identifier
  ]
}

output "vm_ids" {
  value = [
    module.bdd.vm_id,
    module.back.vm_id,
    module.front.vm_id
  ]
}

output "resource_group_name" {
  value = module.bdd.resource_group_name
}

output "lab_name" {
  value = module.bdd.lab_name
}