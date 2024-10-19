terraform {
  backend "azurerm" {
    resource_group_name  = "t-clo-901-nts-0"
    storage_account_name = "atclo901nts03632"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

# Reference the existing DevTest Lab
data "azurerm_dev_test_lab" "lab" {
  name                = "t-clo-901-nts-0"
  resource_group_name = "t-clo-901-nts-0"
}

# Get the lab's virtual network
data "azurerm_dev_test_virtual_network" "lab_network" {
  name                = "t-clo-901-nts-0"
  lab_name            = data.azurerm_dev_test_lab.lab.name
  resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
}

module "bdd" {
  source = "./modules/compute"

  name                    = "ubuntu-vm-nts-0-bdd"
  lab_name                = data.azurerm_dev_test_lab.lab.name
  lab_resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
  lab_virtual_network_id  = data.azurerm_dev_test_virtual_network.lab_network.id
  lab_subnet_name         = "t-clo-901-nts-0Subnet"
}

module "back" {
  source = "./modules/compute"

  name                    = "ubuntu-vm-nts-0-back"
  lab_name                = data.azurerm_dev_test_lab.lab.name
  lab_resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
  lab_virtual_network_id  = data.azurerm_dev_test_virtual_network.lab_network.id
  lab_subnet_name         = "t-clo-901-nts-0Subnet"
}

module "front" {
  source = "./modules/compute"

  name                    = "ubuntu-vm-nts-0-front"
  lab_name                = data.azurerm_dev_test_lab.lab.name
  lab_resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
  lab_virtual_network_id  = data.azurerm_dev_test_virtual_network.lab_network.id
  lab_subnet_name         = "t-clo-901-nts-0Subnet"
}