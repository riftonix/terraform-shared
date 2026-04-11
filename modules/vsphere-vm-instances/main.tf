data "vsphere_datacenter" "this" {
  name = var.datacenter_name
}

data "vsphere_resource_pool" "this" {
  count         = var.resource_pool_name != null ? 1 : 0
  name          = var.resource_pool_name
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_resource_pool" "per_node" {
  for_each = {
    for name, node in var.nodes : name => node
    if try(node.resource_pool_name, null) != null
  }

  name          = each.value.resource_pool_name
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_compute_cluster" "this" {
  count         = var.resource_pool_name == null && var.compute_cluster_name != null ? 1 : 0
  name          = var.compute_cluster_name
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_compute_cluster" "per_node" {
  for_each = {
    for name, node in var.nodes : name => node
    if try(node.compute_cluster_name, null) != null
  }

  name          = each.value.compute_cluster_name
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_datastore" "this" {
  count         = var.datastore_name != null ? 1 : 0
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_datastore" "per_node" {
  for_each = {
    for name, node in var.nodes : name => node
    if try(node.datastore_name, null) != null
  }

  name          = each.value.datastore_name
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_network" "this" {
  count         = var.network_path != null ? 1 : 0
  name          = var.network_path
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_network" "per_node" {
  for_each = {
    for name, node in var.nodes : name => node
    if try(node.network_name, null) != null
  }

  name          = each.value.network_name
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_host" "default" {
  count         = var.vsphere_host != null ? 1 : 0
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_host" "per_node" {
  for_each = {
    for name, node in var.nodes : name => node
    if try(node.vsphere_host, null) != null
  }

  name          = each.value.vsphere_host
  datacenter_id = data.vsphere_datacenter.this.id
}

locals {
  root_volume_type_by_node = {
    for name, node in var.nodes : name => coalesce(try(node.root_volume_type, null), var.root_volume_type)
  }

  resource_pool_id_by_node = {
    for name, node in var.nodes : name => coalesce(
      try(data.vsphere_resource_pool.per_node[name].id, null),
      try(data.vsphere_compute_cluster.per_node[name].resource_pool_id, null),
      try(data.vsphere_resource_pool.this[0].id, null),
      try(data.vsphere_compute_cluster.this[0].resource_pool_id, null),
      try(data.vsphere_host.per_node[name].resource_pool_id, null),
      try(data.vsphere_host.default[0].resource_pool_id, null)
    )
  }

  ovf_network_id_map_by_node = {
    for name, node in var.nodes : name => {
      (var.ovf_network_label) = try(
        data.vsphere_network.per_node[name].id,
        data.vsphere_network.this[0].id
      )
    }
  }

  merged_metadata_by_node = {
    for name, node in var.nodes : name => merge(var.metadata, try(node.metadata, {}))
  }

  vapp_properties_by_node = {
    for name, node in var.nodes : name => merge(
      local.merged_metadata_by_node[name],
      try(node.user_data, var.user_data) != null ? {
        "user-data" = try(node.user_data, var.user_data)
      } : {}
    )
  }

  num_cpus_by_node = {
    for name, node in var.nodes : name => coalesce(
      try(node.num_cpus, null),
      var.num_cpus,
      data.vsphere_ovf_vm_template.this[name].num_cpus
    )
  }

  num_cores_per_socket_by_node = {
    for name, node in var.nodes : name => coalesce(
      try(node.num_cores_per_socket, null),
      var.num_cores_per_socket,
      data.vsphere_ovf_vm_template.this[name].num_cores_per_socket
    )
  }

  memory_mb_by_node = {
    for name, node in var.nodes : name => coalesce(
      try(node.memory_mb, null),
      var.memory_mb,
      data.vsphere_ovf_vm_template.this[name].memory
    )
  }

  firmware_by_node = {
    for name, _ in var.nodes : name => (
      contains(["bios", "efi"], lower(trimspace(try(data.vsphere_ovf_vm_template.this[name].firmware, ""))))
      ? lower(trimspace(data.vsphere_ovf_vm_template.this[name].firmware))
      : null
    )
  }
}

data "vsphere_ovf_vm_template" "this" {
  for_each = var.nodes

  name              = each.key
  disk_provisioning = local.root_volume_type_by_node[each.key]
  resource_pool_id  = local.resource_pool_id_by_node[each.key]
  datastore_id      = try(data.vsphere_datastore.per_node[each.key].id, data.vsphere_datastore.this[0].id)
  host_system_id    = try(data.vsphere_host.per_node[each.key].id, data.vsphere_host.default[0].id)
  remote_ovf_url    = var.image_source_url
  ovf_network_map   = local.ovf_network_id_map_by_node[each.key]
}

resource "vsphere_virtual_machine" "this" {
  for_each = var.nodes

  name             = each.key
  datacenter_id    = data.vsphere_datacenter.this.id
  folder           = var.folder_path
  resource_pool_id = local.resource_pool_id_by_node[each.key]
  datastore_id     = try(data.vsphere_datastore.per_node[each.key].id, data.vsphere_datastore.this[0].id)

  num_cpus             = local.num_cpus_by_node[each.key]
  num_cores_per_socket = local.num_cores_per_socket_by_node[each.key]
  memory               = local.memory_mb_by_node[each.key]
  guest_id             = data.vsphere_ovf_vm_template.this[each.key].guest_id
  firmware             = local.firmware_by_node[each.key]
  scsi_type            = data.vsphere_ovf_vm_template.this[each.key].scsi_type
  sync_time_with_host  = var.sync_time_with_host

  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.this[each.key].ovf_network_map
    content {
      network_id  = network_interface.value
      ovf_mapping = network_interface.key
    }
  }

  disk {
    label = "disk0"
    size  = coalesce(try(each.value.root_volume_size_gb, null), var.root_volume_size_gb)
    io_share_count = var.disk_io_share_count

    thin_provisioned = local.root_volume_type_by_node[each.key] == "thin"
    eagerly_scrub    = local.root_volume_type_by_node[each.key] == "eagerZeroedThick"
  }

  ovf_deploy {
    remote_ovf_url            = data.vsphere_ovf_vm_template.this[each.key].remote_ovf_url
    disk_provisioning         = data.vsphere_ovf_vm_template.this[each.key].disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.this[each.key].ovf_network_map
    allow_unverified_ssl_cert = var.allow_unverified_ovf_ssl_cert
  }

  vapp {
    properties = local.vapp_properties_by_node[each.key]
  }

  wait_for_guest_net_timeout = var.wait_for_guest_net_timeout
  wait_for_guest_ip_timeout  = var.wait_for_guest_ip_timeout
}
