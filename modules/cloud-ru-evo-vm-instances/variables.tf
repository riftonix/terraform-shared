variable "project_id" {
  description = "Cloud.ru Evolution project ID."
  type        = string
}

variable "image_name" {
  description = "Name of VM image used for root disk."
  type        = string
}

variable "flavor_name" {
  description = "Name of VM flavor."
  type        = string
}

variable "zone_name" {
  description = "Default availability zone name for all nodes."
  type        = string
}

variable "network_name" {
  description = "Default subnet name for VM interfaces. If null, each node must define network_name."
  type        = string
  default     = null
}

variable "network_id" {
  description = "Default subnet ID for VM interfaces. If set, has priority over network_name."
  type        = string
  default     = null
}

variable "root_volume_size_gb" {
  description = "Default root volume size in GB."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size_gb > 0
    error_message = "`root_volume_size_gb` must be greater than 0."
  }
}

variable "root_volume_type" {
  description = "Default disk type name for root volume."
  type        = string
}

variable "user_data" {
  description = "Default cloud-init userdata for all nodes."
  type        = string
  default     = null
}

variable "security_groups" {
  description = "Default security groups names for all nodes (overridable per node)."
  type        = list(string)
  default     = []
}

variable "nodes" {
  description = "Instances map keyed by node name."
  type = map(object({
    network_id          = optional(string)
    network_name        = optional(string)
    root_volume_size_gb = optional(number)
    root_volume_type    = optional(string)
    user_data           = optional(string)
    security_groups     = optional(list(string))
    fixed_ip_v4         = optional(string)
    zone_name           = optional(string)
  }))

  validation {
    condition     = length(var.nodes) > 0
    error_message = "At least one node must be provided in `nodes`."
  }
}
