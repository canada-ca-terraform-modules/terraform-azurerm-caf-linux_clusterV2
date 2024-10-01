module "linux_VMs" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-linux_virtual_machineV2.git?ref=v1.0.1"
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

resource "azurerm_network_interface_backend_address_pool_association" "LB_VMs" {
  for_each = var.linux_vms_cluster.lb != null ? var.linux_vms_cluster.linux_VMs : {}

  network_interface_id    =  module.linux_VMs[each.key].linux_vm_object.network_interface_ids[0]
  ip_configuration_name   =  "${module.linux_VMs[each.key].linux_vm_object.name}-ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.loadbalancer-lbbp[0].id
}