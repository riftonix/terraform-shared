variable "image_name" {
  description = "Name of OpenStack image for instances."
  type        = string
}

variable "image_disk_format" {
  description = "Optional OpenStack image disk_format filter to avoid selecting an incompatible image (e.g. iso)."
  type        = string
  default     = null
}

variable "root_volume_size_gb" {
  description = "Default root volume size in GB for boot-from-volume instances."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size_gb > 0
    error_message = "`root_volume_size_gb` must be greater than 0."
  }
}

variable "root_volume_type" {
  description = "Default Cinder volume type for boot-from-volume root disk (e.g. ssd)."
  type        = string
  default     = null
}

variable "flavor_name" {
  description = "Name of OpenStack flavor for instances."
  type        = string
}

variable "network_name" {
  description = "Default OpenStack network where NICs will be attached. If null, each node must define network_name."
  type        = string
  default     = null
}

variable "nodes" {
  description = "Instances map keyed by node name."
  type = map(object({
    network_name        = optional(string)
    root_volume_size_gb = optional(number)
    root_volume_type    = optional(string)
    fixed_ip_v4         = optional(string)
    user_data           = optional(string)
    metadata            = optional(map(string), {})
    tags                = optional(list(string), [])
    security_groups     = optional(list(string))
    availability_zone   = optional(string)
  }))

  validation {
    condition     = length(var.nodes) > 0
    error_message = "At least one node must be provided in `nodes`."
  }

  validation {
    condition = var.network_name != null || alltrue([
      for _, node in var.nodes : try(node.network_name, null) != null
    ])
    error_message = "If `network_name` is not set, every node in `nodes` must define `network_name`."
  }
}

variable "security_groups" {
  description = "Default security groups for all nodes (can be overridden per node)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Default tags for all nodes (merged with per-node tags)."
  type        = list(string)
  default     = []
}

variable "metadata" {
  description = "Default metadata for all nodes (merged with per-node metadata)."
  type        = map(string)
  default     = {}
}

variable "key_pair" {
  description = "Default OpenStack key pair name for all nodes."
  type        = string
  default     = null
}

variable "user_data" {
  description = "Default cloud-init user_data for all nodes."
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "Default availability zone for all nodes."
  type        = string
  default     = null
}
