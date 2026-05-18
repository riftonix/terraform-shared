locals {
  tcp_port_inputs = {
    for port in var.allowed_tcp_ports : "tcp-${port}" => {
      protocol = "tcp"
      dst_port = port
      comment  = "Allow TCP input ${port}"
    }
  }

  udp_port_inputs = {
    for port in var.allowed_udp_ports : "udp-${port}" => {
      protocol = "udp"
      dst_port = port
      comment  = "Allow UDP input ${port}"
    }
  }

  allowed_inputs = merge(local.tcp_port_inputs, local.udp_port_inputs, var.allowed_inputs)

  allowed_forwards = {
    for name, rule in var.allowed_forwards : name => merge(rule, {
      src_address = try(trimsuffix(rule.src_address, "/32"), null)
      dst_address = try(trimsuffix(rule.dst_address, "/32"), null)
    })
  }

  drop_forwards = {
    for name, rule in var.drop_forwards : name => merge(rule, {
      src_address = try(trimsuffix(rule.src_address, "/32"), null)
      dst_address = try(trimsuffix(rule.dst_address, "/32"), null)
    })
  }

  srcnats = {
    for name, rule in var.srcnats : name => merge(rule, {
      src_address = try(trimsuffix(rule.src_address, "/32"), null)
      dst_address = try(trimsuffix(rule.dst_address, "/32"), null)
    })
  }
}

resource "routeros_ip_firewall_filter" "established_related" {
  action           = "accept"
  chain            = "input"
  connection_state = "established,related"
  comment          = "Allow established and related input"
}

resource "routeros_ip_firewall_filter" "allowed" {
  for_each = local.allowed_inputs

  action       = "accept"
  chain        = "input"
  protocol     = each.value.protocol
  dst_port     = each.value.dst_port
  in_interface = try(each.value.in_interface, null)
  comment      = coalesce(try(each.value.comment, null), "Allow ${upper(each.value.protocol)} input ${each.value.dst_port}")

  depends_on = [routeros_ip_firewall_filter.established_related]
}

resource "routeros_ip_firewall_filter" "drop" {
  count = var.drop_other_input ? 1 : 0

  action  = "drop"
  chain   = "input"
  comment = "Drop other input"

  depends_on = [
    routeros_ip_firewall_filter.allowed,
  ]
}

resource "routeros_ip_firewall_filter" "allowed_forward" {
  for_each = local.allowed_forwards

  action           = "accept"
  chain            = "forward"
  protocol         = try(each.value.protocol, null)
  dst_port         = try(each.value.dst_port, null)
  in_interface     = try(each.value.in_interface, null)
  out_interface    = try(each.value.out_interface, null)
  src_address      = try(each.value.src_address, null)
  dst_address      = try(each.value.dst_address, null)
  src_address_list = try(each.value.src_address_list, null)
  dst_address_list = try(each.value.dst_address_list, null)
  comment          = coalesce(try(each.value.comment, null), "Allow forward ${each.key}")
}

resource "routeros_ip_firewall_filter" "drop_forward" {
  for_each = local.drop_forwards

  action           = "drop"
  chain            = "forward"
  protocol         = try(each.value.protocol, null)
  dst_port         = try(each.value.dst_port, null)
  in_interface     = try(each.value.in_interface, null)
  out_interface    = try(each.value.out_interface, null)
  src_address      = try(each.value.src_address, null)
  dst_address      = try(each.value.dst_address, null)
  src_address_list = try(each.value.src_address_list, null)
  dst_address_list = try(each.value.dst_address_list, null)
  comment          = coalesce(try(each.value.comment, null), "Drop forward ${each.key}")

  depends_on = [routeros_ip_firewall_filter.allowed_forward]
}

resource "routeros_ip_firewall_nat" "srcnat" {
  for_each = local.srcnats

  action           = each.value.action
  chain            = "srcnat"
  out_interface    = try(each.value.out_interface, null)
  src_address      = try(each.value.src_address, null)
  dst_address      = try(each.value.dst_address, null)
  src_address_list = try(each.value.src_address_list, null)
  dst_address_list = try(each.value.dst_address_list, null)
  comment          = coalesce(try(each.value.comment, null), "Source NAT ${each.key}")
}
