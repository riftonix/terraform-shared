variable "router_name" {
  description = "Name of OpenStack router."
  type        = string
}

variable "router_description" {
  description = "Optional router description."
  type        = string
  default     = null
}

variable "router_admin_state_up" {
  description = "Administrative state of router."
  type        = bool
  default     = true
}

variable "external_network_id" {
  description = "External network ID used as router gateway for Internet access. Has priority over external_network_name."
  type        = string
  default     = null
}

variable "external_network_name" {
  description = "External network name used to resolve gateway network when external_network_id is not set."
  type        = string
  default     = "external-network"
}

variable "router_enable_snat" {
  description = "Enable SNAT on router external gateway."
  type        = bool
  default     = true
}

variable "router_tags" {
  description = "Tags applied to the router."
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Explicit subnet IDs to attach to the router (primary input)."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for subnet_id in var.subnet_ids : trimspace(subnet_id) != ""
    ])
    error_message = "`subnet_ids` cannot contain empty values."
  }
}

variable "openstack_network_modules" {
  description = "Optional list of OpenStack network module outputs/objects containing both `input_subnets` and `subnets` maps. Iteration is by `input_subnets` keys, attachment uses real IDs from `subnets` map."
  type        = list(any)
  default     = []

  validation {
    condition = alltrue([
      for module_output in var.openstack_network_modules :
      try(module_output[var.openstack_network_modules_subnets_key], null) != null &&
      try(module_output.subnets, null) != null
    ])
    error_message = "Each item in `openstack_network_modules` must contain the key from `openstack_network_modules_subnets_key` (default: input_subnets) and a `subnets` map with IDs."
  }
}

variable "openstack_network_modules_subnets_key" {
  description = "Key inside each object from `openstack_network_modules` that contains subnet input map."
  type        = string
  default     = "input_subnets"
}
