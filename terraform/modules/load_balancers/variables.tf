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

variable "frontend_nic_ids" {
  description = "List of frontend NIC IDs"
  type        = list(string)
}

variable "backend_nic_ids" {
  description = "List of backend NIC IDs"
  type        = list(string)
}
