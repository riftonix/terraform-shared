locals {
  interface_network = "${cidrhost(var.interface.address, 0)}/${split("/", var.interface.address)[1]}"

  active_site_peers = {
    for peer_name, peer in var.site_peers : peer_name => peer
    if coalesce(try(peer.enabled, null), true)
  }

  site_peer_allowed_addresses = {
    for peer_name, peer in local.active_site_peers :
    peer_name => coalesce(
      try(peer.allowed_addresses, null),
      ["0.0.0.0/0"]
    )
  }

  route_entries = {
    for entry in flatten([
      for peer_name, peer in local.active_site_peers : [
        for route_prefix in coalesce(try(peer.route_prefixes, null), peer.remote_networks) : {
          key         = "${peer_name}-${replace(replace(route_prefix, ".", "-"), "/", "_")}"
          comment     = coalesce(try(peer.comment, null), "WireGuard route ${peer_name}")
          dst_address = route_prefix
        }
      ]
    ]) : entry.key => entry
  }

  local_to_remote_forward_rules = {
    for entry in flatten([
      for peer_name, peer in local.active_site_peers : [
        for pair in setproduct(toset(peer.local_networks), toset(peer.remote_networks)) : {
          key         = "${peer_name}-l2r-${replace(replace(pair[0], ".", "-"), "/", "_")}-${replace(replace(pair[1], ".", "-"), "/", "_")}"
          src_address = pair[0]
          dst_address = pair[1]
          comment     = coalesce(try(peer.comment, null), "WireGuard peer ${peer_name}")
        }
      ]
    ]) : entry.key => entry
  }

  remote_to_local_forward_rules = {
    for entry in flatten([
      for peer_name, peer in local.active_site_peers : [
        for pair in setproduct(toset(peer.remote_networks), toset(peer.local_networks)) : {
          key         = "${peer_name}-r2l-${replace(replace(pair[0], ".", "-"), "/", "_")}-${replace(replace(pair[1], ".", "-"), "/", "_")}"
          src_address = pair[0]
          dst_address = pair[1]
          comment     = coalesce(try(peer.comment, null), "WireGuard peer ${peer_name}")
        }
      ]
    ]) : entry.key => entry
  }

  active_road_warrior_peers = var.road_warrior == null ? {} : {
    for peer_name, peer in try(var.road_warrior.peers, {}) : peer_name => peer
    if coalesce(try(peer.enabled, null), true)
  }

  road_warrior_generated_keys = {
    for peer_name, peer in local.active_road_warrior_peers : peer_name => peer
    if try(peer.private_key, null) != null || try(peer.public_key, null) == null
  }

  road_warrior_generated_configs = {
    for peer_name, peer in local.active_road_warrior_peers : peer_name => peer
    if try(peer.private_key, null) != null || try(peer.public_key, null) == null
  }

  road_warrior_public_keys = {
    for peer_name, peer in local.active_road_warrior_peers :
    peer_name => coalesce(
      try(peer.public_key, null),
      try(wireguard_asymmetric_key.road_warrior[peer_name].public_key, null)
    )
  }

  road_warrior_private_keys = {
    for peer_name, peer in local.road_warrior_generated_configs :
    peer_name => coalesce(
      try(peer.private_key, null),
      try(wireguard_asymmetric_key.road_warrior[peer_name].private_key, null)
    )
  }

  road_warrior_preshared_keys = {
    for peer_name, peer in local.active_road_warrior_peers :
    peer_name => coalesce(
      try(peer.preshared_key, null),
      try(wireguard_preshared_key.road_warrior[peer_name].key, null)
    )
  }

  internet_egress_nat_sources = {
    for entry in flatten([
      for peer_name, peer in local.active_site_peers : [
        for source_network in coalesce(try(peer.internet_egress_source_networks, null), []) : {
          key         = "${peer_name}-${replace(replace(source_network, ".", "-"), "/", "_")}"
          src_address = source_network
          comment     = coalesce(try(peer.comment, null), "WireGuard peer ${peer_name}")
        }
      ]
    ]) : entry.key => entry
  }

  road_warrior_nat_excluded_prefixes = var.road_warrior == null ? [] : coalesce(
    try(var.road_warrior.nat_excluded_prefixes, null),
    []
  )

  road_warrior_nat_excluded_prefix_map = {
    for prefix in local.road_warrior_nat_excluded_prefixes :
    replace(replace(prefix, ".", "-"), "/", "_") => prefix
  }

  road_warrior_nat_exclusion_list_name = "${var.interface.name}-nat-excluded"
}

resource "routeros_interface_wireguard" "this" {
  name        = var.interface.name
  listen_port = var.interface.listen_port
  comment     = try(var.interface.comment, null)
  mtu         = try(var.interface.mtu, null)
  private_key = try(var.interface.private_key, null)
}

resource "routeros_ip_address" "this" {
  address   = var.interface.address
  interface = routeros_interface_wireguard.this.name
  comment   = coalesce(try(var.interface.comment, null), "WireGuard interface address")
}

resource "routeros_interface_wireguard_peer" "site" {
  for_each = local.active_site_peers

  name                 = each.key
  interface            = routeros_interface_wireguard.this.name
  public_key           = each.value.peer_public_key
  preshared_key        = try(each.value.preshared_key, null)
  endpoint_address     = try(each.value.endpoint_address, null)
  endpoint_port        = try(each.value.endpoint_port, null) == null ? null : tostring(each.value.endpoint_port)
  persistent_keepalive = try(each.value.persistent_keepalive, null)
  allowed_address      = local.site_peer_allowed_addresses[each.key]
  is_responder         = try(each.value.responder_only, false)
  comment              = coalesce(try(each.value.comment, null), "WireGuard peer ${each.key}")
}

