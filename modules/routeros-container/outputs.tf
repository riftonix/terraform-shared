output "interface_name" {
  description = "RouterOS veth interface name of the container"
  value       = routeros_interface_veth.this.name
}

output "router_address" {
  description = "Router host address on the container link"
  value       = local.router_host
  depends_on  = [routeros_ip_address.this]
}

output "container_address" {
  description = "Container host address on the container link"
  value       = local.container_host
}

output "container_id" {
  description = "RouterOS ID of the container"
  value       = routeros_container.this.id
}

output "egress" {
  description = "Egress object suitable for routeros-egress-policy, or null without var.egress"
  value = var.egress == null ? null : {
    routing_table = local.egress_routing
    gateway       = local.container_host
    interface     = routeros_interface_veth.this.name
    comment       = local.comment
  }
  depends_on = [routeros_ip_address.this]
}
