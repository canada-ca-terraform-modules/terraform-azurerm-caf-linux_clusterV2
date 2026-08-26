# test_dependencies.tf
# Self-contained dependency resources, owned entirely by this harness.
#
# Deliberately NOT reusing any shared/production resource group, vnet, or
# subnet: writing into a shared L1-managed "Network" RG usually requires
# elevated, L1-scoped permissions. A dedicated throwaway RG + vnet + subnet
# here needs only Contributor on the sandbox subscription and can never
# collide with or affect any production resource.
#
# No Recovery Services Vault / backup policy is created here: the fixture's
# jump_server = true + disable_backup = true skip the child linux_VMs
# module's RSV/backup-policy data-source lookups entirely on this module's
# current released version.

resource "azurerm_resource_group" "live_test" {
  # pr_number suffix keeps two concurrently open PRs against this module
  # from colliding on the same sandbox subscription.
  name     = "${var.env}-caf-linux-clusterv2-live-test-${var.pr_number}-rg"
  location = var.location

  tags = merge(var.tags, {
    "pr-number" = var.pr_number
  })
}

resource "azurerm_virtual_network" "live_test" {
  name                = "${var.env}-caf-linux-clusterv2-live-test-${var.pr_number}-vnet"
  address_space       = ["10.252.0.0/16"] # arbitrary, unpeered - collision-safe by construction
  location            = azurerm_resource_group.live_test.location
  resource_group_name = azurerm_resource_group.live_test.name
  tags                = var.tags
}

resource "azurerm_subnet" "live_test" {
  name                 = "${var.env}-caf-linux-clusterv2-live-test-${var.pr_number}-snet"
  resource_group_name  = azurerm_resource_group.live_test.name
  virtual_network_name = azurerm_virtual_network.live_test.name
  address_prefixes     = ["10.252.0.0/24"]
}

locals {
  # linux_clusterV2 takes MAPS keyed by the name the linux_vms_cluster object
  # references (resource_group = "Project", nic.subnet = "probe").
  #
  # Keyvault is required even though the KV lookup itself is skipped (count=0
  # via disable_password_authentication=false + a literal admin_password):
  # the child linux_VMs module's secret.tf unconditionally hashes
  # var.resource_groups["Keyvault"].id in a local regardless of that count -
  # a real Key Vault never needs to exist behind it since the hash is just of
  # the RG id string, but the map key itself must resolve or the plan fails
  # with "Invalid index" before count is even evaluated. Real ESLZ callers
  # never hit this because their resource_groups map always includes every
  # subscription RG (Keyvault included).
  resource_groups = {
    Project  = { name = azurerm_resource_group.live_test.name, id = azurerm_resource_group.live_test.id }
    Keyvault = { name = azurerm_resource_group.live_test.name, id = azurerm_resource_group.live_test.id }
  }
  subnets = {
    probe = { id = azurerm_subnet.live_test.id }
  }
}
