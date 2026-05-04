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
