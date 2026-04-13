data "cloudru_evolution_compute_image_collection" "this" {
  project_id = var.project_id
  page_size  = 1000
}

data "cloudru_evolution_compute_flavor_collection" "this" {
  project_id = var.project_id
  page_size  = 1000
}

data "cloudru_evolution_compute_subnet_collection" "this" {
  project_id = var.project_id
  page_size  = 1000
}

locals {
  flavor_candidates = [
    for flavor in coalesce(data.cloudru_evolution_compute_flavor_collection.this.flavors, []) : flavor
    if flavor.name == var.flavor_name
  ]

  image_candidates = [
    for image in coalesce(data.cloudru_evolution_compute_image_collection.this.images, []) : image
    if image.name == var.image_name
  ]

  flavor_id = try(one(local.flavor_candidates).id, null)
  image_id  = try(one(local.image_candidates).id, null)

  network_id_by_node = {
    for name, node in var.nodes : name => coalesce(try(node.network_id, null), var.network_id)
  }

  network_name_by_node = {
    for name, node in var.nodes : name => (
      coalesce(try(node.network_id, null), var.network_id) != null
      ? null
      : coalesce(try(node.network_name, null), var.network_name)
    )
  }

  subnet_candidates_by_node = {
    for name, network_name in local.network_name_by_node : name => [
      for subnet in coalesce(data.cloudru_evolution_compute_subnet_collection.this.subnets, []) : subnet
      if subnet.name == network_name
    ]
  }

  subnet_id_by_node = {
    for name, subnets in local.subnet_candidates_by_node : name => coalesce(local.network_id_by_node[name], try(one(subnets).id, null))
  }

  security_groups_by_node = {
    for name, node in var.nodes : name => coalesce(try(node.security_groups, null), var.security_groups)
  }
}

resource "cloudru_evolution_compute_disk" "root" {
  for_each = var.nodes

  project_id = var.project_id
  name       = "${each.key}-root-volume"
  size       = coalesce(try(each.value.root_volume_size_gb, null), var.root_volume_size_gb)
  image_id   = local.image_id
  bootable    = true

  zone_identifier = {
    name = coalesce(try(each.value.zone_name, null), var.zone_name)
  }

  disk_type_identifier = {
    name = coalesce(try(each.value.root_volume_type, null), var.root_volume_type)
  }
}

resource "cloudru_evolution_compute_interface" "this" {
  for_each = var.nodes

  project_id = var.project_id
  name       = "${each.key}-nic0"
  subnet_id  = local.subnet_id_by_node[each.key]
  type       = "INTERFACE_TYPE_REGULAR"

  zone_identifier = {
    name = coalesce(try(each.value.zone_name, null), var.zone_name)
  }

  ip_address = try(each.value.fixed_ip_v4, null)

  security_groups_identifiers = length(local.security_groups_by_node[each.key]) > 0 ? {
    value = [
      for sg_name in local.security_groups_by_node[each.key] : {
        name = sg_name
      }
    ]
  } : null

  lifecycle {
    precondition {
      condition     = local.subnet_id_by_node[each.key] != null
      error_message = "Subnet not found for node `${each.key}`. Check `network_name` (global or per-node), project, and zone visibility."
    }
  }
}

resource "cloudru_evolution_compute_vm" "this" {
  for_each = var.nodes

  project_id = var.project_id
  name       = each.key

  zone_identifier = {
    name = coalesce(try(each.value.zone_name, null), var.zone_name)
  }

  flavor_identifier = {
    id = local.flavor_id
  }

  cloud_init_userdata = try(each.value.user_data, null) != null ? each.value.user_data : var.user_data

  disk_identifiers = [{
    disk_id = cloudru_evolution_compute_disk.root[each.key].id
  }]

  network_interfaces = [{
    interface_id = cloudru_evolution_compute_interface.this[each.key].id
  }]

  lifecycle {
    precondition {
      condition     = local.flavor_id != null
      error_message = "Flavor not found by name `${var.flavor_name}` in project `${var.project_id}`."
    }

    precondition {
      condition     = local.image_id != null
      error_message = "Image not found by name `${var.image_name}` in project `${var.project_id}`."
    }

    precondition {
      condition     = local.network_id_by_node[each.key] != null || var.network_name != null || try(each.value.network_name, null) != null
      error_message = "Set one of: `network_id`/`nodes[*].network_id` or `network_name`/`nodes[*].network_name`."
    }
  }
}
