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

module "vm1" {
  source = "./modules/compute"

  name                    = "ubuntu-vm-nts-0-lol"
  lab_name                = data.azurerm_dev_test_lab.lab.name
  lab_resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
  lab_virtual_network_id  = data.azurerm_dev_test_virtual_network.lab_network.id
  lab_subnet_name         = "t-clo-901-nts-0Subnet"
}

# module "vm2" {
#   source = "./modules/compute"

#   name                    = "ubuntu-vm-nts-0-2"
#   lab_name                = data.azurerm_dev_test_lab.lab.name
#   lab_resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
#   lab_virtual_network_id  = data.azurerm_dev_test_virtual_network.lab_network.id
#   lab_subnet_name         = "t-clo-901-nts-0Subnet"
# }