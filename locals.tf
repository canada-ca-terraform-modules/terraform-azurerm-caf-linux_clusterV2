locals {
  resource_group_name = strcontains(var.linux_vms_cluster.resource_group, "/resourceGroups/") ? regex("[^\\/]+$", var.linux_vms_cluster.resource_group) :  var.resource_groups[var.linux_vms_cluster.resource_group].name
}