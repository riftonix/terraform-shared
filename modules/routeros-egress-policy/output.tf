output "routing_tables" {
  description = "Routing tables created for non-main egresses"
  value = {
    for name, table in routeros_routing_table.egress :
    name => table.name
  }
}

output "static_routes" {
  description = "Static egress routes created from static_destination_prefixes"
  value = {
    for key, route in routeros_ip_route.static_egress :
    key => {
      dst_address   = route.dst_address
      gateway       = route.gateway
      routing_table = route.routing_table
    }
  }
}

output "destination_address_lists" {
  description = "Destination address lists configured by egress"
  value       = local.destination_address_lists
}
