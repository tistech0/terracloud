# Reference the existing DevTest Lab
data "azurerm_dev_test_lab" "lab" {
  name                = var.resource_group_name
  resource_group_name = var.resource_group_name
}

# Get the lab's virtual network
data "azurerm_dev_test_virtual_network" "lab_network" {
  name                = var.resource_group_name
  lab_name            = data.azurerm_dev_test_lab.lab.name
  resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
}

module "bdd" {
  source = "./modules/compute"

  name                    = "ubuntu-vm-nts-0-bdd"
  lab_name                = data.azurerm_dev_test_lab.lab.name
  lab_resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
  lab_virtual_network_id  = data.azurerm_dev_test_virtual_network.lab_network.id
  lab_subnet_name         = var.lab_subnet_name
  ssh_user                = var.ssh_user
  ssh_key                 = var.ssh_key
}

module "application" {
  source = "./modules/compute"

  name                    = "ubuntu-vm-nts-0-application"
  lab_name                = data.azurerm_dev_test_lab.lab.name
  lab_resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
  lab_virtual_network_id  = data.azurerm_dev_test_virtual_network.lab_network.id
  lab_subnet_name         = var.lab_subnet_name
  ssh_user                = var.ssh_user
  ssh_key                 = var.ssh_key
}

module "monitoring" {
  source = "./modules/compute"

  name                    = "ubuntu-vm-nts-0-monitoring"
  lab_name                = data.azurerm_dev_test_lab.lab.name
  lab_resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
  lab_virtual_network_id  = data.azurerm_dev_test_virtual_network.lab_network.id
  lab_subnet_name         = var.lab_subnet_name
  ssh_user                = var.ssh_user
  ssh_key                 = var.ssh_key
}
