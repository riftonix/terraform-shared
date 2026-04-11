variable "cluster_name" {
  description = "Talos/Kubernetes cluster name."
  type        = string
}

variable "talos_version" {
  description = "Talos version used for generated machine configuration features."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version embedded into Talos machine configuration."
  type        = string
}

variable "cluster_endpoint_host" {
  description = "Kubernetes API endpoint host (IP/DNS). If null, first control-plane endpoint is used."
  type        = string
  default     = null
}

variable "cluster_endpoint_port" {
  description = "Kubernetes API endpoint port."
  type        = number
  default     = 6443
}

variable "control_plane_nodes_map" {
  description = "Control-plane nodes as map keyed by node name. Works with any infra module output that follows this schema."
  type = map(object({
    name     = string
    node     = string
    endpoint = optional(string)
    install_disk = optional(string)
    labels       = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    config_patches = optional(list(string), [])
  }))

  validation {
    condition     = length(var.control_plane_nodes_map) > 0
    error_message = "At least one control-plane node is required in control_plane_nodes_map."
  }

  validation {
    condition = alltrue([
      for taint in flatten([
        for _, node in var.control_plane_nodes_map : node.taints
      ]) : contains(["NoSchedule", "PreferNoSchedule", "NoExecute"], taint.effect)
    ])
    error_message = "Invalid taint effect in control_plane_nodes_map. Allowed: NoSchedule, PreferNoSchedule, NoExecute."
  }
}

variable "control_plane_defaults" {
  description = "Defaults applied to nodes from control_plane_nodes_map."
  type = object({
    install_disk   = optional(string)
    labels         = optional(map(string), {})
    taints         = optional(list(object({ key = string, value = string, effect = string })), [])
    config_patches = optional(list(string), [])
  })
  default = {
    install_disk   = null
    labels         = {}
    taints         = []
    config_patches = []
  }

  validation {
    condition = alltrue([
      for taint in flatten([
        var.control_plane_defaults.taints
      ]) : contains(["NoSchedule", "PreferNoSchedule", "NoExecute"], taint.effect)
    ])
    error_message = "Invalid taint effect in control_plane_defaults.taints. Allowed: NoSchedule, PreferNoSchedule, NoExecute."
  }
}

variable "worker_node_maps" {
  description = "Worker nodes as list of maps keyed by node name (e.g., from one or many infra modules)."
  type = list(map(object({
    name     = string
    node     = string
    endpoint = optional(string)
    install_disk = optional(string)
    labels       = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    config_patches = optional(list(string), [])
  })))
  default = []

  validation {
    condition = alltrue([
      for taint in flatten(flatten([
        for worker_map in var.worker_node_maps : [
          for _, node in worker_map : node.taints
        ]
      ])) : contains(["NoSchedule", "PreferNoSchedule", "NoExecute"], taint.effect)
    ])
    error_message = "Invalid taint effect in worker_node_maps. Allowed: NoSchedule, PreferNoSchedule, NoExecute."
  }
}

variable "worker_defaults" {
  description = "Defaults applied to nodes from worker_node_maps."
  type = object({
    install_disk   = optional(string)
    labels         = optional(map(string), {})
    taints         = optional(list(object({ key = string, value = string, effect = string })), [])
    config_patches = optional(list(string), [])
  })
  default = {
    install_disk   = null
    labels         = {}
    taints         = []
    config_patches = []
  }

  validation {
    condition = alltrue([
      for taint in flatten([
        var.worker_defaults.taints
      ]) : contains(["NoSchedule", "PreferNoSchedule", "NoExecute"], taint.effect)
    ])
    error_message = "Invalid taint effect in worker_defaults.taints. Allowed: NoSchedule, PreferNoSchedule, NoExecute."
  }
}

variable "bootstrap_node" {
  description = "Node address for talos bootstrap action. If null, first control-plane node is used."
  type        = string
  default     = null
}

variable "bootstrap_endpoint" {
  description = "Talos API endpoint for bootstrap node. If null, first control-plane endpoint is used."
  type        = string
  default     = null
}

variable "talosconfig_endpoints" {
  description = "Talos API endpoints list to be written into talosconfig. If empty, all control-plane endpoints are used."
  type        = list(string)
  default     = []
}

variable "kubeconfig_server_host" {
  description = "Host to write into kubeconfig server URL. If null, cluster_endpoint_host is used."
  type        = string
  default     = null
}

variable "apply_mode" {
  description = <<EOF
Apply mode for `talos_machine_configuration_apply`.

Allowed values:
- `auto`: regular apply.
- `staged`: staged apply mode (typically used when changes may require reboot/coordination).
- `staged_if_needing_reboot`: provider performs dry-run and chooses `staged` only if reboot is required, otherwise `auto`.
EOF
  type        = string
  default     = "auto"

  validation {
    condition = contains([
      "auto",
      "staged",
      "staged_if_needing_reboot",
    ], var.apply_mode)
    error_message = "Invalid apply_mode. Allowed values: auto, staged, staged_if_needing_reboot."
  }
}

variable "control_plane_allow_schedule" {
  description = "Allow workload scheduling on control-plane nodes."
  type        = bool
  default     = false
}

variable "additional_api_server_cert_sans" {
  description = "Additional SAN values added to Talos machine certSANs patch."
  type        = list(string)
  default     = []
}

variable "control_plane_config_patches" {
  description = "Extra config patches applied to all control-plane nodes."
  type        = list(string)
  default     = []
}

variable "worker_config_patches" {
  description = "Extra config patches applied to all worker nodes."
  type        = list(string)
  default     = []
}

variable "rollout_control_plane_names" {
  description = "Control-plane rollout filter: null = all nodes, [] = no nodes, [names...] = selected nodes only."
  type        = list(string)
  default     = null
  nullable    = true
}

variable "rollout_worker_names" {
  description = "Worker rollout filter: null = all nodes, [] = no nodes, [names...] = selected nodes only."
  type        = list(string)
  default     = null
  nullable    = true
}
