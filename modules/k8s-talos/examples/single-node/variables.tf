variable "cluster_name" {
  type        = string
  description = "Cluster name."
  default     = "demo-talos-single"
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

variable "control_plane_node_ip" {
  type        = string
  description = "IP (or resolvable DNS) of existing Talos control-plane node."
}

