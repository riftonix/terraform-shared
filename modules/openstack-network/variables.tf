variable "network_name" {
  description = "Name of the private OpenStack network."
  type        = string
}

variable "network_description" {
  description = "Optional human-readable network description."
  type        = string
  default     = null
}

variable "network_admin_state_up" {
  description = "Administrative state of the network."
  type        = bool
  default     = true
}

variable "network_port_security_enabled" {
  description = "Enable or disable port security on the network."
  type        = bool
  default     = true
}

variable "network_mtu" {
  description = "Optional network MTU."
  type        = number
  default     = null
}

variable "network_dns_domain" {
  description = "Optional DNS domain for the network."
  type        = string
  default     = null
}

variable "network_tags" {
  description = "Default tags applied to the network."
  type        = list(string)
  default     = null
}

variable "network_value_specs" {
  description = "Optional provider-specific map for network value_specs."
  type        = map(string)
  default     = {}
}

variable "subnets" {
  description = "Subnets map keyed by subnet name."
  type = map(object({
    description         = optional(string)
    cidr                = optional(string)
    subnetpool_id       = optional(string)
    prefix_length       = optional(number)
    ip_version          = optional(number, 4)
    gateway_ip          = optional(string)
    no_gateway          = optional(bool, false)
    enable_dhcp         = optional(bool, true)
    dns_nameservers     = optional(list(string), [])
    dns_publish_fixed_ip = optional(bool, false)
    service_types       = optional(list(string), [])
    segment_id          = optional(string)
    tags                = optional(list(string), [])
    value_specs         = optional(map(string), {})
    allocation_pools = optional(list(object({
      start = string
      end   = string
    })), [])
  }))

  validation {
    condition     = length(var.subnets) > 0
    error_message = "At least one subnet must be provided in `subnets`."
  }

  validation {
    condition = alltrue([
      for _, subnet in var.subnets : (
        try(subnet.cidr, null) != null || try(subnet.subnetpool_id, null) != null
      )
    ])
    error_message = "Each subnet must define either `cidr` or `subnetpool_id`."
  }

  validation {
    condition = alltrue([
      for _, subnet in var.subnets : !(
        try(subnet.cidr, null) != null && try(subnet.subnetpool_id, null) != null
      )
    ])
    error_message = "`cidr` and `subnetpool_id` are mutually exclusive for each subnet."
  }

  validation {
    condition = alltrue([
      for _, subnet in var.subnets : !(
        try(subnet.no_gateway, false) && try(subnet.gateway_ip, null) != null
      )
    ])
    error_message = "`no_gateway = true` cannot be used together with `gateway_ip`."
  }
}

