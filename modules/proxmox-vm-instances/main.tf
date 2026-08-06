locals {
  cloudinit_defaults = nonsensitive(var.cloudinit)

  networks_by_node = {
    for name, node in var.nodes : name => try(node.networks, null) != null ? node.networks : (var.networks != null ? var.networks : {})
  }

  data_volumes_by_node = {
    for name, node in var.nodes : name => try(node.data_volumes, null) != null ? node.data_volumes : (var.data_volumes != null ? var.data_volumes : {})
  }

  root_volume_by_node = {
    for name, node in var.nodes : name => try(node.root_volume, null) != null ? node.root_volume : var.root_volume
  }

  cloudinit_by_node = {
    for name, node in var.nodes : name => {
      enabled       = try(node.cloudinit.enabled, null) != null ? node.cloudinit.enabled : try(local.cloudinit_defaults.enabled, true)
      slot          = try(node.cloudinit.slot, null) != null ? node.cloudinit.slot : try(local.cloudinit_defaults.slot, "ide2")
      storage       = try(node.cloudinit.storage, null) != null ? node.cloudinit.storage : try(local.cloudinit_defaults.storage, null)
      ciuser        = try(node.cloudinit.ciuser, null) != null ? node.cloudinit.ciuser : try(local.cloudinit_defaults.ciuser, null)
      cipassword    = try(node.cloudinit.cipassword, null) != null ? node.cloudinit.cipassword : try(local.cloudinit_defaults.cipassword, null)
      cicustom      = try(node.cloudinit.cicustom, null) != null ? node.cloudinit.cicustom : try(local.cloudinit_defaults.cicustom, null)
      ciupgrade     = try(node.cloudinit.ciupgrade, null) != null ? node.cloudinit.ciupgrade : try(local.cloudinit_defaults.ciupgrade, false)
      ci_wait       = try(node.cloudinit.ci_wait, null) != null ? node.cloudinit.ci_wait : try(local.cloudinit_defaults.ci_wait, 30)
      searchdomain  = try(node.cloudinit.searchdomain, null) != null ? node.cloudinit.searchdomain : try(local.cloudinit_defaults.searchdomain, null)
      nameserver    = try(node.cloudinit.nameserver, null) != null ? node.cloudinit.nameserver : try(local.cloudinit_defaults.nameserver, null)
      sshkeys       = try(node.cloudinit.sshkeys, null) != null ? node.cloudinit.sshkeys : try(local.cloudinit_defaults.sshkeys, null)
      skip_ipv4     = try(node.cloudinit.skip_ipv4, null) != null ? node.cloudinit.skip_ipv4 : try(local.cloudinit_defaults.skip_ipv4, false)
      skip_ipv6     = try(node.cloudinit.skip_ipv6, null) != null ? node.cloudinit.skip_ipv6 : try(local.cloudinit_defaults.skip_ipv6, false)
      agent_timeout = try(node.cloudinit.agent_timeout, null) != null ? node.cloudinit.agent_timeout : try(local.cloudinit_defaults.agent_timeout, 90)
    }
  }

  cloudinit_disk_by_node = {
    for name, config in local.cloudinit_by_node : name => (
      try(config.enabled, true) && try(config.storage, null) != null
      ? {
        cloudinit = {
          slot    = try(config.slot, "ide2")
          type    = "cloudinit"
          storage = config.storage
        }
      }
      : {}
    )
  }

  root_disk_by_node = {
    for name, volume in local.root_volume_by_node : name => (
      volume == null ? {} : {
        root = merge(volume, {
          type = try(volume.type, "disk")
        })
      }
    )
  }

  disks_by_node = {
    for name, _ in var.nodes : name => merge(
      local.root_disk_by_node[name],
      local.data_volumes_by_node[name],
      local.cloudinit_disk_by_node[name]
    )
  }

  cpu_by_node = {
    for name, node in var.nodes : name => {
      cores    = try(node.cpu.cores, null) != null ? node.cpu.cores : var.cpu.cores
      sockets  = try(node.cpu.sockets, null) != null ? node.cpu.sockets : var.cpu.sockets
      type     = try(node.cpu.type, null) != null ? node.cpu.type : var.cpu.type
      numa     = try(node.cpu.numa, null) != null ? node.cpu.numa : var.cpu.numa
      limit    = try(node.cpu.limit, null) != null ? node.cpu.limit : var.cpu.limit
      units    = try(node.cpu.units, null) != null ? node.cpu.units : var.cpu.units
      vcores   = try(node.cpu.vcores, null) != null ? node.cpu.vcores : var.cpu.vcores
      affinity = try(node.cpu.affinity, null) != null ? node.cpu.affinity : var.cpu.affinity
      flags    = try(node.cpu.flags, null) != null ? node.cpu.flags : var.cpu.flags
    }
  }

  fixed_ipconfig0_by_node = {
    for name, node in var.nodes : name => (
      try(node.fixed_ip_v4, null) == null
      ? null
      : join(",", compact([
        "ip=${node.fixed_ip_v4}",
        try(node.gateway_v4, null) != null ? "gw=${node.gateway_v4}" : null,
      ]))
    )
  }

  ipconfig_by_node = {
    for name, node in var.nodes : name => merge(
      local.fixed_ipconfig0_by_node[name] == null ? {} : { "0" = local.fixed_ipconfig0_by_node[name] },
      try(node.ipconfig, {})
    )
  }

  metadata_by_node = {
    for name, node in var.nodes : name => merge(var.metadata, try(node.metadata, {}))
  }

  metadata_description_by_node = {
    for name, metadata in local.metadata_by_node : name => (
      var.include_metadata_in_description && length(metadata) > 0
      ? join("\n", concat(
        ["metadata:"],
        [for key in sort(keys(metadata)) : "${key}=${metadata[key]}"]
      ))
      : null
    )
  }

  description_by_node = {
    for name, node in var.nodes : name => join("\n\n", compact([
      try(node.description, null) != null ? node.description : var.description,
      local.metadata_description_by_node[name],
    ]))
  }
}

