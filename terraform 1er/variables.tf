# Azure Authentication Variables
variable "ARM_CLIENT_ID" {
  type        = string
  description = "The Client ID for the Service Principal"
}

variable "ARM_CLIENT_SECRET" {
  type        = string
  description = "The Client Secret for the Service Principal"
  sensitive   = true
}

variable "ARM_SUBSCRIPTION_ID" {
  type        = string
  description = "The Subscription ID for the Azure account"
}

variable "ARM_TENANT_ID" {
  type        = string
  description = "The Tenant ID for the Azure account"
}

# Project Variables
variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "terracloud"
}

variable "environment" {
  type        = string
  description = "Environment (dev, test, prod)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region to deploy resources"
  default     = "France Central"
}

# Network Variables
variable "admin_ip" {
  type        = string
  description = "IP address allowed for SSH access"
  default     = "10.84.108.208"
}

# Compute Variables
variable "ssh_public_key" {
  type        = string
  description = "The public SSH key for VM access"
}

variable "frontend_vm_count" {
  type        = number
  description = "Number of frontend VMs to create"
  default     = 2
}

variable "backend_vm_count" {
  type        = number
  description = "Number of backend VMs to create"
  default     = 2
}

variable "vm_size" {
  type        = string
  description = "Size of the VMs"
  default     = "Standard_B1ls"
}

variable "admin_username" {
  type        = string
  description = "Admin username for VMs"
  default     = "adminuser"
}