variable "pm_api_url" {
  description = "Proxmox API URL, for example https://pve.example.com:8006/api2/json."
  type        = string
}

variable "pm_user" {
  description = "Proxmox user."
  type        = string
}

variable "pm_password" {
  description = "Proxmox password."
  type        = string
  sensitive   = true
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID, for example terraform@pve!token."
  type        = string
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret."
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Allow insecure TLS when connecting to Proxmox API."
  type        = bool
  default     = true
}

variable "target_node" {
  description = "PVE node where the Talos VM will be created."
  type        = string
}

variable "storage" {
  description = "Proxmox storage for the VM root disk."
  type        = string
}

variable "network_bridge" {
  description = "Proxmox network bridge for the VM."
  type        = string
}
