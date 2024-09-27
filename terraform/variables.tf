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

variable "admin_ip" {
  type        = string
  description = "IP address allowed for SSH access"
  default     = "10.84.108.208"
}

variable "ssh_public_key" {
  type        = string
  description = "The public SSH key for VM access"
}