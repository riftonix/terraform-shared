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

variable "drop_other_input" {
  description = "Whether to append a final drop rule for the input chain"
  type        = bool
  default     = true
}
