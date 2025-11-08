variable "timeweb_token" {
  description = "TimeWebCloud Token"
  type        = string
  nullable    = true
  default     = null
}

variable "project_name" {
  description = "Name of existing project"
  type        = string
  default     = null
}

variable "name" {
  description = "Server name"
  type        = string
  default     = "Managed by terraform"
}

variable "availability_zone" {
  description = "Availability zone for cloud server and floating ip"
  type        = string
  default     = "spb-3"
}

variable "create_floating_ip" {
  description = "Create or not externam ip for cloud server"
  type        = bool
  default     = false
}

variable "image_name" {
  description = "Information about specified image"

  type = string

  default = null
}

variable "os" {
  description = "Information about specified OS"

  type = object({
    name    = string
    version = string
  })

  default = null
}

variable "software" {
  description = "Information about specified software"

  type = object({
    name       = string
    os_family  = string
    os_name    = string
    os_version = string
  })

  default = null
}

variable "local_network" {
  description = "Local network configuration"

  type = object({
    id   = string
    ip   = optional(string)
    mode = optional(string)
  })

  default = null
}

variable "ssh_keys" {
  description = "List of names SSH Keys for server"
  type        = list(string)
  default     = null
}

variable "ssh_keys_paths" {
  description = "Local paths of SSH Keys for server"
  type = list(object({
    name = string
    path = string
  }))
  default = null
}

variable "cloud_init" {
  description = "Cloud-init script path to file"
  type = object({
    file = string
    vars = optional(map(string))
  })
  default = null
}

variable "location" {
  description = "Location for the server (ru-1, ru-2, pl-1, kz-1, nl-1)"
  type        = string
  default     = null
}

variable "cpu_frequency" {
  description = "Current CPU frequency of server (2.8, 3.3, 5)"
  type        = number

  validation {
    condition     = contains([2.8, 3.3, 5], var.cpu_frequency)
    error_message = "Error! CPU frequency does not support"
  }
  default = 3.3
}

variable "preset" {
  description = "Settings for the server with preset"

  type = object({
    cpu  = number
    ram  = number
    disk = number

    price = optional(object({
      min = number
      max = number
    }))
  })

  default = null
}

variable "configurator" {
  description = "Settings for the server with configurator"

  type = object({
    cpu  = number
    ram  = number
    disk = number
  })

  default = null
}
