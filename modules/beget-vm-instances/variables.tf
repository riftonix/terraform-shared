variable "region" {
  description = "Default Beget region for all nodes (e.g. ru1)."
  type        = string
  default     = null
}

variable "software_slug" {
  description = "Default software slug from Beget marketplace (e.g. ubuntu-24-04, routeros-7)."
  type        = string
  default     = null
}

variable "cpu" {
  description = "Default CPU cores count."
  type        = number
}

variable "ram_mb" {
  description = "Default RAM in MB."
  type        = number
}

variable "disk_mb" {
  description = "Default disk size in MB."
  type        = number
}

variable "cpu_class" {
  description = "Default CPU class (e.g. normal_cpu)."
  type        = string
}

variable "ssh_key_ids" {
  description = "Default existing SSH key IDs attached to instances."
  type        = list(number)
  default     = []
}

variable "ssh_public_key" {
  description = "Default SSH public key content (OpenSSH). If `ssh_key_ids` are empty, module will create beget_ssh_key and use it."
  type        = string
  default     = null
}

variable "create_additional_ip" {
  description = "Create and attach additional public IP for each node by default."
  type        = bool
  default     = false
}

variable "private_network_id" {
  description = "Default private network ID to attach instances."
  type        = string
  default     = null
}

variable "nodes" {
  description = "Instances map keyed by node name."
  type = map(object({
    region               = optional(string)
    software_slug        = optional(string)
    image_id             = optional(string)
    snapshot_id          = optional(number)
    cpu                  = optional(number)
    ram_mb               = optional(number)
    disk_mb              = optional(number)
    cpu_class            = optional(string)
    ssh_key_ids          = optional(list(number))
    ssh_public_key       = optional(string)
    create_additional_ip = optional(bool)
    private_network_id   = optional(string)
    private_network_ip   = optional(string)
    hostname             = optional(string)
    description          = optional(string)
    software_vars        = optional(map(string))
    isp_license_id       = optional(number)
  }))

  validation {
    condition     = length(var.nodes) > 0
    error_message = "At least one node must be provided in `nodes`."
  }
}
