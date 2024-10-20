variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "lab_name" {
  description = "Name of the DevTest Lab"
  type        = string
}

variable "lab_resource_group_name" {
  description = "Resource group name of the DevTest Lab"
  type        = string
}

variable "lab_virtual_network_id" {
  description = "ID of the lab's virtual network"
  type        = string
}

variable "lab_subnet_name" {
  description = "Name of the subnet in the lab's virtual network"
  type        = string
}

variable "ssh_user" {
  description = "SSH user to use for the VM"
  type        = string
}

variable "ssh_key" {
  description = "SSH key to use for the VM"
  type        = string
}

