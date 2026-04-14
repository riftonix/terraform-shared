terraform {
  required_version = ">= 1.9.0"

  required_providers {
    beget = {
      source  = "tf.beget.com/beget/beget"
      version = "0.0.66"
    }
  }
}

variable "beget_token" {
  description = "Beget API token"
  type        = string
  sensitive   = true
}

provider "beget" {
  token = var.beget_token
}

data "beget_regions" "all" {}

data "beget_configuration_groups" "all" {}

data "beget_configurations" "all" {
  only_available = true
}

data "beget_softwares" "all" {}

data "beget_private_networks" "all" {}

output "regions" {
  description = "Available regions"
  value       = data.beget_regions.all.regions
}

output "configuration_groups" {
  description = "Available CPU configuration groups"
  value       = data.beget_configuration_groups.all.groups
}

output "configurations" {
  description = "Available VPS configurations"
  value = {
    for k, cfg in data.beget_configurations.all.configurations : k => {
      id      = cfg.id
      name    = cfg.name
      cpu     = cfg.cpu
      ram_mb  = cfg.ram_mb
      disk_mb = cfg.disk_mb
      group   = cfg.group
      region  = cfg.region
    }
  }
}

output "software_slugs" {
  description = "Marketplace software slugs"
  value       = keys(data.beget_softwares.all.softwares)
}

output "private_networks" {
  description = "Existing private networks"
  value       = data.beget_private_networks.all.networks
}

output "private_networks_all" {
  description = "All private networks with full objects"
  value       = data.beget_private_networks.all.networks
}
