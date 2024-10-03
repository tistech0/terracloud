variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  type        = map(string)
}

variable "frontend_vm_count" {
  description = "Number of frontend VMs to create"
  type        = number
  default     = 2
}

variable "backend_vm_count" {
  description = "Number of backend VMs to create"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "The size of the virtual machines"
  type        = string
  default     = "Standard_B1ls"
}

variable "admin_username" {
  description = "The admin username for the VMs"
  type        = string
  default     = "adminuser"
}

variable "ssh_public_key" {
  description = "The public SSH key for the VMs"
  type        = string
}
