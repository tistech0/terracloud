terraform {
  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  
  cloud {
    organization = "tcloud-901"
    workspaces {
      name = "terracloud"
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
}

# Networking Module
module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  project_name        = var.project_name
  environment         = var.environment
}

# Compute Module
module "compute" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  subnet_ids          = module.networking.subnet_ids
  frontend_vm_count   = var.frontend_vm_count
  backend_vm_count    = var.backend_vm_count
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
}

# Load Balancers Module
module "load_balancers" {
  source              = "./modules/load_balancers"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  subnet_ids          = module.networking.subnet_ids
  frontend_nic_ids    = module.compute.frontend_nic_ids
  backend_nic_ids     = module.compute.backend_nic_ids
}

# Bastion Module
module "bastion" {
  source              = "./modules/bastion"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  bastion_subnet_id   = module.networking.subnet_ids["bastion"]
}
