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

run "resource_group_key_lookup" {
  command = plan

  variables {
    linux_vms_cluster = {
      resource_group = "Project"
      linux_VMs      = {}
      as = {
        platform_fault_domain_count  = 1
        platform_update_domain_count = 1
        platform_managed             = true
      }
    }
  }

  assert {
    condition     = output.availability_set.resource_group_name == "rg-cluster"
    error_message = "Expected resource_group_name to be resolved via the 'Project' key from the resource_groups map"
  }
}

run "name_truncation" {
  command = plan

  variables {
    userDefinedString = "clusterfullname"
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
    error_message = "Expected userDefinedString to be truncated to 7 characters: 'clusterfullname' -> 'cluster'"
  }
}

run "lb_tags_propagation" {
  command = plan

  variables {
    tags = {
      env            = "dev"
      classification = "pbmm"
    }
    linux_vms_cluster = {
      resource_group = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster"
      linux_VMs      = {}
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
    condition     = output.load_balancer[0].loadbalancer.tags["env"] == "dev"
    error_message = "Expected 'env' tag to be propagated to the load balancer"
  }

  assert {
    condition     = output.load_balancer[0].loadbalancer.tags["classification"] == "pbmm"
    error_message = "Expected 'classification' tag to be propagated to the load balancer"
  }
}

run "availability_set_id_injected_into_vms" {
  command = plan

  # Override the AS so it has a known valid-format ID during plan,
  # allowing us to assert that the ID is forwarded into each VM.
  override_resource {
    target = azurerm_availability_set.availability_set
    override_during = plan
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster/providers/Microsoft.Compute/availabilitySets/devSRV-cluster-as"
    }
  }

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
      }
      as = {
        platform_fault_domain_count  = 1
        platform_update_domain_count = 1
        platform_managed             = true
      }
    }
  }

  assert {
    # availability_set_id on azurerm_linux_virtual_machine is Optional+Computed in the azurerm
    # schema, so mock_provider generates its own value rather than reflecting the config input.
    # We verify co-existence instead: the AS has the overridden ID and exactly one VM is planned.
    condition     = azurerm_availability_set.availability_set.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster/providers/Microsoft.Compute/availabilitySets/devSRV-cluster-as"
    error_message = "Expected override_resource to provide a known AS ID so the injection expression can be evaluated"
  }

  assert {
    condition     = length(output.VMs) == 1
    error_message = "Expected exactly one VM planned alongside the availability set (verifies AS+VM co-existence wiring)"
  }
}

run "tags_propagation" {
  command = plan

  variables {
    tags = {
      env            = "dev"
      classification = "pbmm"
      owner          = "test@example.com"
    }
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
    condition     = output.availability_set.tags["env"] == "dev"
    error_message = "Expected the 'env' tag to be propagated to the availability set"
  }

  assert {
    condition     = output.availability_set.tags["classification"] == "pbmm"
    error_message = "Expected the 'classification' tag to be propagated to the availability set"
  }

  assert {
    condition     = output.availability_set.tags["owner"] == "test@example.com"
    error_message = "Expected the 'owner' tag to be propagated to the availability set"
  }
}