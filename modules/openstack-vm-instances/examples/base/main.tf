terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.4.0"
    }
  }
}

variable "openstack_auth_url" {
  description = "OpenStack auth URL"
  type        = string
  sensitive   = true
}

variable "openstack_domain_name" {
  description = "OpenStack domain name"
  type        = string
  sensitive   = true
}

variable "openstack_tenant_id" {
  description = "OpenStack project id"
  type        = string
  sensitive   = true
}

variable "openstack_username" {
  description = "OpenStack login"
  type        = string
  sensitive   = true
}

variable "openstack_password" {
  description = "OpenStack password"
  type        = string
  sensitive   = true
}

provider "openstack" {
  alias       = "kz1"
  auth_url    = var.openstack_auth_url
  domain_name = var.openstack_domain_name
  tenant_id   = var.openstack_tenant_id
  user_name   = var.openstack_username
  password    = var.openstack_password
  region      = "kz-1"
}

module "network_example" {
  source = "../../../openstack-network"

  providers = {
    openstack = openstack.kz1
  }

  network_name = "example-network-kz1"

  subnets = {
    example = {
      cidr            = "172.20.20.0/24"
      ip_version      = 4
      enable_dhcp     = true
      dns_nameservers = ["188.93.16.19", "188.93.17.19"]
      allocation_pools = [
        {
          start = "172.20.20.2"
          end   = "172.20.20.254"
        }
      ]
    }
  }
}

module "router_example" {
  source = "../../../openstack-router"

  providers = {
    openstack = openstack.kz1
  }

  router_name = "example-router-kz1"

  # Network modules can be passed as full module output; router reads `input_subnets` key by default
  openstack_network_modules = [module.network_example]
}

module "instance_example" {
  source = "../../"

  providers = {
    openstack = openstack.kz1
  }

  image_name          = "routeros-7.20.8"
  root_volume_size_gb = 5
  root_volume_type    = "basic.kz-1a"
  availability_zone   = "kz-1a"
  network_id          = module.network_example.network.id
  create_public_ip    = true
  flavor_name         = "PRC10.1-512"
  # security_groups     = ["default"]

  nodes = {
    example = {}
  }

  depends_on = [module.router_example]
}

output "network_example" {
  description = "Created network and subnets in kz-1"
  value       = module.network_example
}

output "router_example" {
  description = "Created router and attached internal subnets in kz-1"
  value       = module.router_example
}

output "instance_example" {
  description = "Created VM instance in kz-1"
  value       = module.instance_example
}