resource "wireguard_asymmetric_key" "road_warrior" {
  for_each = local.road_warrior_generated_keys

  private_key = try(each.value.private_key, null)
}

resource "wireguard_preshared_key" "road_warrior" {
  for_each = {
    for peer_name, peer in local.active_road_warrior_peers : peer_name => peer
    if try(peer.preshared_key, null) == null
  }
}

resource "routeros_interface_wireguard_peer" "road_warrior" {
  for_each = local.active_road_warrior_peers

  name                 = each.key
  interface            = routeros_interface_wireguard.this.name
  public_key           = local.road_warrior_public_keys[each.key]
  preshared_key        = local.road_warrior_preshared_keys[each.key]
  allowed_address      = [each.value.address]
  client_address       = each.value.address
  persistent_keepalive = coalesce(try(each.value.persistent_keepalive, null), try(var.road_warrior.client_persistent_keepalive, null))
  comment              = coalesce(try(each.value.comment, null), "Road-warrior peer ${each.key}")
}

data "wireguard_config_document" "road_warrior" {
  for_each = local.road_warrior_generated_configs

  private_key = local.road_warrior_private_keys[each.key]
  addresses   = [each.value.address]
  dns         = coalesce(try(each.value.dns, null), try(var.road_warrior.client_dns, null), [])

  dynamic "peer" {
    for_each = [each.value]

    content {
      public_key           = routeros_interface_wireguard.this.public_key
      preshared_key        = local.road_warrior_preshared_keys[each.key]
      endpoint             = try(var.interface.public_endpoint_address, null) == null ? null : "${var.interface.public_endpoint_address}:${var.interface.listen_port}"
      allowed_ips          = coalesce(try(each.value.allowed_ips, null), try(var.road_warrior.client_allowed_ips, null), ["0.0.0.0/0"])
      persistent_keepalive = coalesce(try(each.value.persistent_keepalive, null), try(var.road_warrior.client_persistent_keepalive, null), null) == null ? null : tonumber(trimsuffix(coalesce(try(each.value.persistent_keepalive, null), try(var.road_warrior.client_persistent_keepalive, null)), "s"))
      description          = coalesce(try(each.value.comment, null), "Road-warrior peer ${each.key}")
    }
  }
}

resource "routeros_ip_route" "site" {
  for_each = local.route_entries

  dst_address = each.value.dst_address
  gateway     = routeros_interface_wireguard.this.name
  comment     = each.value.comment
}

resource "routeros_ip_firewall_filter" "wireguard_input" {
  count = var.manage_firewall ? 1 : 0

  action   = "accept"
  chain    = "input"
  protocol = "udp"
  dst_port = tostring(var.interface.listen_port)
  comment  = coalesce(try(var.interface.comment, null), "Allow WireGuard input")
}

resource "routeros_ip_firewall_filter" "forward_local_to_remote" {
  for_each = var.manage_firewall ? local.local_to_remote_forward_rules : {}

  action      = "accept"
  chain       = "forward"
  src_address = each.value.src_address
  dst_address = each.value.dst_address
  comment     = "${each.value.comment} local-to-remote"
}

resource "routeros_ip_firewall_filter" "forward_remote_to_local" {
  for_each = var.manage_firewall ? local.remote_to_local_forward_rules : {}

  action      = "accept"
  chain       = "forward"
  src_address = each.value.src_address
  dst_address = each.value.dst_address
  comment     = "${each.value.comment} remote-to-local"
}

resource "routeros_ip_firewall_filter" "road_warrior_forward" {
  count = var.manage_firewall && var.road_warrior != null ? 1 : 0

  action      = "accept"
  chain       = "forward"
  src_address = local.interface_network
  comment     = coalesce(try(var.interface.comment, null), "Allow road-warrior forwarding")
}

resource "routeros_ip_firewall_filter" "internet_egress_forward" {
  for_each = var.manage_firewall ? local.internet_egress_nat_sources : {}

  action      = "accept"
  chain       = "forward"
  src_address = each.value.src_address
  comment     = "${each.value.comment} internet-egress"
}

resource "routeros_ip_firewall_addr_list" "road_warrior_nat_exclusion" {
  for_each = var.road_warrior != null && try(var.road_warrior.create_internet_nat, false) ? local.road_warrior_nat_excluded_prefix_map : {}

  list    = local.road_warrior_nat_exclusion_list_name
  address = each.value
  comment = coalesce(try(var.interface.comment, null), "Road-warrior NAT exclusion")
}

resource "routeros_ip_firewall_nat" "road_warrior_nat_exclusion" {
  count = var.road_warrior != null && try(var.road_warrior.create_internet_nat, false) && length(local.road_warrior_nat_excluded_prefixes) > 0 ? 1 : 0

  action           = "accept"
  chain            = "srcnat"
  src_address      = local.interface_network
  dst_address_list = local.road_warrior_nat_exclusion_list_name
  comment          = coalesce(try(var.interface.comment, null), "Road-warrior NAT exclusion")
}

resource "routeros_ip_firewall_nat" "road_warrior_nat" {
  count = var.road_warrior != null && try(var.road_warrior.create_internet_nat, false) ? 1 : 0

  action        = "masquerade"
  chain         = "srcnat"
  src_address   = local.interface_network
  out_interface = try(var.road_warrior.internet_nat_out_interface, null)
  comment       = coalesce(try(var.interface.comment, null), "Road-warrior internet egress")
}

resource "routeros_ip_firewall_nat" "internet_egress_nat" {
  for_each = local.internet_egress_nat_sources

  action      = "masquerade"
  chain       = "srcnat"
  src_address = each.value.src_address
  comment     = "${each.value.comment} internet-egress"
}
