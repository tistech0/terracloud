# Availability Sets
resource "azurerm_availability_set" "frontend_avset" {
  name                = "avset-frontend"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_availability_set" "backend_avset" {
  name                = "avset-backend"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Network Interfaces
resource "azurerm_network_interface" "frontend_nic" {
  count               = var.frontend_vm_count
  name                = "nic-frontend-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids["frontend"]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "backend_nic" {
  count               = var.backend_vm_count
  name                = "nic-backend-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids["backend"]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "database_nic" {
  name                = "nic-database"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids["database"]
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "frontend_vm" {
  count               = var.frontend_vm_count
  name                = "vm-frontend-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  availability_set_id = azurerm_availability_set.frontend_avset.id

  network_interface_ids = [
    azurerm_network_interface.frontend_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "backend_vm" {
  count               = var.backend_vm_count
  name                = "vm-backend-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  availability_set_id = azurerm_availability_set.backend_avset.id

  network_interface_ids = [
    azurerm_network_interface.backend_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "database_vm" {
  name                = "vm-database"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.database_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
