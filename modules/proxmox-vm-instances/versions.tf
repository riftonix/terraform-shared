terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.6.0"
    }
  }
}
