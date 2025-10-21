terraform {
  required_version = ">= 1.9.0"
  required_providers {
    twc = {
      source  = "tf.timeweb.cloud/timeweb-cloud/timeweb-cloud"
      version = "1.6.6"
    }
  }
}

provider "twc" {
  token = var.timeweb_token
}
