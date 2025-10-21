variable "timeweb_token" {
  description = "Timeweb cloud token, more info https://github.com/timeweb-cloud/terraform-provider-timeweb-cloud/tree/main"
  type        = string
  sensitive   = true
}

variable "servers" {
  type = map(object({
    availability_zone = string
    project_name      = optional(string)
    location          = optional(string)
    cpu_frequency     = optional(number)
    disk_type         = optional(string)
    preset = optional(object({
      cpu  = number
      ram  = number
      disk = number

      price = optional(object({
        min = number
        max = number
      }))
    }))

    software = optional(object({
      name       = string
      os_family  = string
      os_name    = string
      os_version = string
    }))

    os = optional(object({
      name    = string
      version = string
    }))

    create_floating_ip = bool

    ssh_keys = optional(list(string))

    ssh_keys_paths = optional(list(object({
      name = string
      path = string
    })))
    cloud_init = optional(object({
      file = string
      vars = optional(map(string))
    }))

    configurator = optional(object({
      cpu  = number
      ram  = number
      disk = number
    }))
  }))

  default = {
    wireguard = {
      location          = "nl-1",
      availability_zone = "ams-1",
      preset = {
        cpu  = 1
        ram  = 1
        disk = 15
      }
      software = {
        name       = "Wireguard-GUI"
        os_family  = "linux"
        os_name    = "ubuntu"
        os_version = "22.04"
      }
      create_floating_ip = true
    }
  }
}
