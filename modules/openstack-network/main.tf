resource "openstack_networking_network_v2" "this" {
  name                  = var.network_name
  description           = var.network_description
  admin_state_up        = var.network_admin_state_up
  port_security_enabled = var.network_port_security_enabled
  mtu                   = var.network_mtu
  dns_domain            = var.network_dns_domain
  tags                  = coalesce(var.network_tags, [])
  value_specs           = var.network_value_specs
}

resource "openstack_networking_subnet_v2" "this" {
  for_each = var.subnets

  name                 = each.key
  description          = try(each.value.description, null)
  network_id           = openstack_networking_network_v2.this.id
  cidr                 = try(each.value.cidr, null)
  subnetpool_id        = try(each.value.subnetpool_id, null)
  prefix_length        = try(each.value.prefix_length, null)
  ip_version           = try(each.value.ip_version, 4)
  gateway_ip           = try(each.value.gateway_ip, null)
  no_gateway           = try(each.value.no_gateway, false)
  enable_dhcp          = try(each.value.enable_dhcp, true)
  dns_nameservers      = try(each.value.dns_nameservers, [])
  dns_publish_fixed_ip = try(each.value.dns_publish_fixed_ip, false)
  service_types        = try(each.value.service_types, [])
  segment_id           = try(each.value.segment_id, null)
  value_specs          = try(each.value.value_specs, {})
  tags                 = coalesce(try(each.value.tags, null), [])

  dynamic "allocation_pool" {
    for_each = try(each.value.allocation_pools, [])
    content {
      start = allocation_pool.value.start
      end   = allocation_pool.value.end
    }
  }
}
