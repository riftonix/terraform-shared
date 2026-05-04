locals {
  non_main_egresses = {
    for name, egress in var.egresses : name => egress
    if egress.routing_table != "main"
  }

  egress_has_address_list_policy = {
    for name, egress in var.egresses : name => (
      length(coalesce(try(egress.destination_prefixes, null), [])) > 0
      || length(coalesce(try(egress.dns_names, null), [])) > 0
    )
  }

  destination_address_lists = {
    for name, egress in var.egresses :
    name => "egress-${name}"
    if local.egress_has_address_list_policy[name]
  }

  mangle_non_main_egresses = {
    for name, egress in local.non_main_egresses : name => egress
    if local.egress_has_address_list_policy[name] || name == var.default_egress
  }

  egress_marks = {
    for name, egress in var.egresses : name => {
      connection = coalesce(try(egress.connection_mark, null), "to-${name}")
      routing    = coalesce(try(egress.routing_mark, null), "to-${name}")
    }
  }

  dns_name_rules = {
    for entry in flatten([
      for egress_name, egress in var.egresses : [
        for name in coalesce(try(egress.dns_names, null), []) : {
          key          = "${egress_name}-${replace(name, ".", "-")}"
          egress_name  = egress_name
          name         = name
          address_list = local.destination_address_lists[egress_name]
          comment      = coalesce(try(egress.comment, null), "Egress ${egress_name}")
        }
        if local.egress_has_address_list_policy[egress_name]
      ]
    ]) : entry.key => entry
  }

  destination_prefixes = {
    for entry in flatten([
      for egress_name, egress in var.egresses : [
        for prefix in coalesce(try(egress.destination_prefixes, null), []) : {
          key          = "${egress_name}-${replace(replace(prefix, ".", "-"), "/", "_")}"
          address_list = local.destination_address_lists[egress_name]
          address      = prefix
          comment      = coalesce(try(egress.comment, null), "Egress ${egress_name}")
        }
        if local.egress_has_address_list_policy[egress_name]
      ]
    ]) : entry.key => entry
  }

  static_route_entries = {
    for entry in flatten([
      for egress_name, egress in var.egresses : [
        for prefix in coalesce(try(egress.static_destination_prefixes, null), []) : {
          key           = "${egress_name}-${replace(replace(prefix, ".", "-"), "/", "_")}"
          egress_name   = egress_name
          dst_address   = prefix
          gateway       = egress.gateway
          routing_table = "main"
          comment       = coalesce(try(egress.comment, null), "Egress ${egress_name}")
        }
        if try(egress.gateway, null) != null
      ]
    ]) : entry.key => entry
  }

  source_local_bypasses = {
    for entry in flatten([
      for source_name, source in var.sources : [
        for index, prefix in var.local_bypass_prefixes : {
          key          = "${source_name}-${index}"
          source_name  = source_name
          in_interface = try(source.in_interface, null)
          src_address  = try(source.src_address, null)
          dst_address  = prefix
        }
      ]
    ]) : entry.key => entry
  }

  main_egress_bypasses = {
    for entry in flatten([
      for source_name, source in var.sources : [
        for egress_name, egress in var.egresses : {
          key              = "${source_name}-${egress_name}"
          source_name      = source_name
          egress_name      = egress_name
          in_interface     = try(source.in_interface, null)
          src_address      = try(source.src_address, null)
          dst_address_list = local.destination_address_lists[egress_name]
          comment          = coalesce(try(egress.comment, null), "Egress ${egress_name}")
        }
        if egress.routing_table == "main" && local.egress_has_address_list_policy[egress_name]
      ]
    ]) : entry.key => entry
  }

  explicit_non_main_marks = {
    for entry in flatten([
      for source_name, source in var.sources : [
        for egress_name, egress in local.mangle_non_main_egresses : {
          key              = "${source_name}-${egress_name}"
          source_name      = source_name
          egress_name      = egress_name
          in_interface     = try(source.in_interface, null)
          src_address      = try(source.src_address, null)
          dst_address_list = local.destination_address_lists[egress_name]
          comment          = coalesce(try(egress.comment, null), "Egress ${egress_name}")
        }
        if local.egress_has_address_list_policy[egress_name]
      ]
    ]) : entry.key => entry
  }

  default_egress_marks = {
    for source_name, source in var.sources : source_name => {
      egress_name  = var.default_egress
      in_interface = try(source.in_interface, null)
      src_address  = try(source.src_address, null)
      comment      = coalesce(try(var.egresses[var.default_egress].comment, null), "Default egress ${var.default_egress}")
    }
    if var.egresses[var.default_egress].routing_table != "main"
  }

  routing_marks = {
    for entry in flatten([
      for source_name, source in var.sources : [
        for egress_name, egress in local.mangle_non_main_egresses : {
          key          = "${source_name}-${egress_name}"
          egress_name  = egress_name
          in_interface = try(source.in_interface, null)
          src_address  = try(source.src_address, null)
          comment      = coalesce(try(egress.comment, null), "Egress ${egress_name}")
        }
      ]
    ]) : entry.key => entry
  }
}

