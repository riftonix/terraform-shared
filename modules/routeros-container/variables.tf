variable "name" {
  description = "Base name for the veth interface, the environment list and comments"
  type        = string
}

variable "remote_image" {
  description = "Image reference passed to RouterOS"
  type        = string
}

variable "root_dir" {
  description = "Container root directory on the router disk"
  type        = string
}

variable "network" {
  description = "Point-to-point link between the router and the container; addresses in CIDR form, interface_name defaults to veth-<name>"
  type = object({
    interface_name    = optional(string)
    router_address    = string
    container_address = string
  })

  validation {
    condition = try(
      split("/", var.network.router_address)[1] == split("/", var.network.container_address)[1]
      && cidrhost(var.network.router_address, 0) == cidrhost(var.network.container_address, 0)
      && split("/", var.network.router_address)[0] != split("/", var.network.container_address)[0],
      false
    )
    error_message = "network.router_address and network.container_address must be CIDR addresses with the same prefix length, in the same network and with different host addresses."
  }
}

variable "envs" {
  description = "Container environment"
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "devices" {
  description = "Devices passed through to the container"
  type        = set(string)
  default     = []
}

variable "dns" {
  description = "Container DNS servers"
  type        = string
  default     = null
}

variable "memory_high" {
  description = "Container memory limit"
  type        = string
  default     = null
}

variable "logging" {
  description = "Whether RouterOS writes the container output to its log"
  type        = bool
  default     = true
}

variable "check_certificate" {
  description = "Whether RouterOS validates the registry certificate"
  type        = bool
  default     = true
}

variable "start_on_create" {
  description = "Whether the container starts once after creation; later changes and manual starts or stops are ignored"
  type        = bool
  default     = false
}

variable "start_on_boot" {
  description = "Whether the container starts on router boot"
  type        = bool
  default     = false
}

variable "auto_restart_interval" {
  description = "Interval after which RouterOS restarts a failed container"
  type        = string
  default     = null
}

variable "comment" {
  description = "Comment used on related Terraform-managed resources"
  type        = string
  default     = null
}

variable "egress" {
  description = "Policy-routing identity exported to routeros-egress-policy; routing_table defaults to to-<name>"
  type = object({
    name          = string
    routing_table = optional(string)
  })
  default = null
}
