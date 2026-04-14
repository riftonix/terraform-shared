terraform {
  required_version = ">= 1.9.0"

  required_providers {
    beget = {
      source  = "tf.beget.com/beget/beget"
      version = "0.0.66"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.2.1"
    }
  }
}
