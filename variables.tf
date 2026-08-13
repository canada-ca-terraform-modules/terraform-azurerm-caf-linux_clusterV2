variable "location" {
  description = "Azure location for the VM"
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags that will be applied to every associated VM resource"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "(Required) 4 character string defining the environment name prefix for the VM"
  type        = string
  default     = "dev"
}

variable "group" {
  description = "(Required) Character string defining the group for the target subscription"
  type        = string
  default     = "test"
}

variable "project" {
  description = "(Required) Character string defining the project for the target subscription"
  type        = string
  default     = "test"
}

variable "userDefinedString" {
  description = "(Required) User defined portion value for the name of the VM."
  type        = string
  default     = "test"
}

variable "serverType" {
  description = "3 character string defining the server type for the VM"
  type        = string
  default     = "SWJ"
}





variable "linux_vms_cluster" {
  description = "(Required) Cluster configuration for the HA VMs."
  type        = any
  default     = null
}

variable "resource_groups" {
  description = "(Required) Resource group object for the VM"
  type        = any
  default     = {}
}



variable "subnets" {
  description = "(Required) List of subnet objects for the VM"
  type        = any
  default     = {}
}

# Not currently consumed by this module - per-VM user_data is read from
# linux_vms_cluster.linux_VMs.<key>.user_data instead (see linux-vms.tf).
# Kept for interface compatibility; not forwarded to any child module.
# tflint-ignore: terraform_unused_declarations
variable "user_data" {
  description = "Not used by this module. Set per-VM user_data via linux_vms_cluster.linux_VMs.<key>.user_data instead."
  type        = any
  default     = null
}
