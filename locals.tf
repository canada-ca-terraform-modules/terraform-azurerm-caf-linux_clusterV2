locals {
  cluster_resource_group = try(var.linux_vms_cluster.resource_group, null)
  resource_group_name = local.cluster_resource_group == null ? null : (
    strcontains(local.cluster_resource_group, "/resourceGroups/")
    ? regex("[^\\/]+$", local.cluster_resource_group)
    : try(var.resource_groups[local.cluster_resource_group].name, local.cluster_resource_group)
  )
}