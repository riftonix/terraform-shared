variable "allowed_tcp_ports" {
  description = "TCP input ports allowed before the final input drop"
  type        = set(string)
  default     = ["80"]
}

variable "allowed_udp_ports" {
  description = "UDP input ports allowed before the final input drop"
  type        = set(string)
  default     = []
}

variable "allowed_inputs" {
  description = "Additional input allow rules. in_interface is optional; omit it to match all interfaces."
  type = map(object({
    protocol     = string
    dst_port     = string
    in_interface = optional(string)
    comment      = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in values(var.allowed_inputs) :
      contains(["tcp", "udp"], rule.protocol)
    ])
    error_message = "allowed_inputs protocol must be tcp or udp."
  }
}

variable "allowed_forwards" {
  description = "Forward chain allow rules. Rules are created before drop_forwards."
  type = map(object({
    protocol         = optional(string)
    dst_port         = optional(string)
    in_interface     = optional(string)
    out_interface    = optional(string)
    src_address      = optional(string)
    dst_address      = optional(string)
    src_address_list = optional(string)
    dst_address_list = optional(string)
    comment          = optional(string)
  }))
  default = {}
}

variable "drop_forwards" {
  description = "Forward chain drop rules created after allowed_forwards."
  type = map(object({
    protocol         = optional(string)
    dst_port         = optional(string)
    in_interface     = optional(string)
    out_interface    = optional(string)
    src_address      = optional(string)
    dst_address      = optional(string)
    src_address_list = optional(string)
    dst_address_list = optional(string)
    comment          = optional(string)
  }))
  default = {}
}

variable "srcnats" {
  description = "Source NAT rules."
  type = map(object({
    action           = optional(string, "masquerade")
    out_interface    = optional(string)
    src_address      = optional(string)
    dst_address      = optional(string)
    src_address_list = optional(string)
    dst_address_list = optional(string)
    comment          = optional(string)
  }))
  default = {}
}

variable "drop_other_input" {
  description = "Whether to append a final drop rule for the input chain"
  type        = bool
  default     = true
}
