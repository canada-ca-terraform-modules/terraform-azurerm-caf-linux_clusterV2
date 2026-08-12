# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.2.0] - 2026-08-12

### Changed

- Bumped `azurerm` provider constraint from `~> 4.0` to `~> 5.0` (target `5.0.1`).
- Bumped child module `linux_VMs` (`terraform-azurerm-caf-linux_virtual_machineV2`) ref from `v1.0.7` to `v2.0.0`, which itself targets `azurerm ~> 5.0` and bumps its own `boot_diagnostic_storage` child module (`terraform-azurerm-caf-storage_accountV2`) to `v1.2.0`. This resolves the `Deprecated value used` warnings that surfaced on every plan/apply for the boot-diagnostics storage account's `queue_properties` and removes the `vm_agent_platform_updates_enabled` argument, which the Azure API redefined as read-only (`Argument is deprecated` warning).
- Bumped child module `load_balancer` (`terraform-azurerm-caf-load_balancer`) ref from `v1.0.2` to `v2.0.0`, which targets `azurerm ~> 5.0`.
- Marked the `availability_set`, `load_balancer`, and `loaddbalancer` outputs `sensitive = true` (they expose whole resource/module objects — Pattern 8 in the module-upgrade playbook).
- Bumped GitHub Actions pins: `actions/checkout` to `v7.0.1`, `hashicorp/setup-terraform` to `v4.0.1`.
- Added TFLint steps (`terraform-linters/setup-tflint@v6.3.0`, `tflint_version: v0.64.0`) to `terraform-ci.yml`.

### Removed

- Stopped passing `group`, `project`, `custom_data`, and `user_data` to the `load_balancer` child module — these arguments were removed entirely from that module's `v2.0.0` variables (dead/copy-paste arguments never used by a load balancer). Any caller-supplied `lb.custom_data`/`lb.user_data`/`lb.group`/`lb.project` keys are unaffected — they still pass through wholesale as part of the `load_balancer = var.linux_vms_cluster.lb` object, they are simply no longer individually forwarded as separate module arguments.

### Fixed

- Fixed a pre-existing `tests/linux_cluster.tftest.hcl` bug: the `custom_data_passthrough` run asserted `can(output.VMs["app01"].linux_vm_object.custom_data)` under `command = plan`, which fails with "Unknown condition value" because the `custom_data` value resolves through a live `data.http` lookup (the `install-ca-certs` shortcut) inside the child module. Converted the run to `command = apply` (mock_provider fully simulates apply at no infra cost) with `override_resource` blocks providing realistic ARM-format IDs for the availability set and NIC (both cross-referenced by the VM resource, which parses them into ARM ID segments during apply).

### Added

- `.tflint.hcl` (`call_module_type = "local"`).
- `.gitattributes` enforcing LF line endings.
- `.github/workflows/release.yml` — creates a GitHub release on merge to `main`, tagged from the version pinned in `ESLZ/SRV-Linux-cluster.tf`'s own `?ref=vX.Y.Z`.
- This `CHANGELOG.md`.
- `ESLZ/SRV-Linux-cluster.tfvars`: documented (as commented examples) every genuinely new optional argument added to the `linux_VMs` child module's `linux_VM` object schema in `v2.0.0` — found by diffing `module.tf` between `v1.0.7` and `v2.0.0` (a gap-analysis diff this changelog entry didn't originally cover): `vm_name` and `os_managed_disk_id` (VM-level), `os_disk.name`/`disk_encryption_set_id`/`secure_vm_disk_encryption_set_id`/`security_encryption_type`/`diff_disk_settings`, `nic.name`/`ip_configuration_name`/`auxiliary_mode`/`auxiliary_sku`/`nic.<ip_config>.public_ip_address_id`/`gateway_load_balancer_frontend_ip_configuration_id`/`private_ip_address_version`, `data_disks.name`/`disk_encryption_set_id`/`network_access_policy`/`disk_access_id`/`encryption_settings`, `nsg_name`, and `security_rules.*.source_application_security_group_ids`/`destination_application_security_group_ids`. All are additive `try(..., null)`-wrapped Pattern 12 name-override or optional-block arguments — no compat impact on existing tfvars.
- `tests/linux_cluster.tftest.hcl`: added `vm_v2_new_optional_args_passthrough` covering `vm_name`, `nsg_name`, `nic.name`/`ip_configuration_name`, `os_disk.name`/`disk_encryption_set_id`, and `security_rules` ASG ids in one plan-only run (all literal config values, no cross-resource ID dependency); asserts the `vm_name` override reaches the real resource via the child module's `linux_vm_name` output.

### Fixed (housekeeping)

- `.gitignore`: added a bare `*.tfvars` ignore rule before the `!ESLZ/*.tfvars` negation — the negation was previously a no-op (nothing ignored `*.tfvars` yet for it to un-ignore), so `ESLZ/*.tfvars` tracking worked by accident but any other stray `*.tfvars` file was not actually ignored.
- `ESLZ/SRV-Linux-cluster.tfvars`: removed/annotated the stale `# vm_agent_platform_updates_enabled = false` example — that argument was removed from the `linux_VMs` child module's schema in `v2.0.0` (the Azure API redefined it as platform-controlled/read-only); uncommenting it would now be silently ignored rather than erroring, so the misleading example was replaced with a note pointing at the read-only `linux_vm_object.vm_agent_platform_updates_enabled` attribute instead.
- `load_balancer` `v2.0.0` also fixes a bug where `sku` was read from the wrong path (`var.load_balancer.lb.sku` instead of `var.load_balancer.sku`), so it was always `"Standard"` regardless of caller input in `v1.0.2` — no action needed here since `ESLZ/SRV-Linux-cluster.tfvars` never set a non-default `sku` (already correctly documented as a top-level `lb.sku`/`lb.sku_tier` commented example, which now actually takes effect). Also noted: `load_balancer` `v2.0.0` renamed the backend address pool's `tunnel_interfaces` input key to `tunnel_interface` (singular) — `ESLZ/SRV-Linux-cluster.tfvars` already used the correct singular key, so no caller-facing action was needed, but this is a real breaking rename for any other consumer still on the plural key.

### Known blockers

None. The target version `5.0.1` is a real published `azurerm` release and required no substitution.
