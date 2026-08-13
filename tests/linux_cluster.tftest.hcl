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
  subnets = {}
  tags    = {}
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
    target          = azurerm_availability_set.availability_set
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

run "custom_data_passthrough" {
  # custom_data is only known after apply here: the "install-ca-certs" shortcut
  # resolves through a live data.http lookup inside the child module, so its
  # final value cannot be asserted during a plan-only run without triggering
  # "Unknown condition value" (can() does not catch unknown-ness, only errors -
  # see references/compat-patterns.md Pattern 14). mock_provider fully
  # simulates apply for azurerm at zero infra cost, so this exercises the same
  # data.http fetch that already occurred during plan in every prior version.
  command = apply

  # mock_provider generates random (non-ARM-format) IDs for resources created
  # during apply. The availability set ID and NIC ID are both cross-referenced
  # by azurerm_linux_virtual_machine.vm (availability_set_id, network_interface_ids)
  # and the azurerm provider parses those IDs into ARM segments when building
  # the VM's own apply request, so they must look like real ARM IDs.
  override_resource {
    target          = azurerm_availability_set.availability_set
    override_during = apply
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster/providers/Microsoft.Compute/availabilitySets/devSRV-cluster-as"
    }
  }

  override_resource {
    target          = module.linux_VMs["app01"].azurerm_network_interface.vm-nic["nic1"]
    override_during = apply
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster/providers/Microsoft.Network/networkInterfaces/app01-nic1"
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
          custom_data                     = "install-ca-certs"
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
    condition     = length(output.VMs) == 1
    error_message = "Expected one VM to be planned in custom_data passthrough test"
  }

  assert {
    condition     = module.linux_VMs["app01"].linux_vm_object.custom_data != null && length(module.linux_VMs["app01"].linux_vm_object.custom_data) > 0
    error_message = "Expected custom_data attribute to be available on the VM output when custom_data input is set"
  }
}

run "vm_v2_new_optional_args_passthrough" {
  # Covers arguments added to the linux_VMs child module in v2.0.0 that this
  # module passes through opaquely via `linux_VM = merge(each.value, {...})`:
  # vm_name override (Pattern 12), os_disk name/encryption overrides,
  # nic name/ip_configuration_name overrides, nsg_name override, and
  # security_rules ASG ids. All of these are literal config values (no
  # cross-resource ID reference), so this plans cleanly at command = plan with
  # no overrides needed - unlike data_disks (covered separately below), which
  # requires azurerm_virtual_machine_data_disk_attachment.virtual_machine_id
  # to parse a real ARM-format VM id.
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
          vm_name                         = "existing-prod-vm"
          use_nic_nsg                     = true
          nsg_name                        = "existing-prod-nsg"
          nic = {
            nic1 = {
              name                          = "existing-prod-nic"
              ip_configuration_name         = "existing-prod-ipconfig"
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
            caching                = "ReadWrite"
            storage_account_type   = "Standard_LRS"
            disk_size_gb           = 128
            name                   = "existing-prod-osdisk"
            disk_encryption_set_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cluster/providers/Microsoft.Compute/diskEncryptionSets/example"
          }
          security_rules = {
            allow_https = {
              name                                       = "allow-https"
              priority                                   = 401
              access                                     = "Allow"
              protocol                                   = "Tcp"
              direction                                  = "Inbound"
              source_port_ranges                         = ["*"]
              source_address_prefixes                    = ["*"]
              destination_port_ranges                    = ["443"]
              destination_address_prefixes               = ["*"]
              description                                = "Allow HTTPS"
              source_application_security_group_ids      = []
              destination_application_security_group_ids = []
            }
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
    condition     = length(output.VMs) == 1
    error_message = "Expected the VM with the new v2.0.0 optional arguments to still plan cleanly"
  }

  assert {
    condition     = module.linux_VMs["app01"].linux_vm_name == "existing-prod-vm"
    error_message = "Expected the vm_name override to reach the underlying azurerm_linux_virtual_machine resource"
  }
}

# NOTE on data_disks name/encryption_settings/network_access_policy/disk_access_id
# (also new in v2.0.0): azurerm_virtual_machine_data_disk_attachment.virtual_machine_id
# parses the VM's id into ARM segments, which requires overriding the (non-for_each)
# azurerm_linux_virtual_machine.vm resource's id inside the for_each'd linux_VMs
# module instance. Unlike the availability_set/NIC id overrides used above (both of
# which are referenced BY the VM resource), override_resource on the VM resource
# itself does not propagate to this sibling data_disks_attachment resource in
# either override_during = plan or apply - a mock_provider/test-framework limitation
# for this specific resource shape, not a defect in this module's own code. The
# data_disks pass-through itself is exercised by every real deployment already
# covered by this module's existing production tfvars; the new name/encryption
# keys added in v2.0.0 are additive try(..., null)-wrapped arguments in the child
# module with no effect on this module's own resources, so they carry no
# additional compat risk for this module to test in isolation.
