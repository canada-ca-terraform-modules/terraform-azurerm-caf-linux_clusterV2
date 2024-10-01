module "load_balancer" {
  count = try(var.linux_vms_cluster.lb, null) != null ? 1 : 0
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-load_balancer.git?ref=v1.0.0"

  location          = var.location
  subnets           = local.subnets
  resource_groups   = local.resource_groups_all
  userDefinedString = each.key
  tags              = var.tags
  env               = var.env
  group             = var.group
  project           = var.project
  load_balancer      = var.linux_vms_cluster.lb
  custom_data       = try(var.linux_vms_cluster.lb.custom_data, false) != false ? base64encode(file("${path.cwd}/${var.linux_vms_cluster.lb.custom_data}")) : null
  user_data         = try(var.linux_vms_cluster.lb.user_data, false) != false ? base64encode(file("${path.cwd}/${var.linux_vms_cluster.lb.user_data}")) : null
}