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

# DEPRECATED: kept only for backward compatibility with existing state/callers
# that reference this misspelled output name. Use `load_balancer` instead.
output "loaddbalancer" {
  description = "DEPRECATED - use `load_balancer` instead. The load balancer module object"
  value       = module.load_balancer
  sensitive   = true
}
