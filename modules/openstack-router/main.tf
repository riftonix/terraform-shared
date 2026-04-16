locals {
  network_module_subnet_name_to_id_maps = [
    for module_output in var.openstack_network_modules : {
      for subnet_name, _ in try(module_output[var.openstack_network_modules_subnets_key], {}) :
      subnet_name => try(module_output.subnets[subnet_name].id, null)
    }
  ]

  network_module_subnet_name_to_id = merge(
    {},
    local.network_module_subnet_name_to_id_maps...
  )

  explicit_subnet_name_to_id = {
    for subnet_id in var.subnet_ids : subnet_id => subnet_id
  }

  effective_subnet_name_to_id = merge(
    local.network_module_subnet_name_to_id,
    local.explicit_subnet_name_to_id
  )

  effective_subnet_ids = values(local.effective_subnet_name_to_id)

  unresolved_subnet_keys = [
    for subnet_name, subnet_id in local.network_module_subnet_name_to_id : subnet_name
    if subnet_id == null
  ]

  effective_external_network_id = coalesce(
    var.external_network_id,
    try(data.openstack_networking_network_v2.external[0].id, null)
  )
}

data "openstack_networking_network_v2" "external" {
  count = var.external_network_id == null ? 1 : 0
  name  = var.external_network_name
}

resource "openstack_networking_router_v2" "this" {
  name                = var.router_name
  description         = var.router_description
  admin_state_up      = var.router_admin_state_up
  external_network_id = local.effective_external_network_id
  enable_snat         = var.router_enable_snat
  tags                = var.router_tags

  lifecycle {
    precondition {
      condition     = length(local.effective_subnet_ids) > 0
      error_message = "At least one subnet must be attached: provide `subnet_ids` and/or valid `openstack_network_modules` with subnet IDs."
    }

    precondition {
      condition     = length(local.unresolved_subnet_keys) == 0
      error_message = "Some subnet keys from `openstack_network_modules` could not be resolved to subnet IDs."
    }
  }
}

resource "openstack_networking_router_interface_v2" "this" {
  for_each = local.effective_subnet_name_to_id

  router_id = openstack_networking_router_v2.this.id
  subnet_id = each.value
}
