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
  description = "Named egress targets, optional DNS-derived destination lists and optional split DNS resolvers"
  type = map(object({
    routing_table               = optional(string, "main")
    gateway                     = optional(string)
    destination_prefixes        = optional(list(string), [])
    static_destination_prefixes = optional(list(string), [])
    destination_domains         = optional(list(string), [])
    dns_resolver = optional(object({
      domains = list(string)
      servers = list(string)
    }))
    connection_mark = optional(string)
    routing_mark    = optional(string)
    comment         = optional(string)
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

  validation {
    condition = alltrue([
      for name, egress in var.egresses :
      try(egress.dns_resolver, null) == null || (length(egress.dns_resolver.domains) > 0 && length(egress.dns_resolver.servers) > 0)
    ])
    error_message = "dns_resolver.domains and dns_resolver.servers must not be empty."
  }

  validation {
    condition = alltrue(flatten([
      for name, egress in var.egresses : [
        for server in try(egress.dns_resolver.servers, []) :
        can(regex("^[0-9]{1,3}(\\.[0-9]{1,3}){3}$", server)) && can(cidrhost("${server}/32", 0))
      ]
    ]))
    error_message = "dns_resolver.servers must be IPv4 addresses without a prefix length."
  }

  validation {
    condition = alltrue(flatten([
      for name, egress in var.egresses : [
        for domain in try(egress.dns_resolver.domains, []) :
        can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*$", domain))
      ]
    ]))
    error_message = "dns_resolver.domains must be lowercase DNS names without a trailing dot."
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

variable "destination_domains_upstream" {
  description = "DNS servers of the FWD records that populate address lists from destination_domains; the first entry is used"
  type        = list(string)
  default     = ["1.1.1.1"]

  validation {
    condition     = length(var.destination_domains_upstream) > 0
    error_message = "destination_domains_upstream must contain at least one DNS server."
  }
}
