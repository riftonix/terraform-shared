variable "image_name" {
  description = "Default Proxmox VM/template name to clone from. Mutually exclusive with image_id."
  type        = string
  default     = null
}

variable "image_id" {
  description = "Default Proxmox VM/template ID to clone from. Mutually exclusive with image_name."
  type        = number
  default     = null
}

variable "target_node" {
  description = "Default PVE node name on which to place VMs. If null, each node must define target_node."
  type        = string
  default     = null
}

variable "pool" {
  description = "Default Proxmox resource pool."
  type        = string
  default     = null
}

variable "full_clone" {
  description = "Create full clones when cloning from a template. Set false for linked clones."
  type        = bool
  default     = true
}

variable "agent" {
  description = "Enable QEMU guest agent. Set to 1 when the guest image has qemu-guest-agent installed."
  type        = number
  default     = 1

  validation {
    condition     = contains([0, 1], var.agent)
    error_message = "`agent` must be 0 or 1."
  }
}

variable "os_type" {
  description = "Provisioning method used by the provider. For cloud-init templates use `cloud-init`."
  type        = string
  default     = "cloud-init"
}

variable "qemu_os" {
  description = "Guest OS type for Proxmox optimizations."
  type        = string
  default     = "l26"
}

variable "bios" {
  description = "VM BIOS type. One of: seabios, ovmf."
  type        = string
  default     = "seabios"

  validation {
    condition     = contains(["seabios", "ovmf"], var.bios)
    error_message = "`bios` must be one of: seabios, ovmf."
  }
}

variable "scsihw" {
  description = "SCSI controller to emulate."
  type        = string
  default     = "virtio-scsi-single"

  validation {
    condition = contains([
      "lsi",
      "lsi53c810",
      "megasas",
      "pvscsi",
      "virtio-scsi-pci",
      "virtio-scsi-single",
    ], var.scsihw)
    error_message = "`scsihw` must be a valid Proxmox SCSI controller type."
  }
}

variable "boot" {
  description = "Default VM boot order, for example `order=scsi0`."
  type        = string
  default     = "order=scsi0"
}

variable "bootdisk" {
  description = "Default boot disk slot."
  type        = string
  default     = "scsi0"
}

variable "vm_state" {
  description = "Desired VM state. One of: running, stopped, started."
  type        = string
  default     = "running"

  validation {
    condition     = contains(["running", "stopped", "started"], var.vm_state)
    error_message = "`vm_state` must be one of: running, stopped, started."
  }
}

variable "start_at_node_boot" {
  description = "Whether guests should start automatically when the Proxmox node boots."
  type        = bool
  default     = false
}

variable "protection" {
  description = "Enable VM protection from removal."
  type        = bool
  default     = false
}

variable "tablet" {
  description = "Enable USB tablet device."
  type        = bool
  default     = true
}

variable "hotplug" {
  description = "Comma-delimited hotplug features. Set to `0` to disable."
  type        = string
  default     = "network,disk,usb"
}

variable "memory_mb" {
  description = "Default VM memory in MB."
  type        = number
  default     = 2048

  validation {
    condition     = var.memory_mb > 0
    error_message = "`memory_mb` must be greater than 0."
  }
}

variable "balloon" {
  description = "Default minimum memory in MB for ballooning. 0 disables ballooning."
  type        = number
  default     = 0

  validation {
    condition     = var.balloon >= 0
    error_message = "`balloon` must be greater than or equal to 0."
  }
}

variable "cpu" {
  description = "Default CPU configuration."
  type = object({
    cores    = optional(number, 1)
    sockets  = optional(number, 1)
    type     = optional(string, "host")
    numa     = optional(bool, false)
    limit    = optional(number, 0)
    units    = optional(number, 0)
    vcores   = optional(number, 0)
    affinity = optional(string, "")
    flags    = optional(map(string), {})
  })
  default = {}

  validation {
    condition     = var.cpu.cores > 0 && var.cpu.sockets > 0 && var.cpu.limit >= 0 && var.cpu.units >= 0 && var.cpu.vcores >= 0
    error_message = "`cpu.cores` and `cpu.sockets` must be greater than 0; limit, units, and vcores must be >= 0."
  }
}

variable "networks" {
  description = "Default network interfaces for all nodes. Node-level networks override this map entirely when set."
  type = map(object({
    id        = number
    model     = optional(string, "virtio")
    bridge    = optional(string, "vmbr0")
    macaddr   = optional(string)
    tag       = optional(number, 0)
    firewall  = optional(bool, false)
    mtu       = optional(number)
    rate      = optional(number, 0)
    queues    = optional(number, 1)
    link_down = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, network in var.networks : network.id >= 0 && network.id <= 31
    ])
    error_message = "`networks[*].id` must be between 0 and 31."
  }

  validation {
    condition = length(distinct([
      for _, network in var.networks : network.id
    ])) == length(var.networks)
    error_message = "`networks[*].id` values must be unique."
  }
}

