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

module "talos" {
  source = "../.."

  target_node = var.target_node

  agent                  = 1
  os_type                = null
  qemu_os                = "l26"
  bios                   = "seabios"
  scsihw                 = "virtio-scsi-single"
  boot                   = "order=ide2;scsi0"
  bootdisk               = "scsi0"
  vm_state               = "running"
  define_connection_info = false

  cpu = {
    cores   = 4
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
    size     = "20G"
    format   = "raw"
    discard  = true
    iothread = true
  }

  data_volumes = {
    talos_iso = {
      slot = "ide2"
      type = "cdrom"
      iso  = "ISO:iso/talos-1.13.8-nocloud-amd64.iso"
    }
  }

  cloudinit = {
    enabled = false
  }

  nodes = {
    talos-control-plane-1 = {
      vmid = 301
    }
  }
}
