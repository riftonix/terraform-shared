data "openstack_images_image_v2" "this" {
  name        = var.image_name
  most_recent = true
  disk_format = var.image_disk_format
}

data "openstack_compute_flavor_v2" "this" {
  name = var.flavor_name
}

data "openstack_networking_network_v2" "this" {
  count = var.network_name != null ? 1 : 0
  name  = var.network_name
}

data "openstack_networking_network_v2" "per_node" {
  for_each = {
    for name, node in var.nodes : name => node
    if try(node.network_name, null) != null
  }

  name = each.value.network_name
}

locals {
  effective_network_id = {
    for name, node in var.nodes : name => coalesce(
      try(node.network_id, null),
      try(data.openstack_networking_network_v2.per_node[name].id, null),
      var.network_id,
      try(data.openstack_networking_network_v2.this[0].id, null)
    )
  }

  create_public_ip = {
    for name, node in var.nodes : name => coalesce(
      try(node.create_public_ip, null),
      var.create_public_ip
    )
  }

  nodes_with_public_ip = {
    for name, node in var.nodes : name => node
    if local.create_public_ip[name]
  }
}

resource "openstack_compute_instance_v2" "this" {
  for_each = var.nodes

  name              = each.key
  flavor_id         = data.openstack_compute_flavor_v2.this.id
  key_pair          = var.key_pair
  availability_zone = each.value.availability_zone != null ? each.value.availability_zone : var.availability_zone
  security_groups   = coalesce(try(each.value.security_groups, null), var.security_groups)
  tags              = distinct(concat(var.tags, try(each.value.tags, [])))
  metadata          = merge(var.metadata, try(each.value.metadata, {}))
  user_data         = each.value.user_data != null ? each.value.user_data : var.user_data

  block_device {
    source_type           = "image"
    uuid                  = data.openstack_images_image_v2.this.id
    destination_type      = "volume"
    volume_size           = coalesce(try(each.value.root_volume_size_gb, null), var.root_volume_size_gb)
    volume_type           = coalesce(try(each.value.root_volume_type, null), var.root_volume_type)
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid        = local.effective_network_id[each.key]
    fixed_ip_v4 = try(each.value.fixed_ip_v4, null)
  }
}

data "openstack_networking_port_v2" "public_ip" {
  for_each = local.nodes_with_public_ip

  device_id  = openstack_compute_instance_v2.this[each.key].id
  network_id = local.effective_network_id[each.key]

  depends_on = [openstack_compute_instance_v2.this]
}

resource "openstack_networking_floatingip_v2" "this" {
  for_each = local.nodes_with_public_ip

  pool = var.public_ip_pool
}

resource "openstack_networking_floatingip_associate_v2" "this" {
  for_each = local.nodes_with_public_ip

  floating_ip = openstack_networking_floatingip_v2.this[each.key].address
  port_id     = data.openstack_networking_port_v2.public_ip[each.key].id
}
