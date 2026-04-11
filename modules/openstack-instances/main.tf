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
  name = var.network_name
}

data "openstack_networking_network_v2" "per_node" {
  for_each = {
    for name, node in var.nodes : name => node
    if try(node.network_name, null) != null
  }

  name = each.value.network_name
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
    uuid = try(
      data.openstack_networking_network_v2.per_node[each.key].id,
      data.openstack_networking_network_v2.this[0].id
    )
    fixed_ip_v4 = try(each.value.fixed_ip_v4, null)
  }
}
