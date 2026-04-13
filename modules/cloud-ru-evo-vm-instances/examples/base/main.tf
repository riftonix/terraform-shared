terraform {
  required_providers {
    cloudru = {
      source  = "cloud.ru/cloudru/cloud"
      version = "2.0.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
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

resource "cloudru_evolution_vpc_vpc" "general" {
  project_id  = var.project_id
  name        = "vpc-general"
  description = "General vpc"
}

resource "cloudru_evolution_compute_subnet" "general" {
  vpc_id         = cloudru_evolution_vpc_vpc.general.id
  project_id     = var.project_id
  name           = "subnet-general"
  subnet_address = "10.42.0.0/24"
  routed_network = true

  zone_identifier = {
    name = "ru.AZ-2"
  }
}

module "routeros_instances" {
  source = "../../"

  project_id   = var.project_id
  image_name   = "routeros-7.20.8"
  zone_name    = "ru.AZ-2"
  network_id   = cloudru_evolution_compute_subnet.general.id

  flavor_name         = "lowcost10-1-1"
  root_volume_type    = "HDD"
  root_volume_size_gb = 10

  nodes = {
    "rurouter" = {}
  }
}

resource "cloudru_evolution_compute_external_ip" "rurouter" {
  project_id = var.project_id
  name       = "rurouter-external-ip"

  zone_identifier = {
    name = "ru.AZ-2"
  }

  interface_id = module.routeros_instances.instances["rurouter"].interface_id

  depends_on = [module.routeros_instances]
}

resource "random_password" "rurouter" {
  length  = 20
  special = false
}

resource "null_resource" "rurouter_init" {
  triggers = {
    lock_file = "${path.module}/.rurouter-init.lock"
    router_ip = coalesce(
      try(cloudru_evolution_compute_external_ip.rurouter.ip_address, null),
      module.routeros_instances.instances["rurouter"].access_ip_v4,
      module.routeros_instances.instances["rurouter"].fixed_ip_v4
    )
  }

  provisioner "local-exec" {
    command = "sh ${path.module}/scripts/routeros-init.sh"

    environment = {
      LOCK_FILE    = self.triggers.lock_file
      ROUTER_IP    = self.triggers.router_ip
      NEW_PASSWORD = random_password.rurouter.result
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f \"${self.triggers.lock_file}\""
  }

  depends_on = [module.routeros_instances]
}


output "routeros_instances" {
  description = "Raw instances output from module routeros_instances"
  value       = module.routeros_instances.instances
}

output "routeros_nodes" {
  description = "Normalized nodes output from module routeros_instances"
  value       = module.routeros_instances.nodes
}

output "routeros_access" {
  description = "RouterOS access credentials and address"
  value = {
    address  = cloudru_evolution_compute_external_ip.rurouter.ip_address
    login    = "admin"
    password = random_password.rurouter.result
  }
  sensitive = true
}
