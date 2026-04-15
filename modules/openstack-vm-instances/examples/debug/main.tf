terraform {
  required_version = ">= 1.9.0"

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

variable "image_name_regex" {
  description = "Optional regex to filter image IDs (e.g. ^Ubuntu.*)"
  type        = string
  default     = "routeros-7.20.8"
}

variable "security_group_name" {
  description = "Optional security group name to inspect"
  type        = string
  default     = "default"
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

data "openstack_compute_availability_zones_v2" "all_ru2" {
  provider = openstack.ru2
}

data "openstack_compute_availability_zones_v2" "all_kz1" {
  provider = openstack.kz1
}

data "openstack_images_image_ids_v2" "all_ru2" {
  provider   = openstack.ru2
  name_regex = var.image_name_regex
  sort       = "updated_at:desc"
}

data "openstack_images_image_ids_v2" "all_kz1" {
  provider   = openstack.kz1
  name_regex = var.image_name_regex
  sort       = "updated_at:desc"
}

data "openstack_networking_subnet_ids_v2" "all_ru2" {
  provider = openstack.ru2
}

data "openstack_networking_subnet_ids_v2" "all_kz1" {
  provider = openstack.kz1
}

data "openstack_networking_port_ids_v2" "all_ru2" {
  provider = openstack.ru2
}

data "openstack_networking_port_ids_v2" "all_kz1" {
  provider = openstack.kz1
}

data "openstack_networking_secgroup_v2" "selected_ru2" {
  provider = openstack.ru2
  count    = var.security_group_name != null ? 1 : 0
  name     = var.security_group_name
}

data "openstack_networking_secgroup_v2" "selected_kz1" {
  provider = openstack.kz1
  count    = var.security_group_name != null ? 1 : 0
  name     = var.security_group_name
}

output "availability_zones_ru2" {
  description = "Available compute AZ names in ru-1"
  value       = data.openstack_compute_availability_zones_v2.all_ru2.names
}

output "availability_zones_kz1" {
  description = "Available compute AZ names in kz-1"
  value       = data.openstack_compute_availability_zones_v2.all_kz1.names
}

output "image_ids_ru2" {
  description = "Image IDs in ru-2 matching image_name_regex"
  value       = data.openstack_images_image_ids_v2.all_ru2.ids
}

output "image_ids_kz1" {
  description = "Image IDs in kz-1 matching image_name_regex"
  value       = data.openstack_images_image_ids_v2.all_kz1.ids
}

output "subnet_ids_ru2" {
  description = "All visible subnet IDs in ru-1"
  value       = data.openstack_networking_subnet_ids_v2.all_ru2.ids
}

output "subnet_ids_kz1" {
  description = "All visible subnet IDs in kz-1"
  value       = data.openstack_networking_subnet_ids_v2.all_kz1.ids
}

output "port_ids_ru2" {
  description = "All visible port IDs in ru-1"
  value       = data.openstack_networking_port_ids_v2.all_ru2.ids
}

output "port_ids_kz1" {
  description = "All visible port IDs in kz-1"
  value       = data.openstack_networking_port_ids_v2.all_kz1.ids
}

output "selected_security_group_ru2" {
  description = "Resolved security group details (if security_group_name is set)"
  value = var.security_group_name != null ? {
    id       = data.openstack_networking_secgroup_v2.selected_ru2[0].id
    name     = data.openstack_networking_secgroup_v2.selected_ru2[0].name
    stateful = data.openstack_networking_secgroup_v2.selected_ru2[0].stateful
    all_tags = data.openstack_networking_secgroup_v2.selected_ru2[0].all_tags
  } : null
}

output "selected_security_group_kz1" {
  description = "Resolved security group details (if security_group_name is set)"
  value = var.security_group_name != null ? {
    id       = data.openstack_networking_secgroup_v2.selected_kz1[0].id
    name     = data.openstack_networking_secgroup_v2.selected_kz1[0].name
    stateful = data.openstack_networking_secgroup_v2.selected_kz1[0].stateful
    all_tags = data.openstack_networking_secgroup_v2.selected_kz1[0].all_tags
  } : null
}
