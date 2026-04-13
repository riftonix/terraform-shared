terraform {
  required_version = ">= 1.9.0"

  required_providers {
    cloudru = {
      source  = "cloud.ru/cloudru/cloud"
      version = "2.0.0"
    }
  }
}

variable "auth_key_id" {
  description = "Cloud.ru Evolution auth key id"
  type        = string
  sensitive   = true
}

variable "auth_secret" {
  description = "Cloud.ru Evolution auth secret"
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "Cloud.ru Evolution project id"
  type        = string
}

provider "cloudru" {
  project_id  = var.project_id
  auth_key_id = var.auth_key_id
  auth_secret = var.auth_secret
  region      = "ru-central-1"

  endpoints = {
    iam_endpoint            = "iam.api.cloud.ru:443"
    compute_endpoint        = "compute.api.cloud.ru:443"
    baremetal_endpoint      = "baremetal.api.cloud.ru:443"
    vpc_endpoint            = "vpc.api.cloud.ru:443"
    magic_router_endpoint   = "magic-router.api.cloud.ru"
    dns_endpoint            = "dns.api.cloud.ru:443"
    nlb_endpoint            = "nlb.api.cloud.ru"
    kafka_endpoint          = "kafka.api.cloud.ru:443"
    redis_endpoint          = "redis.api.cloud.ru:443"
    object_storage_endpoint = "https://s3.cloud.ru"
  }
}

data "cloudru_evolution_compute_flavor_collection" "available" {
  project_id = var.project_id
  page_size  = 1000
}

data "cloudru_evolution_compute_image_collection" "available" {
  project_id = var.project_id
  page_size  = 1000
}

data "cloudru_evolution_compute_zone_collection" "available" {
  project_id = var.project_id
  page_size  = 1000
}

data "cloudru_evolution_compute_subnet_collection" "available" {
  project_id = var.project_id
  page_size  = 1000
}

data "cloudru_evolution_compute_disk_type_collection" "available" {
  project_id = var.project_id
  page_size  = 1000
}

output "available_flavors" {
  description = "Available flavors in current project"
  value = [
    for flavor in coalesce(data.cloudru_evolution_compute_flavor_collection.available.flavors, []) : {
      name = try(flavor.name, null)
      cpu  = try(flavor.cpu, null)
      ram  = try(flavor.ram, null)
      gpu  = try(flavor.gpu, null)
    }
  ]
}

output "available_images" {
  description = "Available images in current project"
  value = [
    for image in coalesce(data.cloudru_evolution_compute_image_collection.available.images, []) : image.name
  ]
}

output "available_zones" {
  description = "Available zones in current project"
  value       = coalesce(data.cloudru_evolution_compute_zone_collection.available.zones, [])
}

output "available_networks" {
  description = "Available networks (subnets) in current project"
  value       = coalesce(data.cloudru_evolution_compute_subnet_collection.available.subnets, [])
}

output "available_volume_types" {
  description = "Available volume (disk) types in current project"
  value       = coalesce(data.cloudru_evolution_compute_disk_type_collection.available.disk_types, [])
}