resource "proxmox_vm_qemu" "this" {
  for_each = var.nodes

  name        = each.key
  target_node = try(each.value.target_node, null) != null ? each.value.target_node : var.target_node
  vmid        = try(each.value.vmid, null)
  pool        = try(each.value.pool, null) != null ? each.value.pool : var.pool

  clone      = try(each.value.image_name, null) != null ? each.value.image_name : var.image_name
  clone_id   = try(each.value.image_id, null) != null ? each.value.image_id : var.image_id
  full_clone = try(each.value.full_clone, null) != null ? each.value.full_clone : var.full_clone

  description            = local.description_by_node[each.key] != "" ? local.description_by_node[each.key] : null
  tags                   = try(each.value.tags, null) != null ? each.value.tags : var.tags
  define_connection_info = try(each.value.define_connection_info, null) != null ? each.value.define_connection_info : var.define_connection_info

  bios               = try(each.value.bios, null) != null ? each.value.bios : var.bios
  agent              = try(each.value.agent, null) != null ? each.value.agent : var.agent
  os_type            = try(each.value.os_type, null) != null ? each.value.os_type : var.os_type
  qemu_os            = try(each.value.qemu_os, null) != null ? each.value.qemu_os : var.qemu_os
  scsihw             = try(each.value.scsihw, null) != null ? each.value.scsihw : var.scsihw
  boot               = try(each.value.boot, null) != null ? each.value.boot : var.boot
  bootdisk           = try(each.value.bootdisk, null) != null ? each.value.bootdisk : var.bootdisk
  vm_state           = try(each.value.vm_state, null) != null ? each.value.vm_state : var.vm_state
  start_at_node_boot = try(each.value.start_at_node_boot, null) != null ? each.value.start_at_node_boot : var.start_at_node_boot
  protection         = try(each.value.protection, null) != null ? each.value.protection : var.protection
  tablet             = try(each.value.tablet, null) != null ? each.value.tablet : var.tablet
  hotplug            = try(each.value.hotplug, null) != null ? each.value.hotplug : var.hotplug
  memory             = try(each.value.memory_mb, null) != null ? each.value.memory_mb : var.memory_mb
  balloon            = try(each.value.balloon, null) != null ? each.value.balloon : var.balloon

  ssh_user        = try(each.value.ssh_user, null) != null ? each.value.ssh_user : var.ssh_user
  ssh_private_key = try(each.value.ssh_private_key, null) != null ? each.value.ssh_private_key : var.ssh_private_key
  ssh_forward_ip  = try(each.value.ssh_forward_ip, null) != null ? each.value.ssh_forward_ip : var.ssh_forward_ip

  automatic_reboot            = try(each.value.automatic_reboot, null) != null ? each.value.automatic_reboot : var.automatic_reboot
  automatic_reboot_severity   = try(each.value.automatic_reboot_severity, null) != null ? each.value.automatic_reboot_severity : var.automatic_reboot_severity
  force_create                = try(each.value.force_create, null) != null ? each.value.force_create : var.force_create
  force_recreate_on_change_of = try(each.value.force_recreate_on_change_of, null) != null ? each.value.force_recreate_on_change_of : var.force_recreate_on_change_of

  ciuser        = try(local.cloudinit_by_node[each.key].ciuser, null)
  cipassword    = try(local.cloudinit_by_node[each.key].cipassword, null)
  cicustom      = try(local.cloudinit_by_node[each.key].cicustom, null)
  ciupgrade     = try(local.cloudinit_by_node[each.key].ciupgrade, false)
  ci_wait       = try(local.cloudinit_by_node[each.key].ci_wait, 30)
  searchdomain  = try(local.cloudinit_by_node[each.key].searchdomain, null)
  nameserver    = try(local.cloudinit_by_node[each.key].nameserver, null)
  sshkeys       = try(local.cloudinit_by_node[each.key].sshkeys, null)
  skip_ipv4     = try(local.cloudinit_by_node[each.key].skip_ipv4, false) ? true : null
  skip_ipv6     = try(local.cloudinit_by_node[each.key].skip_ipv6, false) ? true : null
  agent_timeout = try(local.cloudinit_by_node[each.key].agent_timeout, 90)

  ipconfig0  = lookup(local.ipconfig_by_node[each.key], "0", null)
  ipconfig1  = lookup(local.ipconfig_by_node[each.key], "1", null)
  ipconfig2  = lookup(local.ipconfig_by_node[each.key], "2", null)
  ipconfig3  = lookup(local.ipconfig_by_node[each.key], "3", null)
  ipconfig4  = lookup(local.ipconfig_by_node[each.key], "4", null)
  ipconfig5  = lookup(local.ipconfig_by_node[each.key], "5", null)
  ipconfig6  = lookup(local.ipconfig_by_node[each.key], "6", null)
  ipconfig7  = lookup(local.ipconfig_by_node[each.key], "7", null)
  ipconfig8  = lookup(local.ipconfig_by_node[each.key], "8", null)
  ipconfig9  = lookup(local.ipconfig_by_node[each.key], "9", null)
  ipconfig10 = lookup(local.ipconfig_by_node[each.key], "10", null)
  ipconfig11 = lookup(local.ipconfig_by_node[each.key], "11", null)
  ipconfig12 = lookup(local.ipconfig_by_node[each.key], "12", null)
  ipconfig13 = lookup(local.ipconfig_by_node[each.key], "13", null)
  ipconfig14 = lookup(local.ipconfig_by_node[each.key], "14", null)
  ipconfig15 = lookup(local.ipconfig_by_node[each.key], "15", null)

  cpu {
    cores    = local.cpu_by_node[each.key].cores
    sockets  = local.cpu_by_node[each.key].sockets
    type     = local.cpu_by_node[each.key].type
    numa     = local.cpu_by_node[each.key].numa
    limit    = local.cpu_by_node[each.key].limit
    units    = local.cpu_by_node[each.key].units
    vcores   = local.cpu_by_node[each.key].vcores
    affinity = local.cpu_by_node[each.key].affinity

    dynamic "flags" {
      for_each = length(local.cpu_by_node[each.key].flags) > 0 ? [local.cpu_by_node[each.key].flags] : []

      content {
        aes         = lookup(flags.value, "aes", null)
        amd_no_ssb  = lookup(flags.value, "amd_no_ssb", null)
        amd_ssbd    = lookup(flags.value, "amd_ssbd", null)
        hv_evmcs    = lookup(flags.value, "hv_evmcs", null)
        hv_tlbflush = lookup(flags.value, "hv_tlbflush", null)
        ibpb        = lookup(flags.value, "ibpb", null)
        md_clear    = lookup(flags.value, "md_clear", null)
        pbpe1gb     = lookup(flags.value, "pbpe1gb", null)
        pcid        = lookup(flags.value, "pcid", null)
        spec_ctrl   = lookup(flags.value, "spec_ctrl", null)
        ssbd        = lookup(flags.value, "ssbd", null)
        virt_ssbd   = lookup(flags.value, "virt_ssbd", null)
      }
    }
  }

  dynamic "network" {
    for_each = local.networks_by_node[each.key]

    content {
      id        = network.value.id
      model     = network.value.model
      bridge    = network.value.bridge
      macaddr   = try(network.value.macaddr, null)
      tag       = network.value.tag
      firewall  = network.value.firewall
      mtu       = try(network.value.mtu, null)
      rate      = network.value.rate
      queues    = network.value.queues
      link_down = network.value.link_down
    }
  }

  dynamic "disk" {
    for_each = local.disks_by_node[each.key]

    content {
      slot                 = disk.value.slot
      type                 = try(disk.value.type, "disk")
      storage              = try(disk.value.storage, null)
      size                 = try(disk.value.size, null)
      format               = try(disk.value.format, null)
      cache                = try(disk.value.cache, null)
      discard              = try(disk.value.discard, null)
      iothread             = try(disk.value.iothread, null)
      backup               = try(disk.value.backup, null)
      asyncio              = try(disk.value.asyncio, null)
      emulatessd           = try(disk.value.emulatessd, null)
      replicate            = try(disk.value.replicate, null)
      readonly             = try(disk.value.readonly, null)
      serial               = try(disk.value.serial, null)
      wwn                  = try(disk.value.wwn, null)
      iso                  = try(disk.value.iso, null)
      passthrough          = try(disk.value.passthrough, null)
      disk_file            = try(disk.value.disk_file, null)
      mbps_r_burst         = try(disk.value.mbps_r_burst, null)
      mbps_r_concurrent    = try(disk.value.mbps_r_concurrent, null)
      mbps_wr_burst        = try(disk.value.mbps_wr_burst, null)
      mbps_wr_concurrent   = try(disk.value.mbps_wr_concurrent, null)
      iops_r_burst         = try(disk.value.iops_r_burst, null)
      iops_r_burst_length  = try(disk.value.iops_r_burst_length, null)
      iops_r_concurrent    = try(disk.value.iops_r_concurrent, null)
      iops_wr_burst        = try(disk.value.iops_wr_burst, null)
      iops_wr_burst_length = try(disk.value.iops_wr_burst_length, null)
      iops_wr_concurrent   = try(disk.value.iops_wr_concurrent, null)
    }
  }

  lifecycle {
    precondition {
      condition     = !(var.image_name != null && var.image_id != null)
      error_message = "Only one of global `image_name` or `image_id` can be set."
    }

    precondition {
      condition     = (try(each.value.target_node, null) != null ? each.value.target_node : var.target_node) != null
      error_message = "If `target_node` is not set globally, every node must define `target_node`."
    }

    precondition {
      condition = !(
        (try(each.value.image_name, null) != null ? each.value.image_name : var.image_name) != null &&
        (try(each.value.image_id, null) != null ? each.value.image_id : var.image_id) != null
      )
      error_message = "Each node can resolve at most one clone source: `image_name` or `image_id`."
    }
  }
}
