output "interface_name" {
  description = "RouterOS OpenVPN client interface name"
  value       = var.name
  depends_on  = [routeros_system_script.import_ovpn]
}

output "routing_table" {
  description = "Routing table name exported for policy routing"
  value       = local.routing_table
  depends_on  = [routeros_system_script.import_ovpn]
}

output "egress" {
  description = "Egress object suitable for routeros-egress-policy"
  value = {
    routing_table = local.routing_table
    gateway       = local.gateway
    comment       = local.comment
  }
  depends_on = [routeros_system_script.import_ovpn]
}
