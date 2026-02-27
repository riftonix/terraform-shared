variable "cluster_name" {
  type        = string
  description = "Cluster name."
  default     = "demo-talos"
}

variable "talos_version" {
  type        = string
  description = "Talos version for generated machine configs."
  default     = "v1.9.4"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for generated machine configs."
  default     = "1.32.0"
}

variable "cluster_endpoint_host" {
  type        = string
  description = "Kubernetes API endpoint host (DNS/IP)."
}

variable "kubeconfig_server_host" {
  type        = string
  description = "Optional kubeconfig server host for external access."
  default     = null
}

variable "control_plane_nodes" {
  description = "Existing control-plane Talos nodes."
  type = list(object({
    name         = string
    node         = string
    endpoint     = optional(string)
    install_disk = optional(string)
    labels       = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    config_patches = optional(list(string), [])
  }))
}

variable "worker_nodes" {
  description = "Existing worker Talos nodes."
  type = list(object({
    name         = string
    node         = string
    endpoint     = optional(string)
    install_disk = optional(string)
    labels       = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    config_patches = optional(list(string), [])
  }))
  default = []
}

