variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "bastion_subnet_id" {
  description = "The ID of the Bastion subnet"
  type        = string
}