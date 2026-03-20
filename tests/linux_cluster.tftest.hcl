mock_provider "azurerm" {}

variables {
  env               = "dev"
  group             = "grp"
  project           = "prj"
  serverType        = "SRV"
  userDefinedString = "cluster"
  location          = "canadacentral"
  resource_groups = {
    Project = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster"
      name = "rg-cluster"
    }
    Backups = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-backups"
      name = "rg-backups"
    }
    Keyvault = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-keyvault"
      name = "rg-keyvault"
    }
  }
  subnets           = {}
  tags              = {}
}

run "naming_convention" {
  command = plan

  variables {
    linux_vms_cluster = {
      resource_group = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster"
      linux_VMs      = {}
      as = {
        platform_fault_domain_count  = 1
        platform_update_domain_count = 1
        platform_managed             = true
      }
    }
  }

  assert {
    condition     = output.availability_set.name == "devSRV-cluster-as"
    error_message = "Expected the availability set name to follow the ESLZ naming convention"
  }
}

run "default_values" {
  command = plan

  variables {
    linux_vms_cluster = {
      resource_group = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster"
      linux_VMs      = {}
      as = {
        platform_fault_domain_count  = 1
        platform_update_domain_count = 1
        platform_managed             = true
      }
    }
  }

  assert {
    condition     = length(output.VMs) == 0
    error_message = "Expected no VM child modules when linux_VMs is empty"
  }

  assert {
    condition     = length(output.load_balancer) == 0
    error_message = "Expected no load balancer child modules when lb is omitted"
  }
}

run "multiple_vms_with_basic_lb" {
  command = plan

  variables {
    linux_vms_cluster = {
      resource_group = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster"
      linux_VMs = {
        app01 = {
          resource_group                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster"
          admin_username                  = "azureadmin"
          disable_password_authentication = true
          disable_backup                  = true
          vm_size                         = "Standard_D2s_v5"
          nic = {
            nic1 = {
              subnet                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-main/subnets/snet-app"
              private_ip_address_allocation = "Dynamic"
            }
          }
          admin_ssh_key = {
            public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/mXVzQGU2b0Z14pIxY4MIYEDkL+bUu03Fncv3gpD8JnqNZsJAz7IXnEAhNny8qqFAN9Q2UkUyzliNirGvCQyU87Fk4dOTz2xUF5ZBj3/DIE4IWI/LinukTA8GYfQwjJahisqB3kU5/Qhw8R142a19+svTRlfBfp5Ts+oonUK7hdf7gjs5oWpvkkQ8FAA9iqi6af7+otAIVcYouq4gJxzHYy7AhHCbmqZK/vKooS6yKHFyp4N5UhGmihfWLFcusThX71W+kq1p7gMkjGbdhJDWJWLGB4RmYJw6qXFYNOM+l1fc1ARZ1EPI4rYCMh3A/N17v1SFqdMkZlfjJn93ZltH bernard@GcPcSAW-CDP6-21"
            username   = "azureadmin"
          }
          storage_image_reference = {
            publisher = "canonical"
            offer     = "0001-com-ubuntu-server-jammy"
            sku       = "22_04-lts-gen2"
            version   = "latest"
          }
          os_disk = {
            caching              = "ReadWrite"
            storage_account_type = "Standard_LRS"
            disk_size_gb         = 128
          }
        }
        app02 = {
          resource_group                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster"
          admin_username                  = "azureadmin"
          disable_password_authentication = true
          disable_backup                  = true
          vm_size                         = "Standard_D2s_v5"
          nic = {
            nic1 = {
              subnet                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-main/subnets/snet-app"
              private_ip_address_allocation = "Dynamic"
            }
          }
          admin_ssh_key = {
            public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/mXVzQGU2b0Z14pIxY4MIYEDkL+bUu03Fncv3gpD8JnqNZsJAz7IXnEAhNny8qqFAN9Q2UkUyzliNirGvCQyU87Fk4dOTz2xUF5ZBj3/DIE4IWI/LinukTA8GYfQwjJahisqB3kU5/Qhw8R142a19+svTRlfBfp5Ts+oonUK7hdf7gjs5oWpvkkQ8FAA9iqi6af7+otAIVcYouq4gJxzHYy7AhHCbmqZK/vKooS6yKHFyp4N5UhGmihfWLFcusThX71W+kq1p7gMkjGbdhJDWJWLGB4RmYJw6qXFYNOM+l1fc1ARZ1EPI4rYCMh3A/N17v1SFqdMkZlfjJn93ZltH bernard@GcPcSAW-CDP6-21"
            username   = "azureadmin"
          }
          storage_image_reference = {
            publisher = "canonical"
            offer     = "0001-com-ubuntu-server-jammy"
            sku       = "22_04-lts-gen2"
            version   = "latest"
          }
          os_disk = {
            caching              = "ReadWrite"
            storage_account_type = "Standard_LRS"
            disk_size_gb         = 128
          }
        }
      }
      lb = {
        resource_group_name = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster"
        postfix             = "01"
        frontend_ip_configuration = {
          feipc1 = {
            subnet                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-main/subnets/snet-lb"
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
      as = {
        platform_fault_domain_count  = 1
        platform_update_domain_count = 1
        platform_managed             = true
      }
    }
  }

  assert {
    condition     = length(output.VMs) == 2
    error_message = "Expected two VM child modules for the two-node cluster fixture"
  }

  assert {
    condition     = length(output.load_balancer) == 1
    error_message = "Expected exactly one load balancer child module when lb is configured"
  }

  assert {
    condition     = length(azurerm_network_interface_backend_address_pool_association.LB_VMs) == 2
    error_message = "Expected both VM NICs to be associated with the load balancer backend pool"
  }
}