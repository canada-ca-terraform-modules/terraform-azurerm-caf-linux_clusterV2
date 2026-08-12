output "VMs" {
  description = "The vm module object"
  value       = module.linux_VMs
  sensitive   = true
}

output "availability_set" {
  description = "The availability_set object"
  value       = azurerm_availability_set.availability_set
  sensitive   = true
}

output "load_balancer" {
  description = "The load balancer module object"
  value       = module.load_balancer
  sensitive   = true
}

output "loaddbalancer" {
  description = "The load balancer module object"
  value       = module.load_balancer
  sensitive   = true
}
