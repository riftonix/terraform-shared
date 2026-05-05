terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url  = var.pm_api_url
  pm_user     = var.pm_user
  pm_password = var.pm_password
  # pm_api_token_id     = var.pm_api_token_id
  # pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure = var.pm_tls_insecure
}

module "routeros" {
  source = "../.."

  image_name  = "routeros-7.20.8.img"
  target_node = var.target_node

  agent      = 0
  os_type    = null
  qemu_os    = "other"
  bios       = "seabios"
  scsihw     = "virtio-scsi-single"
  boot       = "order=scsi0"
  bootdisk   = "scsi0"
  vm_state   = "running"
  full_clone = true

  cpu = {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  memory_mb = 4096

  networks = {
    net0 = {
      id     = 0
      model  = "virtio"
      bridge = var.network_bridge
    }
  }

  root_volume = {
    slot     = "scsi0"
    storage  = var.storage
    size     = "5G"
    format   = "raw"
    cache    = "none"
    discard  = true
    iothread = true
  }

  cloudinit = {
    enabled = false
  }

  nodes = {
    routeros-1 = {}
  }
}

output "instances" {
  value = module.routeros.instances
}

output "nodes" {
  value = module.routeros.nodes
}
