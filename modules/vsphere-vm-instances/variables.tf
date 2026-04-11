variable "image_source_url" {
  description = "Remote OVA URL reachable from vCenter for OVF/OVA deployment."
  type        = string
}

variable "root_volume_size_gb" {
  description = "Default root disk size in GB. Must be >= source OVA disk size."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size_gb > 0
    error_message = "`root_volume_size_gb` must be greater than 0."
  }
}

variable "root_volume_type" {
  description = "Disk provisioning type for OVA deployment. One of: thin, thick, eagerZeroedThick."
  type        = string
  default     = "thin"

  validation {
    condition     = contains(["thin", "thick", "eagerZeroedThick"], var.root_volume_type)
    error_message = "`root_volume_type` must be one of: thin, thick, eagerZeroedThick."
  }
}

variable "network_path" {
  description = "Default vSphere network path/name. If null, each node must define network_name."
  type        = string
  default     = null
}

variable "ovf_network_label" {
  description = "OVF network label to map onto selected vSphere network."
  type        = string
  default     = "VM Network"
}

variable "nodes" {
  description = "Instances map keyed by node name."
  type = map(object({
    network_name        = optional(string)
    datastore_name      = optional(string)
    resource_pool_name  = optional(string)
    compute_cluster_name = optional(string)
    num_cpus            = optional(number)
    num_cores_per_socket = optional(number)
    memory_mb           = optional(number)
    root_volume_size_gb = optional(number)
    root_volume_type    = optional(string)
    fixed_ip_v4         = optional(string)
    user_data           = optional(string)
    metadata            = optional(map(string), {})
    vsphere_host        = optional(string)
  }))

  validation {
    condition     = length(var.nodes) > 0
    error_message = "At least one node must be provided in `nodes`."
  }

  validation {
    condition = var.network_path != null || alltrue([
      for _, node in var.nodes : try(node.network_name, null) != null
    ])
    error_message = "If `network_path` is not set, every node in `nodes` must define `network_name`."
  }

  validation {
    condition = var.vsphere_host != null || alltrue([
      for _, node in var.nodes : try(node.vsphere_host, null) != null
    ])
    error_message = "If `vsphere_host` is not set, every node in `nodes` must define `vsphere_host`."
  }

  validation {
    condition = var.datastore_name != null || alltrue([
      for _, node in var.nodes : try(node.datastore_name, null) != null
    ])
    error_message = "If `datastore_name` is not set, every node in `nodes` must define `datastore_name`."
  }

  validation {
    condition = alltrue([
      for _, node in var.nodes : !(try(node.resource_pool_name, null) != null && try(node.compute_cluster_name, null) != null)
    ])
    error_message = "Each node may define only one of `resource_pool_name` or `compute_cluster_name`, not both."
  }
}

variable "metadata" {
  description = "Default metadata for all nodes (merged with per-node metadata)."
  type        = map(string)
  default     = {}
}

variable "user_data" {
  description = "Default user_data for all nodes (mapped to vApp property `user-data`)."
  type        = string
  default     = null
}

variable "vsphere_host" {
  description = "Default vSphere host name used as deployment target for OVF parsing and placement."
  type        = string
  default     = null
}

variable "datacenter_name" {
  description = "vSphere Datacenter name."
  type        = string
}

variable "resource_pool_name" {
  description = "Default resource pool name (for example: cluster/Resources). Mutually exclusive with global compute_cluster_name."
  type        = string
  default     = null

  validation {
    condition     = !(var.resource_pool_name != null && var.compute_cluster_name != null)
    error_message = "Only one of global `resource_pool_name` or `compute_cluster_name` can be set."
  }
}

variable "compute_cluster_name" {
  description = "Optional default compute cluster name used to resolve root resource pool when `resource_pool_name` is not set."
  type        = string
  default     = null
}

variable "datastore_name" {
  description = "Default datastore name. If null, each node must define datastore_name."
  type        = string
  default     = null
}

variable "num_cpus" {
  description = "Default vCPU count for all nodes. If null, OVA default is used."
  type        = number
  default     = null

  validation {
    condition     = var.num_cpus == null || var.num_cpus > 0
    error_message = "`num_cpus` must be greater than 0 when set."
  }
}

variable "num_cores_per_socket" {
  description = "Default cores per socket for all nodes. If null, OVA default is used."
  type        = number
  default     = null

  validation {
    condition     = var.num_cores_per_socket == null || var.num_cores_per_socket > 0
    error_message = "`num_cores_per_socket` must be greater than 0 when set."
  }
}

variable "memory_mb" {
  description = "Default memory size in MB for all nodes. If null, OVA default is used."
  type        = number
  default     = null

  validation {
    condition     = var.memory_mb == null || var.memory_mb > 0
    error_message = "`memory_mb` must be greater than 0 when set."
  }
}

variable "sync_time_with_host" {
  description = "Enable synchronization of guest time with ESXi host. Global setting for all nodes."
  type        = bool
  default     = true
}

variable "disk_io_share_count" {
  description = "Disk I/O shares count for the root disk. Global setting for all nodes."
  type        = number
  default     = 0

  validation {
    condition     = var.disk_io_share_count >= 0
    error_message = "`disk_io_share_count` must be greater than or equal to 0."
  }
}

variable "folder_path" {
  description = "Optional VM folder path in datacenter scope."
  type        = string
  default     = null
}

variable "allow_unverified_ovf_ssl_cert" {
  description = "Allow unverified SSL certificate when downloading remote OVA."
  type        = bool
  default     = true
}

variable "wait_for_guest_net_timeout" {
  description = "Minutes to wait for guest network information to appear. A value less than 1 disables the waiter."
  type        = number
  default     = 0

  validation {
    condition     = var.wait_for_guest_net_timeout >= 0
    error_message = "`wait_for_guest_net_timeout` must be greater than or equal to 0."
  }
}

variable "wait_for_guest_ip_timeout" {
  description = "Minutes to wait for guest IP address to appear. A value less than 1 disables the waiter."
  type        = number
  default     = 0

  validation {
    condition     = var.wait_for_guest_ip_timeout >= 0
    error_message = "`wait_for_guest_ip_timeout` must be greater than or equal to 0."
  }
}
