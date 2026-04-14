data "beget_softwares" "this" {}

locals {
  effective_region_by_node = {
    for name, node in var.nodes : name => coalesce(try(node.region, null), var.region)
  }

  effective_software_slug_by_node = {
    for name, node in var.nodes : name => (
      try(node.software_slug, null) != null
      ? node.software_slug
      : var.software_slug
    )
  }

  effective_cpu_by_node = {
    for name, node in var.nodes : name => coalesce(try(node.cpu, null), var.cpu)
  }

  effective_ram_mb_by_node = {
    for name, node in var.nodes : name => coalesce(try(node.ram_mb, null), var.ram_mb)
  }

  effective_disk_mb_by_node = {
    for name, node in var.nodes : name => coalesce(try(node.disk_mb, null), var.disk_mb)
  }

  effective_cpu_class_by_node = {
    for name, node in var.nodes : name => coalesce(try(node.cpu_class, null), var.cpu_class)
  }

  effective_ssh_key_ids_by_node = {
    for name, node in var.nodes : name => coalesce(try(node.ssh_key_ids, null), var.ssh_key_ids)
  }

  effective_ssh_public_key_by_node = {
    for name, node in var.nodes : name => (
      try(node.ssh_public_key, null) != null
      ? node.ssh_public_key
      : var.ssh_public_key
    )
  }

  effective_create_additional_ip_by_node = {
    for name, node in var.nodes : name => coalesce(try(node.create_additional_ip, null), var.create_additional_ip)
  }

  effective_private_network_id_by_node = {
    for name, node in var.nodes : name => (
      try(node.private_network_id, null) != null
      ? node.private_network_id
      : var.private_network_id
    )
  }

  software_id_by_node = {
    for name, slug in local.effective_software_slug_by_node :
    name => (slug != null ? try(data.beget_softwares.this.softwares[slug].id, null) : null)
  }
}

resource "beget_ssh_key" "this" {
  for_each = {
    for name, node in var.nodes : name => node
    if length(local.effective_ssh_key_ids_by_node[name]) == 0
  }

  name       = "${each.key}-key"
  public_key = trimspace(
    local.effective_ssh_public_key_by_node[each.key] != null
    ? local.effective_ssh_public_key_by_node[each.key]
    : tls_private_key.generated[each.key].public_key_openssh
  )
}

resource "tls_private_key" "generated" {
  for_each = {
    for name, node in var.nodes : name => node
    if length(local.effective_ssh_key_ids_by_node[name]) == 0 && local.effective_ssh_public_key_by_node[name] == null
  }

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "beget_compute_instance" "this" {
  for_each = var.nodes

  name        = each.key
  hostname    = try(each.value.hostname, null)
  description = try(each.value.description, null)
  region      = local.effective_region_by_node[each.key]

  configuration = {
    cpu       = local.effective_cpu_by_node[each.key]
    ram_mb    = local.effective_ram_mb_by_node[each.key]
    disk_mb   = local.effective_disk_mb_by_node[each.key]
    cpu_class = local.effective_cpu_class_by_node[each.key]
  }

  image = (
    try(each.value.image_id, null) != null ? {
      image_id = each.value.image_id
      } : (
      try(each.value.snapshot_id, null) != null ? {
        snapshot_id = each.value.snapshot_id
        } : {
        software = {
          id             = local.software_id_by_node[each.key]
          isp_license_id = try(each.value.isp_license_id, null)
          vars           = try(each.value.software_vars, null)
        }
      }
    )
  )

  access = {
    ssh_keys = length(local.effective_ssh_key_ids_by_node[each.key]) > 0 ? local.effective_ssh_key_ids_by_node[each.key] : [tonumber(beget_ssh_key.this[each.key].id)]
  }

  private_networks = local.effective_private_network_id_by_node[each.key] != null ? {
    (local.effective_private_network_id_by_node[each.key]) = {
      address = try(each.value.private_network_ip, null)
    }
  } : null

  lifecycle {
    precondition {
      condition = (
        length(local.effective_ssh_key_ids_by_node[each.key]) > 0 ||
        local.effective_ssh_public_key_by_node[each.key] != null ||
        try(tls_private_key.generated[each.key].private_key_openssh, null) != null
      )
      error_message = "Unable to resolve SSH access key for node `${each.key}`."
    }

    precondition {
      condition = (
        try(each.value.image_id, null) != null ||
        try(each.value.snapshot_id, null) != null ||
        local.software_id_by_node[each.key] != null
      )
      error_message = "Set one of image source options for node `${each.key}`: `image_id`, `snapshot_id`, or valid `software_slug`."
    }
  }
}

resource "beget_additional_ip" "this" {
  for_each = {
    for name, node in var.nodes : name => node
    if local.effective_create_additional_ip_by_node[name]
  }

  region              = local.effective_region_by_node[each.key]
  compute_instance_id = beget_compute_instance.this[each.key].id
}
