variable "interface" {
  description = "WireGuard interface configuration for a RouterOS instance"
  type = object({
    name                    = string
    address                 = string
    listen_port             = number
    comment                 = optional(string)
    mtu                     = optional(string)
    private_key             = optional(string)
    public_endpoint_address = optional(string)
  })
}

variable "site_peers" {
  description = "Site-to-site peers attached to the local WireGuard interface"
  type = map(object({
    peer_public_key                = string
    preshared_key                  = optional(string)
    endpoint_address               = optional(string)
    endpoint_port                  = optional(number)
    persistent_keepalive           = optional(number)
    responder_only                 = optional(bool)
    remote_address                 = string
    remote_networks                = list(string)
    routed_prefixes                = optional(list(string))
    local_networks                 = list(string)
    allowed_addresses              = optional(list(string))
    internet_egress_source_networks = optional(list(string))
    comment                        = optional(string)
    enabled                        = optional(bool)
  }))
  default = {}
}

variable "road_warrior" {
  description = "Road-warrior WireGuard access configuration"
  type = object({
    peers = optional(map(object({
      address              = string
      comment              = optional(string)
      public_key           = optional(string)
      private_key          = optional(string)
      preshared_key        = optional(string)
      allowed_ips          = optional(list(string))
      dns                  = optional(list(string))
      persistent_keepalive = optional(number)
      enabled              = optional(bool)
    })), {})
    client_allowed_ips  = optional(list(string))
    client_dns          = optional(list(string))
    create_internet_nat = optional(bool)
    nat_excluded_prefixes = optional(list(string))
  })
  default = null
}

variable "manage_firewall" {
  description = "Whether to create basic firewall rules for WireGuard input and site-to-site forwarding"
  type        = bool
  default     = true
}
