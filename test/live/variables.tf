variable "env" {
  description = "Environment prefix used in generated resource names"
  type        = string
  default     = "livetest"
}

variable "location" {
  description = "Location for the throwaway live-test resource group"
  type        = string
  default     = "canadacentral"
}

variable "group" {
  description = "Character string defining the group for the target subscription (module requirement)"
  type        = string
  default     = "test"
}

variable "project" {
  description = "Character string defining the project for the target subscription (module requirement)"
  type        = string
  default     = "test"
}

variable "userDefinedString" {
  description = "User defined portion value for the name of the availability set"
  type        = string
  default     = "livetest"
}

variable "tags" {
  description = "Tags applied to every resource created by this harness"
  type        = map(string)
  default = {
    purpose = "module-live-test"
  }
}

variable "pr_number" {
  description = <<-EOT
    Suffix applied to test_dependencies.tf resource names so concurrent PRs
    against this module never collide on the same sandbox subscription. CI
    sources this from `TF_VAR_pr_number` (`github.event.number`); manual runs
    can leave the default or pass their own value.
  EOT
  type        = string
  default     = "manual"
}

variable "linux_vms_cluster" {
  description = "Cluster configuration object, passed straight through to the module under test"
  type        = any
}