variable "root_volume" {
  description = "Default root disk configuration. Set to null to leave cloned template disks unmanaged by this module."
  type = object({
    slot                 = optional(string, "scsi0")
    storage              = string
    size                 = string
    format               = optional(string, "raw")
    type                 = optional(string, "disk")
    cache                = optional(string)
    discard              = optional(bool, false)
    iothread             = optional(bool, false)
    backup               = optional(bool, true)
    asyncio              = optional(string)
    emulatessd           = optional(bool, false)
    replicate            = optional(bool, false)
    readonly             = optional(bool, false)
    serial               = optional(string)
    wwn                  = optional(string)
    mbps_r_burst         = optional(number, 0)
    mbps_r_concurrent    = optional(number, 0)
    mbps_wr_burst        = optional(number, 0)
    mbps_wr_concurrent   = optional(number, 0)
    iops_r_burst         = optional(number, 0)
    iops_r_burst_length  = optional(number, 0)
    iops_r_concurrent    = optional(number, 0)
    iops_wr_burst        = optional(number, 0)
    iops_wr_burst_length = optional(number, 0)
    iops_wr_concurrent   = optional(number, 0)
  })
  default = null
}

variable "data_volumes" {
  description = "Default data volumes for all nodes. Node-level data_volumes override this map entirely when set."
  type = map(object({
    slot                 = string
    storage              = optional(string)
    size                 = optional(string)
    type                 = optional(string, "disk")
    format               = optional(string, "raw")
    cache                = optional(string)
    discard              = optional(bool, false)
    iothread             = optional(bool, false)
    backup               = optional(bool, true)
    asyncio              = optional(string)
    emulatessd           = optional(bool, false)
    replicate            = optional(bool, false)
    readonly             = optional(bool, false)
    serial               = optional(string)
    wwn                  = optional(string)
    iso                  = optional(string)
    passthrough          = optional(bool, false)
    disk_file            = optional(string)
    mbps_r_burst         = optional(number, 0)
    mbps_r_concurrent    = optional(number, 0)
    mbps_wr_burst        = optional(number, 0)
    mbps_wr_concurrent   = optional(number, 0)
    iops_r_burst         = optional(number, 0)
    iops_r_burst_length  = optional(number, 0)
    iops_r_concurrent    = optional(number, 0)
    iops_wr_burst        = optional(number, 0)
    iops_wr_burst_length = optional(number, 0)
    iops_wr_concurrent   = optional(number, 0)
  }))
  default = {}
}

variable "cloudinit" {
  description = "Default cloud-init settings."
  type = object({
    enabled       = optional(bool, true)
    slot          = optional(string, "ide2")
    storage       = optional(string)
    ciuser        = optional(string)
    cipassword    = optional(string)
    cicustom      = optional(string)
    ciupgrade     = optional(bool, false)
    ci_wait       = optional(number, 30)
    searchdomain  = optional(string)
    nameserver    = optional(string)
    sshkeys       = optional(string)
    skip_ipv4     = optional(bool, false)
    skip_ipv6     = optional(bool, false)
    agent_timeout = optional(number, 90)
  })
  default   = {}
  sensitive = true
}

variable "metadata" {
  description = "Default metadata used only to build VM descriptions when include_metadata_in_description is true."
  type        = map(string)
  default     = {}
}

variable "include_metadata_in_description" {
  description = "Append merged metadata key/value lines to VM description."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Default comma-separated Proxmox tags."
  type        = string
  default     = null
}

variable "description" {
  description = "Default VM description."
  type        = string
  default     = null
}

variable "define_connection_info" {
  description = "Let the provider define SSH connection info for provisioners."
  type        = bool
  default     = true
}

variable "ssh_user" {
  description = "Default SSH user for provider connection info."
  type        = string
  default     = null
}

variable "ssh_private_key" {
  description = "Default SSH private key for provider connection info."
  type        = string
  default     = null
  sensitive   = true
}

variable "ssh_forward_ip" {
  description = "Default IP or IP:port to use for provider SSH connection info."
  type        = string
  default     = null
}

variable "automatic_reboot" {
  description = "Automatically reboot VMs when parameter changes require this."
  type        = bool
  default     = true
}

variable "automatic_reboot_severity" {
  description = "Severity when automatic_reboot is false and a reboot is required. One of: error, warning."
  type        = string
  default     = "error"

  validation {
    condition     = contains(["error", "warning"], var.automatic_reboot_severity)
    error_message = "`automatic_reboot_severity` must be one of: error, warning."
  }
}

variable "force_create" {
  description = "Always create a new VM instead of reconfiguring a same-name VM on the same node."
  type        = bool
  default     = false
}

variable "force_recreate_on_change_of" {
  description = "Arbitrary value that forces VM recreation when changed."
  type        = string
  default     = null
}

