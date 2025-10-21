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

module "twc_server_talos" {
  source = "../../"

  name               = "talos"
  location           = "nl-1"
  availability_zone  = "ams-1"
  create_floating_ip = false
  image_name         = "talos-amd64-v1.11.1"

  preset = {
    cpu  = 1
    ram  = 1
    disk = 15
  }
}