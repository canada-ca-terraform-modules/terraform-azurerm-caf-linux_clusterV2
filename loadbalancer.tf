module "load_balancer" {
  count  = try(var.linux_vms_cluster.lb, null) != null ? 1 : 0
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-load_balancer.git?ref=v2.0.0"

  location          = var.location
  subnets           = var.subnets
  resource_groups   = var.resource_groups
  userDefinedString = var.userDefinedString
  tags              = var.tags
  env               = var.env
  load_balancer     = var.linux_vms_cluster.lb
}
