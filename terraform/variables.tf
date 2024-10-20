variable "ssh_user" {
  description = "SSH user to use for the VM"
  type        = string
  default     = "AnsibleUser"
}

variable "ssh_key" {
  description = "SSH key to use for the VM"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "resource_group_name" {
  description = "Resource group name of the DevTest Lab"
  type        = string
  default     = "t-clo-901-nts-0"
}

variable "lab_subnet_name" {
  description = "Name of the subnet in the lab's virtual network"
  type        = string
  default     = "t-clo-901-nts-0Subnet"
}
