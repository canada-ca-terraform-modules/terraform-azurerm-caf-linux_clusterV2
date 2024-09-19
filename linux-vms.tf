module "linux_VMs" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-linux_virtual_machineV2.git?ref=v1.0.0"
  for_each = var.linux_vms_cluster.linux_VMs

  location= var.location
  env = var.env
  group = var.group
  project = var.project
  userDefinedString = each.key
  linux_VM = merge(each.value, {availability_set_id = azurerm_availability_set.availability_set.id})
 
  resource_groups = var.resource_groups
  subnets = var.subnets
  user_data = try(each.value.user_data, false) != false ? base64encode(file("${path.cwd}/${each.value.user_data}")) : null
  depends_on = [azurerm_availability_set.availability_set]
}