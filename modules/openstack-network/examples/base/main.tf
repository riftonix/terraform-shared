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
  alias       = "ru2"
  auth_url    = var.openstack_auth_url
  domain_name = var.openstack_domain_name
  tenant_id   = var.openstack_tenant_id
  user_name   = var.openstack_username
  password    = var.openstack_password
  region      = "ru-2"
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

module "network_ru2" {
  source = "../../"

  providers = {
    openstack = openstack.ru2
  }

  network_name = "common-network-ru2"

  subnets = {
    common = {
      cidr            = "172.31.0.0/24"
      ip_version      = 4
      enable_dhcp     = true
      dns_nameservers = ["188.93.16.19", "188.93.17.19"]
      allocation_pools = [
        {
          start = "172.31.0.2"
          end   = "172.31.0.254"
        }
      ]
    }
  }
}

module "network_kz1" {
  source = "../../"

  providers = {
    openstack = openstack.kz1
  }

  network_name = "common-network-kz1"

  subnets = {
    common = {
      cidr            = "172.30.0.0/24"
      ip_version      = 4
      enable_dhcp     = true
      dns_nameservers = ["188.93.16.19", "188.93.17.19"]
      allocation_pools = [
        {
          start = "172.30.0.2"
          end   = "172.30.0.254"
        }
      ]
    }
  }
}

output "network_ru2" {
  description = "Created network and subnets in ru-2"
  value       = module.network_ru2
}

output "network_kz1" {
  description = "Created network and subnets in kz-1"
  value       = module.network_kz1
}