resource "routeros_ip_dns_record" "egress_name" {
  for_each = local.dns_name_rules

  name            = each.value.name
  match_subdomain = true
  type            = "FWD"
  forward_to      = var.dns_forward_to
  address_list    = each.value.address_list
  disabled        = false
  comment         = "${each.value.comment} DNS address-list"
}

resource "routeros_ip_firewall_addr_list" "destination" {
  for_each = local.destination_prefixes

  list    = each.value.address_list
  address = each.value.address
  comment = "${each.value.comment} destination"
}

resource "routeros_routing_table" "egress" {
  for_each = local.mangle_non_main_egresses

  name = each.value.routing_table
  fib  = true
}

resource "routeros_ip_route" "egress_default" {
  for_each = local.mangle_non_main_egresses

  dst_address   = "0.0.0.0/0"
  gateway       = each.value.gateway
  routing_table = each.value.routing_table
  comment       = coalesce(try(each.value.comment, null), "Egress ${each.key}")

  depends_on = [routeros_routing_table.egress]
}

resource "routeros_ip_route" "static_egress" {
  for_each = local.static_route_entries

  dst_address   = each.value.dst_address
  gateway       = each.value.gateway
  routing_table = each.value.routing_table
  comment       = "${each.value.comment} static egress"
}

resource "routeros_ip_firewall_mangle" "local_bypass" {
  for_each = length(local.mangle_non_main_egresses) > 0 ? local.source_local_bypasses : {}

  action       = "accept"
  chain        = var.chain
  in_interface = each.value.in_interface
  src_address  = each.value.src_address
  dst_address  = each.value.dst_address
  comment      = "Bypass policy routing for local destination"
}

resource "routeros_ip_firewall_mangle" "main_egress_bypass" {
  for_each = length(local.mangle_non_main_egresses) > 0 ? local.main_egress_bypasses : {}

  action           = "accept"
  chain            = var.chain
  in_interface     = each.value.in_interface
  src_address      = each.value.src_address
  dst_address_list = each.value.dst_address_list
  comment          = "${each.value.comment} policy bypass"

  depends_on = [
    routeros_ip_firewall_addr_list.destination,
    routeros_ip_firewall_mangle.local_bypass,
  ]
}

resource "routeros_ip_firewall_mangle" "explicit_non_main_connection" {
  for_each = local.explicit_non_main_marks

  action              = "mark-connection"
  chain               = var.chain
  in_interface        = each.value.in_interface
  src_address         = each.value.src_address
  dst_address_list    = each.value.dst_address_list
  connection_state    = "new"
  connection_mark     = "no-mark"
  new_connection_mark = local.egress_marks[each.value.egress_name].connection
  passthrough         = true
  comment             = "${each.value.comment} mark connection"

  depends_on = [
    routeros_ip_firewall_addr_list.destination,
    routeros_ip_firewall_mangle.local_bypass,
    routeros_ip_firewall_mangle.main_egress_bypass,
  ]
}

resource "routeros_ip_firewall_mangle" "default_connection" {
  for_each = local.default_egress_marks

  action              = "mark-connection"
  chain               = var.chain
  in_interface        = each.value.in_interface
  src_address         = each.value.src_address
  connection_state    = "new"
  connection_mark     = "no-mark"
  new_connection_mark = local.egress_marks[each.value.egress_name].connection
  passthrough         = true
  comment             = "${each.value.comment} mark connection"

  depends_on = [
    routeros_ip_firewall_mangle.local_bypass,
    routeros_ip_firewall_mangle.main_egress_bypass,
    routeros_ip_firewall_mangle.explicit_non_main_connection,
  ]
}

resource "routeros_ip_firewall_mangle" "routing" {
  for_each = local.routing_marks

  action           = "mark-routing"
  chain            = var.chain
  in_interface     = each.value.in_interface
  src_address      = each.value.src_address
  connection_mark  = local.egress_marks[each.value.egress_name].connection
  new_routing_mark = local.egress_marks[each.value.egress_name].routing
  passthrough      = false
  comment          = "${each.value.comment} mark routing"

  depends_on = [
    routeros_ip_firewall_mangle.explicit_non_main_connection,
    routeros_ip_firewall_mangle.default_connection,
    routeros_ip_route.egress_default,
  ]
}
