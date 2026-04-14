terraform {
  required_version = ">= 1.9.0"

  required_providers {
    beget = {
      source  = "tf.beget.com/beget/beget"
      version = "0.0.66"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.2.1"
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

resource "beget_private_network" "ru2" {
  region = "ru2"
}

resource "beget_private_network" "lv1" {
  region = "lv1"
}

module "routeros_instances" {
  source = "../../"

  cpu       = 1
  ram_mb    = 1024
  disk_mb   = 10240
  cpu_class = "normal_cpu"

  create_additional_ip = false

  nodes = {
    rurouter = {
      region             = "ru2"
      image_id           = "97487cc6-1a18-4f04-b698-010a1f69b0d2"
      private_network_id = beget_private_network.ru2.id
    }
    # lvrouter = {
    #   region             = "lv1"
    #   image_id           = "516140e3-9637-45fb-b37e-8480a51fd165"
    #   private_network_id = beget_private_network.lv1.id
    # }
  }
}

resource "random_password" "rurouter" {
  length  = 20
  special = false
}

resource "random_password" "lvrouter" {
  length  = 20
  special = false
}

output "routeros_instances" {
  description = "Raw instances output from module routeros_instances"
  value       = module.routeros_instances.instances
  sensitive   = true
}

output "routeros_nodes" {
  description = "Normalized nodes output from module routeros_instances"
  value       = module.routeros_instances.nodes
}

output "rurouter_access" {
  description = "RouterOS access credentials and address"
  value = {
    address = coalesce(
      module.routeros_instances.instances["rurouter"].additional_ip,
      module.routeros_instances.instances["rurouter"].ip_address
    )
    login    = "admin"
    password = random_password.rurouter.result
  }
  sensitive = true
}
