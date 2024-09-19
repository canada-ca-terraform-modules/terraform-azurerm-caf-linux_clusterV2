module "linux_VMs_cluster" {
    source = "../"
    location= var.location
    env = var.env
    group = var.group
    project = var.project
    linux_vms_cluster = var.linux_vms_cluster
    resource_groups = local.resource_groups_all
    subnets = local.subnets
    user_data = try(each.value.user_data, false) != false ? base64encode(file("${path.cwd}/${each.value.user_data}")) : null
}