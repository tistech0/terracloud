# Public IP for Frontend Load Balancer
resource "azurerm_public_ip" "frontend_lb_pip" {
  name                = "pip-frontend-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Frontend Load Balancer
resource "azurerm_lb" "frontend_lb" {
  name                = "lb-frontend"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.frontend_lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "frontend_lb_pool" {
  loadbalancer_id = azurerm_lb.frontend_lb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "frontend_lb_rule_http" {
  loadbalancer_id                = azurerm_lb.frontend_lb.id
  name                           = "HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.frontend_lb_pool.id]
}

resource "azurerm_lb_probe" "frontend_lb_probe" {
  loadbalancer_id = azurerm_lb.frontend_lb.id
  name            = "http-running-probe"
  port            = 80
}

# Backend Load Balancer (Internal)
resource "azurerm_lb" "backend_lb" {
  name                = "lb-backend"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "PrivateIPAddress"
    subnet_id                     = var.subnet_ids["backend"]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_lb_pool" {
  loadbalancer_id = azurerm_lb.backend_lb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "backend_lb_rule" {
  loadbalancer_id                = azurerm_lb.backend_lb.id
  name                           = "BackendRule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "PrivateIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_lb_pool.id]
}

resource "azurerm_lb_probe" "backend_lb_probe" {
  loadbalancer_id = azurerm_lb.backend_lb.id
  name            = "backend-running-probe"
  port            = 8080
}

# Associate frontend VMs with frontend LB backend pool
resource "azurerm_network_interface_backend_address_pool_association" "frontend_lb_association" {
  count                   = length(var.frontend_nic_ids)
  network_interface_id    = var.frontend_nic_ids[count.index]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend_lb_pool.id
}

# Associate backend VMs with backend LB backend pool
resource "azurerm_network_interface_backend_address_pool_association" "backend_lb_association" {
  count                   = length(var.backend_nic_ids)
  network_interface_id    = var.backend_nic_ids[count.index]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_lb_pool.id
}
