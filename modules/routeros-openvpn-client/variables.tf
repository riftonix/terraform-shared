variable "name" {
  description = "RouterOS OpenVPN client interface name"
  type        = string
}

variable "ovpn_config_path" {
  description = "Local path to the .ovpn file imported into RouterOS"
  type        = string
}

variable "ovpn_user" {
  description = "OpenVPN username passed to RouterOS import command"
  type        = string
  default     = ""
}

variable "ovpn_password" {
  description = "OpenVPN password passed to RouterOS import command"
  type        = string
  sensitive   = true
  default     = ""
}

variable "key_passphrase" {
  description = "Private key passphrase passed to RouterOS import command"
  type        = string
  sensitive   = true
  default     = ""
}

variable "skip_cert_import" {
  description = "Whether RouterOS should skip importing cert/key from the .ovpn file"
  type        = bool
  default     = false
}

variable "verify_server_certificate" {
  description = "Whether RouterOS OpenVPN client should verify the server certificate"
  type        = bool
  default     = true
}

variable "set_imported_certificate" {
  description = "Whether to attach an imported client certificate to the OpenVPN interface"
  type        = bool
  default     = true
}

variable "comment" {
  description = "Comment used on related Terraform-managed resources"
  type        = string
  default     = null
}

variable "egress" {
  description = "Policy-routing identity exported to routeros-egress-policy"
  type = object({
    name          = string
    routing_table = optional(string)
    gateway       = optional(string)
    comment       = optional(string)
  })
}

variable "create_nat" {
  description = "Whether to masquerade traffic leaving through this OpenVPN interface"
  type        = bool
  default     = true
}
