# config/linux_clusterV2.tfvars
# Minimal, valid fixture exercising this module's common path: one VM (via
# the availability_set-wired child linux_VMs module) plus a minimal load
# balancer.
#
# admin_password is a literal, obviously-fake placeholder - never a real
# secret. disable_password_authentication = false is required alongside it:
# Azure rejects disable_password_authentication = true without a real
# admin_ssh_key, and admin_password must be a known-at-plan-time literal (not
# a generated value) so the child module's secret.tf count expression can
# resolve at plan time. password_overwrite = true skips the Key Vault data
# lookup entirely.
#
# jump_server = true / disable_backup = true skip the RSV/backup_policy data
# source lookups entirely on this module's current released version - no
# Recovery Services Vault is created by test_dependencies.tf.
#
# vm_size uses the Dav6 family (Standard_D2as_v6) - the sandbox subscription's
# default Dsv5/Dasv5 family quota hits a hard Azure capacity restriction in
# canadacentral (SkuNotAvailable), while Dav6 has quota provisioned.
#
# custom_data is deliberately left unset - "install-ca-certs" would trigger
# an external data.http fetch unrelated to this harness.

env               = "livetest"
group             = "test"
project           = "test"
userDefinedString = "livetest"

linux_vms_cluster = {
  resource_group    = "Project" # resolved via test_dependencies.tf's resource_groups map
  userDefinedString = "livetest"

  linux_VMs = {
    probe = {
      resource_group                  = "Project"
      admin_username                  = "azureadmin"
      admin_password                  = "CHANGE-ME-P@ssw0rd1234!" # placeholder only - throwaway live-test VM, destroyed after use
      disable_password_authentication = false
      password_overwrite              = true
      vm_size                         = "Standard_D2as_v6"

      jump_server    = true
      disable_backup = true

      nic = {
        nic1 = {
          subnet                        = "probe" # resolved via test_dependencies.tf's subnets map
          private_ip_address_allocation = "Dynamic"
        }
      }

      storage_image_reference = {
        publisher = "canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
      }
    }
  }

  # Availability set - this module's own direct resource.
  as = {
    platform_fault_domain_count  = 1
    platform_update_domain_count = 1
    platform_managed             = true
  }

  # Minimal load balancer - exercises the load_balancer child module.
  lb = {
    resource_group_name = "Project"
    postfix             = "01"
    frontend_ip_configuration = {
      feipc1 = {
        subnet                        = "probe"
        private_ip_address_allocation = "Dynamic"
      }
    }
    probes = {
      tcp443 = {
        protocol        = "Tcp"
        port            = 443
        probe_threshold = 1
      }
    }
    rules = {
      tcp443 = {
        protocol                       = "Tcp"
        frontend_port                  = 443
        backend_port                   = 443
        probe_name                     = "tcp443"
        enable_floating_ip             = true
        frontend_ip_configuration_name = "feipc1"
        load_distribution              = "SourceIPProtocol"
      }
    }
  }
}
