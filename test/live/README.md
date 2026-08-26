# `test/live/` - live-test harness

A live, real-Azure-resource harness used by the `live-test` PR check (see the
[`live-test-actions`](https://github.com/canada-ca-terraform-modules/live-test-actions)
repo and this module's own `.github/workflows/live-test.yml`) to prove that
an open PR doesn't destroy or replace a resource a real consumer already has
running. It is **not** a substitute for either of the module's other two
test surfaces:

- **`tests/*.tftest.hcl`** - mock-based unit tests (`terraform test`, no
  provider credentials, no live Azure resources). Run these first; they're
  fast and free.
- **`ESLZ/`** - a usage example showing the map-based (`for_each`) blueprint
  pattern consumers actually wire this module into. Not exercised by CI at
  all; documentation only.
- **`test/live/`** (this directory) - a single, real instance of the module
  applied against a disposable Azure sandbox subscription.

## What's here

| File | Purpose |
|---|---|
| `main.tf` | Module block with `source = "../../"` (a relative path, not a pinned `?ref` - "baseline" and "PR" are just two on-disk checkouts of this repo), the `azurerm` provider config, and an empty `backend "local" {}` block (path supplied at `init` time). |
| `test_dependencies.tf` | A dedicated, throwaway resource group + vnet/subnet this harness owns outright. No Recovery Services Vault - `jump_server = true` / `disable_backup = true` in the fixture skip that lookup entirely. Names are suffixed with `var.pr_number` so concurrently open PRs never collide. |
| `variables.tf` | `env`, `location`, `group`, `project`, `userDefinedString`, `tags`, `pr_number` (defaults to `"manual"`), and `linux_vms_cluster` (typed `any`, passed straight through to the module). |
| `config/linux_clusterV2.tfvars` | One representative real-usage fixture: one VM behind an availability set, plus a minimal load balancer. |

No Terragrunt anywhere under this directory - a single harness per repo has
no cross-harness DRY need.

## Running it manually

Requires your own `az login` session against the sandbox subscription.

```bash
cd test/live
terraform init
terraform plan  -var-file=config/linux_clusterV2.tfvars
terraform apply -var-file=config/linux_clusterV2.tfvars
```

Tear it down when done:

```bash
terraform destroy -var-file=config/linux_clusterV2.tfvars
```

No `.tfstate` file is ever committed under `test/live/` - every run is fully
ephemeral, whether run by CI or by hand.