variable "nodes" {
  description = "Instances map keyed by VM name."
  type = map(object({
    image_name  = optional(string)
    image_id    = optional(number)
    target_node = optional(string)
    vmid        = optional(number)
    pool        = optional(string)

    description = optional(string)
    metadata    = optional(map(string), {})
    tags        = optional(string)

    full_clone                  = optional(bool)
    agent                       = optional(number)
    os_type                     = optional(string)
    qemu_os                     = optional(string)
    bios                        = optional(string)
    scsihw                      = optional(string)
    boot                        = optional(string)
    bootdisk                    = optional(string)
    vm_state                    = optional(string)
    start_at_node_boot          = optional(bool)
    protection                  = optional(bool)
    tablet                      = optional(bool)
    hotplug                     = optional(string)
    memory_mb                   = optional(number)
    balloon                     = optional(number)
    define_connection_info      = optional(bool)
    ssh_user                    = optional(string)
    ssh_private_key             = optional(string)
    ssh_forward_ip              = optional(string)
    automatic_reboot            = optional(bool)
    automatic_reboot_severity   = optional(string)
    force_create                = optional(bool)
    force_recreate_on_change_of = optional(string)

    fixed_ip_v4 = optional(string)
    gateway_v4  = optional(string)
    ipconfig    = optional(map(string), {})

    cpu = optional(object({
      cores    = optional(number)
      sockets  = optional(number)
      type     = optional(string)
      numa     = optional(bool)
      limit    = optional(number)
      units    = optional(number)
      vcores   = optional(number)
      affinity = optional(string)
      flags    = optional(map(string))
    }))

    networks = optional(map(object({
      id        = number
      model     = optional(string, "virtio")
      bridge    = optional(string, "vmbr0")
      macaddr   = optional(string)
      tag       = optional(number, 0)
      firewall  = optional(bool, false)
      mtu       = optional(number)
      rate      = optional(number, 0)
      queues    = optional(number, 1)
      link_down = optional(bool, false)
    })))

    root_volume = optional(object({
      slot                 = optional(string, "scsi0")
      storage              = string
      size                 = string
      format               = optional(string, "raw")
      type                 = optional(string, "disk")
      cache                = optional(string)
      discard              = optional(bool, false)
      iothread             = optional(bool, false)
      backup               = optional(bool, true)
      asyncio              = optional(string)
      emulatessd           = optional(bool, false)
      replicate            = optional(bool, false)
      readonly             = optional(bool, false)
      serial               = optional(string)
      wwn                  = optional(string)
      mbps_r_burst         = optional(number, 0)
      mbps_r_concurrent    = optional(number, 0)
      mbps_wr_burst        = optional(number, 0)
      mbps_wr_concurrent   = optional(number, 0)
      iops_r_burst         = optional(number, 0)
      iops_r_burst_length  = optional(number, 0)
      iops_r_concurrent    = optional(number, 0)
      iops_wr_burst        = optional(number, 0)
      iops_wr_burst_length = optional(number, 0)
      iops_wr_concurrent   = optional(number, 0)
    }))

    data_volumes = optional(map(object({
      slot                 = string
      storage              = optional(string)
      size                 = optional(string)
      type                 = optional(string, "disk")
      format               = optional(string, "raw")
      cache                = optional(string)
      discard              = optional(bool, false)
      iothread             = optional(bool, false)
      backup               = optional(bool, true)
      asyncio              = optional(string)
      emulatessd           = optional(bool, false)
      replicate            = optional(bool, false)
      readonly             = optional(bool, false)
      serial               = optional(string)
      wwn                  = optional(string)
      iso                  = optional(string)
      passthrough          = optional(bool, false)
      disk_file            = optional(string)
      mbps_r_burst         = optional(number, 0)
      mbps_r_concurrent    = optional(number, 0)
      mbps_wr_burst        = optional(number, 0)
      mbps_wr_concurrent   = optional(number, 0)
      iops_r_burst         = optional(number, 0)
      iops_r_burst_length  = optional(number, 0)
      iops_r_concurrent    = optional(number, 0)
      iops_wr_burst        = optional(number, 0)
      iops_wr_burst_length = optional(number, 0)
      iops_wr_concurrent   = optional(number, 0)
    })))

    cloudinit = optional(object({
      enabled       = optional(bool)
      slot          = optional(string)
      storage       = optional(string)
      ciuser        = optional(string)
      cipassword    = optional(string)
      cicustom      = optional(string)
      ciupgrade     = optional(bool)
      ci_wait       = optional(number)
      searchdomain  = optional(string)
      nameserver    = optional(string)
      sshkeys       = optional(string)
      skip_ipv4     = optional(bool)
      skip_ipv6     = optional(bool)
      agent_timeout = optional(number)
    }))
  }))

  validation {
    condition     = length(var.nodes) > 0
    error_message = "At least one node must be provided in `nodes`."
  }

  validation {
    condition = alltrue([
      for _, node in var.nodes : try(node.agent, null) == null || node.agent == 0 || node.agent == 1
    ])
    error_message = "`nodes[*].agent` must be 0 or 1."
  }

  validation {
    condition = alltrue([
      for _, node in var.nodes : (try(node.memory_mb, null) == null || node.memory_mb > 0) && (try(node.balloon, null) == null || node.balloon >= 0)
    ])
    error_message = "`nodes[*].memory_mb` must be greater than 0 and `nodes[*].balloon` must be >= 0."
  }
}
