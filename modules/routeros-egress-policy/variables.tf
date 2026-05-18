variable "sources" {
  description = "Traffic sources governed by this egress policy"
  type = map(object({
    in_interface   = optional(string)
    src_address    = optional(string)
    allowed_egress = optional(set(string))
  }))

  validation {
    condition = alltrue([
      for source in values(var.sources) :
      try(source.in_interface, null) != null || try(source.src_address, null) != null
    ])
    error_message = "Each source must set at least one of in_interface or src_address."
  }
}

variable "egresses" {
  description = "Named egress targets and optional DNS-derived destination lists"
  type = map(object({
    routing_table               = optional(string, "main")
    gateway                     = optional(string)
    destination_prefixes        = optional(list(string), [])
    static_destination_prefixes = optional(list(string), [])
    dns_names                   = optional(list(string), [])
    dns_forward_to              = optional(list(string), [])
    connection_mark             = optional(string)
    routing_mark                = optional(string)
    comment                     = optional(string)
  }))

  validation {
    condition = alltrue([
      for name, egress in var.egresses :
      egress.routing_table == "main" || try(egress.gateway, null) != null
    ])
    error_message = "Each non-main egress must set gateway."
  }

  validation {
    condition = alltrue([
      for name, egress in var.egresses :
      length(coalesce(try(egress.static_destination_prefixes, null), [])) == 0 || try(egress.gateway, null) != null
    ])
    error_message = "Each egress with static_destination_prefixes must set gateway."
  }
}

variable "default_egress" {
  description = "Egress name used for traffic that does not match any bypass or explicit egress list"
  type        = string

  validation {
    condition     = contains(keys(var.egresses), var.default_egress)
    error_message = "default_egress must be a key in egresses."
  }
}

variable "local_bypass_prefixes" {
  description = "Destination prefixes that should never be policy-routed"
  type        = list(string)
  default     = []
}

variable "chain" {
  description = "Firewall mangle chain to attach policy rules to"
  type        = string
  default     = "prerouting"
}

variable "dns_forward_to" {
  description = "Default DNS servers used by FWD records that populate address lists"
  type        = list(string)
  default     = ["1.1.1.1"]

  validation {
    condition     = length(var.dns_forward_to) > 0
    error_message = "dns_forward_to must contain at least one DNS server."
  }
}
