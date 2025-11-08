terraform {
  required_version = ">= 1.9.0"
  required_providers {
    twc = {
      source  = "tf.timeweb.cloud/timeweb-cloud/timeweb-cloud"
      version = "1.6.6"
    }
  }
}

variable "timeweb_token" {
  description = "TimeWebCloud Token"
  type        = string
  sensitive   = true
}

provider "twc" {
  token = var.timeweb_token
}

module "twc_server_ubuntu" {
  source = "../../"

  name               = "ubuntu"
  location           = "ru-1"
  availability_zone  = "spb-3"
  create_floating_ip = false

  os = {
    name    = "ubuntu"
    version = "22.04"
  }

  preset = {
    cpu  = 1
    ram  = 1
    disk = 15
  }
}