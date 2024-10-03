output "frontend_lb_ip" {
  description = "The public IP address of the frontend load balancer"
  value       = azurerm_public_ip.frontend_lb_pip.ip_address
}

output "frontend_lb_id" {
  description = "The ID of the frontend load balancer"
  value       = azurerm_lb.frontend_lb.id
}

output "backend_lb_id" {
  description = "The ID of the backend load balancer"
  value       = azurerm_lb.backend_lb.id
}

output "frontend_lb_backend_address_pool_id" {
  description = "The ID of the frontend load balancer backend address pool"
  value       = azurerm_lb_backend_address_pool.frontend_lb_pool.id
}

output "backend_lb_backend_address_pool_id" {
  description = "The ID of the backend load balancer backend address pool"
  value       = azurerm_lb_backend_address_pool.backend_lb_pool.id
}