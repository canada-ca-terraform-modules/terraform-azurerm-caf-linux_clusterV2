resource "azurerm_lb" "loadbalancer" {
  count = var.linux_vms_cluster.lb != null ? 1 : 0

  name                = local.lb-name
  location            = var.location
  resource_group_name = local.resource_group_name
  frontend_ip_configuration {
    name                          = "${local.lb-name}-lbfe"
    private_ip_address_allocation = lookup(var.linux_vms_cluster.lb, "private_ip_address_allocation", "Static")
    private_ip_address            = var.linux_vms_cluster.lb.private_ip_address
    subnet_id                     = strcontains(var.linux_vms_cluster.lb.subnet, "/resourceGroups/") ? var.linux_vms_cluster.lb.subnet : var.subnets[var.linux_vms_cluster.lb.subnet].id
  }
  sku = lookup(var.linux_vms_cluster.lb, "sku", "Standard")
}

resource "azurerm_lb_probe" "loadbalancer-lbhp" {
  for_each = try(var.linux_vms_cluster.lb.probes, {})

  # resource_group_name = var.resource_group.name
  loadbalancer_id     = azurerm_lb.loadbalancer[0].id
  name                = "${local.lb-name}-${each.key}-lbhp"
  protocol            = lookup(each.value, "protocol", "Tcp")
  port                = each.value.port
  request_path        = lookup(each.value, "request_path", null)
  interval_in_seconds = lookup(each.value, "interval_in_seconds", 5)
  number_of_probes    = lookup(each.value, "number_of_probes", 2)
}

resource "azurerm_lb_backend_address_pool" "loadbalancer-lbbp" {
  count = var.linux_vms_cluster.lb != null ? 1 : 0

  loadbalancer_id = azurerm_lb.loadbalancer[0].id
  name            = "${local.lb-name}-HA-lbbp"
}

resource "azurerm_lb_rule" "loadbalancer-lbr" {
  for_each = try(var.linux_vms_cluster.lb.rules, {})

  # resource_group_name            = var.resource_group.name
  loadbalancer_id                = azurerm_lb.loadbalancer[0].id
  name                           = "${local.lb-name}-${each.key}-lbr"
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "${local.lb-name}-lbfe"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.loadbalancer-lbbp[0].id]
  probe_id                       = azurerm_lb_probe.loadbalancer-lbhp[each.value.probe_name].id
  load_distribution              = each.value.load_distribution
  enable_floating_ip             = each.value.enable_floating_ip
  idle_timeout_in_minutes        = try(each.value.idle_timeout_in_minutes, 4)
}