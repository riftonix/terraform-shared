variable "dns" {
  description = "RouterOS DNS resolver/cache settings"
  type = object({
    enabled               = optional(bool, true)
    servers               = optional(list(string), ["1.1.1.1", "1.0.0.1"])
    allow_remote_requests = optional(bool, true)
  })
  default = {}
}

variable "enabled_services" {
  description = "RouterOS /ip/service entries to keep enabled with their ports"
  type        = map(number)
  default     = {}
}

variable "disabled_services" {
  description = "RouterOS /ip/service entries to disable with their ports"
  type        = map(number)
  default     = {}
}
