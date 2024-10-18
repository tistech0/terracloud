resource "azurerm_dev_test_linux_virtual_machine" "vm" {
  name                       = var.name
  lab_name                   = var.lab_name
  resource_group_name        = var.lab_resource_group_name
  location                   = "westeurope"

  size                       = "Standard_A4_v2"
  username                   = "azureuser"
  ssh_key                    = file("~/.ssh/id_rsa.pub")

  lab_virtual_network_id     = var.lab_virtual_network_id
  lab_subnet_name            = var.lab_subnet_name

  disallow_public_ip_address = false
  allow_claim = true
  
  storage_type               = "Standard"
  notes                      = "Ubuntu 22.04 LTS VM created with Terraform module"

  gallery_image_reference {
    offer     = "0001-com-ubuntu-server-jammy"
    publisher = "Canonical"
    sku       = "22_04-lts"
    version   = "latest"
  }
}